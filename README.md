# salary-seeker

The jobs listed on seek.com.au usually hide the salary range. You can use salary range search filters, but this is tedious and still vague.

This tool modifies URL parameters and brute-forces the salary range of the job through a binary search algorithm.
```
bash-3.2# ./salary-seeker.sh
    | usage: ./salary-seeker.sh <job id>
    | job id can be found in the URL of the job, e.g. https://www.seek.com.au/job/38035537 <--- here
    | example: ./salary-seeker.sh 38035537
```
<p align="center">
<img src=https://github.com/b3n-j4m1n/salary-seeker/raw/master/demo.gif>
</p>
