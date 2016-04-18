#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

# mesos
export MESOS_NATIVE_JAVA_LIBRARY=/usr/local/Cellar/mesos/0.28.0/lib/libmesos.dylib
