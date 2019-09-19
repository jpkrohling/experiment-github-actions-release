#!/bin/bash

make build
RT=$?
if [ ${RT} != 0 ]; then
    echo "Failed to build."
    exit ${RT}
fi
