#!/bin/bash

JENKINS_HOST=localhost
JENKINS_PORT=10000
JENKINS_JOB=website-build

curl "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/api/xml?tree=lastBuild\[number\]&xpath=//number/text()" > latest_build
