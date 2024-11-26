#! /bin/bash
count=5000
for i in $(seq $count); do
  curl http://localhost:8282/api/hello
  echo " ${i}"
  sleep 1
done