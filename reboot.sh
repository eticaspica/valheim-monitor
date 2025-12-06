#!/bin/bash

cp -p valheim.log ./log/loginlog.log.`ls -l ./log/ | wc -l`
nohup ./loginlog.sh > loginlog.log 2>&1 & echo $! > loginlog.pid