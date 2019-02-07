#!/bin/bash

counter='1'
response='1'
lower_limit='30000'
upper_limit='200000'
salary_var=$((lower_limit + (upper_limit - lower_limit) / 2))
job_id=$1

if [[ $# = 0 ]]
then
  echo "    | usage: ./salary-seeker.sh <job id>"
  echo "    | job id can be found in the URL of the job, e.g. https://www.seek.com.au/job/38035537 <--- here"
  echo "    | example: ./salary-seeker.sh 38035537"
  exit 1
fi

job_title=$(curl --silent https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id | tr ',' '\n' | sed 's/{"title":"//g' | grep '"title":"' | cut -d '"' -f 4)
echo "    | job title: "$job_title

#checking $200000+
response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=$upper_limit-999999" | grep '"totalCount":1' | wc -l)
if [[ $response -eq '1' ]]
then
  echo -e "    | salary range: ""\033[1m""$"$upper_limit"+""\033[0m"
  exit 0
fi

#reset response
response='1'

#find minimum
while [[ $counter -lt '19' ]]
do
  response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=$salary_var-$upper_limit" | grep '"totalCount":1' | wc -l)
  if [[ $response -eq '1' ]] #if it's found
  then
    lower_limit=$salary_var
    printf "    | finding maximum > ""$""%d\r" "$salary_var"
    salary_var=$(((salary_var + (upper_limit - salary_var) / 2)))
  elif [[ $response -eq '0' ]] #if it's not found
  then
    upper_limit=$salary_var
    printf "    | finding maximum > ""$""%d\r" "$salary_var"
    salary_var=$(((salary_var - (salary_var - lower_limit) / 2)))
  fi
  ((counter++))
done

salary_max=$salary_var

#reset variables
counter='1'
lower_limit='30000'
upper_limit=$salary_max
salary_var=$((lower_limit + (upper_limit - lower_limit) / 2))

#find maximum
while [[ $counter -lt '16' ]]
do
  response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=$lower_limit-$salary_var" | grep '"totalCount":1' | wc -l)
  if [[ $response -eq '1' ]] #if it's found
  then
    upper_limit=$salary_var
    printf "    | finding minimum > ""$""%d\r" "$salary_var"
    salary_var=$(((salary_var - (salary_var - lower_limit) / 2)))
  elif [[ $response -eq '0' ]] #if it's not found
  then
    lower_limit=$salary_var
    printf "    | finding minimum > ""$""%d\r" "$salary_var"
    salary_var=$(((salary_var + (upper_limit - salary_var) / 2)))
  fi
  ((counter++))
done

salary_min=$salary_var

echo -e "    | salary range: ""\033[1m""$"$salary_min" - ""$"$salary_max"\033[0m"
