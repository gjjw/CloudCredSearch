# CloudCredSearch

This bash script is a supplement for the cloud_enum tool: https://github.com/initstring/cloud_enum .
It takes the output of cloud_enum that is generated with -l option and iterates through all the files discovered by cloud_enum searching for credential strings such as "password=", or any other you would like to search for.

Use:
1) Run cloud_enum with a string like: cloud_enum -k <KEY_WORD> -t 10 -m <MUTATIONS_DICT> -b <BRUTEFORCE_DICT> -l <REPORT_FILE>
2) Provide the cloud_enum report to this script as: CloudCredSearch.sh <cloud_enum_report_file> <credentials_search_report_file_to_be_generated>
