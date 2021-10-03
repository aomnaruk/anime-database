#!/bin/bash

#------- SETUP ------
BASE_URL=("http://localhost:8000/v3" "https://api.jikan.moe/v3")
BASE_OUTPUT_PATH="/home/thanapongs/MAL/docker/jikan-docker/v3/data"
INPUT_FILE="myanimelist_anime_id.txt"

#--------------------



#Parameter #1 URL
#Parameter #2 savelocation

curl_and_save (){
  local success=1   

  if [ ! -f $2  ]; then 
    while [ $success -ne 0 ] 
    do 
    
      sleep 1
      echo "Getting JSON from $1 and save to $2..."    
      curl --fail --silent $1 -o $2
      success=$? 
    if curl -s --head  --request GET $1  | grep "404 Not Found" > /dev/null
    then
       echo "Skipped, 404 Not Found status"
       success=0
    fi
    done
  else
    echo "Skipped, found data on path $2"
  fi
}

restart_docker(){
  while : ; do  sleep 300 && docker restart v3_jikan-rest-api_1 ;  done
}

IFS="
"
total=$(wc -l $INPUT_FILE | cut -f1 -d" ")
current=0
api_site_count=${#BASE_URL[@]}


for id in $(cat $INPUT_FILE); do
  let "current=current+1"
  target_api_url=${BASE_URL[$(($current % $api_site_count))]}
  curl_and_save "$target_api_url/anime/${id}" "$BASE_OUTPUT_PATH/anime/${id}.json" &
  curl_and_save "$target_api_url/anime/${id}/recommendations" "$BASE_OUTPUT_PATH/anime/recommendations/${id}.json" &
  curl_and_save "$target_api_url/anime/${id}/characters_staff" "$BASE_OUTPUT_PATH/anime/characters_staff/${id}.json" &

  wait 
done


