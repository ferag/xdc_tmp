#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
#echo miau > test.txt
#sudo su
#tini -g -- start-notebook.sh --ip="0.0.0.0" --port=8888
echo $(whoami)
echo "test"
exec su - "jovyan"
echo $(whoami)

# to not overwrite the entrypoint of the jupyter/base-notebook
# see https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
tini -g -- start-notebook.sh --ip="0.0.0.0" --port=8888
