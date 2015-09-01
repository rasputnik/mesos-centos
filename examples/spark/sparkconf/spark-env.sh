#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

# mesos
# set MESOS_NATIVE_JAVA_LIBRARY for the spark shell
# - it's already set (as an env. var) in our docker image.
export MESOS_NATIVE_JAVA_LIBRARY=/usr/local/Cellar/mesos/0.22.1/lib/libmesos.dylib
