#!/bin/bash
set -e

i=0
end=10
while [ $i -le $end ]; do
    url="this is $i"
	echo "creating ASG for $url..."
    i=$(($i+1))
done
