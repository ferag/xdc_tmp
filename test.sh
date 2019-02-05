#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
echo miau > test.txt
exec oneclient --authentication token --no_check_certificate ./datasets
exec tini -g -- start-notebook.sh --ip="0.0.0.0" --port=8888
