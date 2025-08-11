#!/bin/sh

ret=$(docker run -d --rm --name $test_container_name $test_image)

log 5 "container id $ret"

sleep 2

ret=$(docker logs $test_container_name 2>&1 | grep "Web UI available at")

echo "$ret"

log 5 "Test successfull: phpcode is running"
