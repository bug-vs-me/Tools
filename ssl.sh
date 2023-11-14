#!/bin/bash

while getopts ":i:" opt; do
  case $opt in
    i)
      target_ip="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$target_ip" ]; then
  echo "Usage: $0 -i <IP_address>"
  exit 1
fi

# Extract the SSL certificate information and only the CN value
cn_value=$(openssl s_client -showcerts -connect "$target_ip":443 </dev/null 2>/dev/null | openssl x509 -noout -subject | sed -n 's/.*CN = //p')

if [ -z "$cn_value" ]; then
  echo "Failed to retrieve CN value for $target_ip"
  exit 1
fi

echo "CN value for $target_ip: $cn_value"
