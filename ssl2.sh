#!/bin/bash

while getopts ":f:" opt; do
  case $opt in
    f)
      url_file="$OPTARG"
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

if [ -z "$url_file" ]; then
  echo "Usage: $0 -f <URL_file>"
  exit 1
fi

# Loop through each URL in the file
while read -r url; do
  echo "Processing URL: $url"

  # Extract the IP address from the URL using awk
  target_ip=$(echo "$url" | awk -F[/:] '{print $4}')

  if [ -z "$target_ip" ]; then
    echo "Failed to extract IP address from $url"
    continue
  fi

  # Extract the SSL certificate information and only the CN value
  cn_value=$(openssl s_client -showcerts -connect "$target_ip":443 </dev/null 2>/dev/null | openssl x509 -noout -subject | sed -n 's/.*CN = //p')

  if [ -z "$cn_value" ]; then
    echo "Failed to retrieve CN value for $target_ip"
  else
    echo "CN value for $target_ip: $cn_value"
  fi

done < "$url_file"
