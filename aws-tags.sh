#!/bin/bash
set -ex

i=(i-xxx i-yyy i-zzz)

for a in "${i[@]}"
do
    # aws ec2 delete-tags \
    # --resources $a \
    # --tags Key=service,Value=processing\
    # --region us-west-2

    aws ec2 create-tags \
    --resources $a \
    --tags 'Key=service,Value=processing_'\
    --region us-west-2

done
