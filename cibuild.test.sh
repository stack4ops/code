#!/bin/sh

ret=$(docker run -d --rm --name $container $test_image)

sleep 5

if ! docker logs $container 2>&1 | grep "Web UI available at"; then
  log 0 "[failed] Test failed!"
  exit 1
fi

log 1 "[success] Test successful"