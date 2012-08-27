#!/bin/bash

JENKINS_HOST=localhost
JENKINS_PORT=10000
JENKINS_JOB=website-build
JENKINS_LATEST_JOB=`cat latest_build`

response=`curl "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/$JENKINS_LATEST_JOB/api/xml?tree=result&xpath=//result/text()"`

if [ "$response" == "SUCCESS" ]; then
    exit 0
elif [ "$response" == "FAILURE" ]; then
    exit 1
fi