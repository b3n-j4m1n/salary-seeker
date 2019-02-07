#!/bin/bash

if [[ $# = 0 ]]
then
  echo "    | usage: ./salary-seeker.sh <job id>"
  echo "    | job id can be found in the URL of the job, e.g. https://www.seek.com.au/job/38035537 <--- here"
  echo "    | example: ./salary-seeker.sh 38035537"
  exit 1
fi

job_id=$1
salary_var='150000'
job_title=$(curl --silent https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id | tr ',' '\n' | sed 's/{"title":"//g' | grep '"title":"' | cut -d '"' -f 4)

echo "    | job title: "$job_title

#checking $200000+
response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=$salary_var-999999" | grep '"totalCount":1' | wc -l)
if [[ $response -eq '1' ]]
then
  echo -e "    | salary range: ""\033[1m""$"$salary_var"+""\033[0m"
  exit 0
fi

response='1' #reset response

#find minimum
while [[ $response -ne "0" ]]
do
  response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=0-$salary_var" | grep '"totalCount":1' | wc -l)
  printf "    | finding minimum > ""$""%d\r" "$salary_var"
  salary_var=$((salary_var - 1000))
done
salary_min=$((salary_var + 1000))

response='1' #reset response

#find maximum
while [[ $response -ne "0" ]]
do
  response=$(curl --silent "https://chalice-search-api.cloud.seek.com.au/search?jobid=$job_id&salaryrange=$salary_var-200000" | grep '"totalCount":1' | wc -l)
  printf "    | finding maximum > ""$""%d\r" "$salary_var"
  salary_var=$((salary_var + 1000))
done
salary_max=$((salary_var - 2000))

echo -e "    | salary range: ""\033[1m""$"$salary_min" - ""$"$salary_max"\033[0m"
