#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
echo miau > test.txt
sudo chown -R jovyan:users /home/jovyan/.local/share/jupyter
sudo chown -R jovyan:users /home/jovyan/datasets
whoami
su root
whoami
sudo -u jovyan oneclient --authentication token --no_check_certificate ./datasets
tini -g -- start-notebook.sh --ip="0.0.0.0" --port=8888
