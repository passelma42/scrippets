#!/bin/bash

# Create user list
echo "---Hello system users---"
sudo awk -F':' '$2 ~ "\$" {print $1}' /etc/shadow |sort > /home/passelma/userinfo/userlist.txt

# Create diskusage per user

file=/home/passelma/userinfo/userusage.$(date +%Y-%b-%d).txt
if [ -f "$file" ]
then 
  echo "$file already exists."
  #cat $file
else
  while read users
    do
      touch /home/passelma/userinfo/userusage.$(date +%Y-%b-%d).txt
      sudo du -k --max-depth=0 /home/"$users" >> /home/passelma/userinfo/userusage.$(date +%Y-%b-%d).txt
  done < /home/passelma/userinfo/userlist.txt
  
fi

column $file -t | sort -nr


echo "Total used size:"
awk '{sum += $1} END {print sum}' "/home/passelma/userinfo/userusage.$(date +%Y-%b-%d).txt"