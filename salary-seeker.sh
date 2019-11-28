#!/bin/bash

job_id=$1
counter='1'
response='1'
lower_limit='30000'
upper_limit='200000'
salary_var=$((lower_limit + (upper_limit - lower_limit) / 2))

if [[ $# = 0 ]]
then
  echo "    | usage: ./salary-seeker.sh <job id>"
  echo "    | job id can be found in the URL of the job, e.g. https://www.seek.com.au/job/38035537 <--- here"
  echo "    | example: ./salary-seeker.sh 38035537"
  exit 1
fi

job_title=$(curl --silent https://jobsearch-api.cloud.seek.com.au/search?jobid=$job_id | tr ',' '\n' | sed 's/{"title":"//g' | grep '"title":"' | cut -d '"' -f 4)
echo "    | job title: "$job_title
keywords=$(curl --silent https://jobsearch-api.cloud.seek.com.au/search?jobid=$job_id | sed "s/.*$job_id\(.*\)teaser.*/\1/" | cut -d '"' -f 8 | tr -c '[:alnum:]\n\r' '+')
advertiser_id=$(curl --silent https://jobsearch-api.cloud.seek.com.au/search?jobid=$job_id | sed "s/.*advertiser\(.*\)description.*/\1/" | cut -d '"' -f 5)

#find maximum
while [[ $counter -lt '19' ]]
do
  response=$(curl --silent "https://jobsearch-api.cloud.seek.com.au/search?keywords=$keywords&advertiserid=$advertiser_id&sourcesystem=houston&salaryrange=$salary_var-$upper_limit" | grep "$job_id" | wc -l)
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

#find minimum
while [[ $counter -lt '16' ]]
do
  response=$(curl --silent "https://jobsearch-api.cloud.seek.com.au/search?keywords=$keywords&advertiserid=$advertiser_id&sourcesystem=houston&salaryrange=$lower_limit-$salary_var" | grep "$job_id" | wc -l)
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

if [[ $salary_max -gt '199998' ]]
then
  plus='+'
fi

echo -e "    | salary range: ""\033[1m""$"$salary_min" - ""$"$salary_max$plus"\033[0m"
