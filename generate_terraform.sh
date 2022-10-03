#!/bin/bash
# terraform resource generate

function generate_terraform () {
  IFS=$'\n'
  for tmp in `az group list | jq -r -c .[]`
  do
    RG=`echo $tmp | jq -r -c .name`
    ID=`echo $tmp | jq -r -c .id`
    echo "resource \"azurerm_resource_group\" ${RG} {}" > ./tmp.tf
    terraform import azurerm_resource_group.${RG} ${ID}
    terraform state show -no-color azurerm_resource_group.${RG} > ./${target_dir}/${RG}.tf
    for tmp2 in `az resource list --resource-group ${RG} | jq -r -c ".[] | {"name": .name, "id": .id, "type": .type}"`
    do
      RS=`echo ${tmp2} | jq -r -c .name`
      ID2=`echo ${tmp2//serverFarms/serverfarms} | jq -r -c .id`
      echo ${ID2} | grep -q ' '
      if [ $? = 0 ]
      then
	      echo "Canceled because there is a space in the ID."
	      echo "id: ${ID2}"
	      break
      fi
      a_type=`echo ${tmp2} | jq -r -c .type`
      line_count=`awk -F, -v a_type=${a_type} '$2==a_type{print $0}' resource.csv | wc -l | tr -d ' '`
      printf "resource_name: %s\nid: %s\nazure_resource_type: %s\n\n" ${RS} ${ID2} ${a_type}
      case ${line_count} in
	      0)
	        read -p "Resource type not found for terraform. please enter manually. or input n ex)azurerm_function_app > " t_type
          if [[ ${t_type} =~ (n|N|no|No) ]]
          then
            echo "skip"
          else
	        echo "resource \"${t_type}\" \"${RS}\" {}" > ./tmp.tf
          terraform import ${t_type}.${RS} "${ID2}"
          terraform state show -no-color ${t_type}.${RS} | grep -v sensitive >> ./${target_dir}/${RG}.tf
	        printf "%s\n" "${t_type}.${RS} generated."
	        fi
	        ;;
        1)
	        t_type=`awk -F, -v type=${a_type} '$2==type{print $1}' resource.csv`
	        echo "resource \"${t_type}\" \"${RS}\" {}" > ./tmp.tf
          terraform import ${t_type}.${RS} "${ID2}"
          terraform state show -no-color ${t_type}.${RS} | grep -v sensitive >> ./${target_dir}/${RG}.tf
	        printf "%s\n" "${t_type}.${RS} generated."
	        ;;
        [2-9] )
	        PS3="Multiple resource types found. Please select one. >"
	        select t_type in `awk -F, -v type=${a_type} '$2==type{print $1}' resource.csv`
          do
	          echo "resource \"${t_type}\" \"${RS}\" {}" > ./tmp.tf
            terraform import ${t_type}.${RS} "${ID2}"
            terraform state show -no-color ${t_type}.${RS} | grep -v sensitive >> ./${target_dir}/${RG}.tf
	          printf "%s\n" "${t_type}.${RS} generated."
	          break
          done
          ;;
	      * )
                printf "%s: %s¥n" NG:line_count: ${line_count}
	        ;;
      esac
      rm -f tmp.tf
    done
  done
}
{
  export target_dir=./define
  generate_terraform
}
