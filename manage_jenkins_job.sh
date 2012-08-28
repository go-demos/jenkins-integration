#!/bin/bash

JENKINS_HOST=localhost
JENKINS_PORT=10000
JENKINS_JOB=website-build
offset=0
console=""

function latest_job {
    JENKINS_LATEST_JOB=`curl -s "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/api/xml?tree=lastBuild\[number\]&xpath=//number/text()"`
}

function jenkins_job_instance {
    curl -s "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/$1/api/xml?tree=$2&xpath=$3"
}

function is_building {
    is_building=`jenkins_job_instance $1 "building" "//building/text()"`
}

function print_console {
    console=`curl -s "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/$JENKINS_LATEST_JOB/logText/progressiveText"`
    echo "$console"
}

function wait_to_complete {
    is_building $JENKINS_LATEST_JOB
    while [ "$is_building" !=  "false" ]
    do
        is_building $JENKINS_LATEST_JOB
    done
}

function wait_for_build_to_trigger {
    expected=`expr $JENKINS_LATEST_JOB + 1`
    is_building $expected
    while [ "$is_building" !=  "true" ]
    do
        is_building $expected
    done
    latest_job
}

function result {
    result=`jenkins_job_instance $JENKINS_LATEST_JOB "result" "//result/text()"`
    echo $result
}

function evaluate_result {
    if [ "$result" == "SUCCESS" ]; then
        exit 0
    elif [ "$result" == "FAILURE" ]; then
        exit 1
    fi
}

function download_artifacts {
    curl -s "http://$JENKINS_HOST:$JENKINS_PORT/job/$JENKINS_JOB/$JENKINS_LATEST_JOB/artifact/*zip*/archive.zip" > archive.zip
    mkdir artifacts
    mv archive.zip artifacts
    cd artifacts
    unzip archive.zip
    rm archive.zip
}

function clean_up {
    rm -rf artifacts
}

function trigger_jenkins {
    curl -s -d "revision=$GO_REVISION_MATERIAL" "http://localhost:10000/job/$JENKINS_JOB/buildWithParameters"
}

clean_up
latest_job
trigger_jenkins
wait_for_build_to_trigger
wait_to_complete
print_console
download_artifacts
result
evaluate_result