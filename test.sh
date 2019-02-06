#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
echo miau > test.txt
tini -g -- start-notebook.sh --ip="0.0.0.0" --port=8888 ; oneclient --authentication token --no_check_certificate ./datasets
