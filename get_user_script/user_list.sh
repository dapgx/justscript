#!/bin/bash

while IFS=: read -r username _ uid gid _ groups; do
    groups=$(id -Gn $username | tr ' ' ',')
    echo "$username|$gid|$groups"
done < /etc/passwd > all_users_list.csv

#TESTING