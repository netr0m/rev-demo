#!/usr/bin/env bash

# clone from git
git clone https://github.com/NREL/reV.git rev-src

# set up conda (virtual environment)
conda create -n rev-test python=3.8
conda activate rev-test

# enter the source code directory for rev
cd rev-src
# install reV
pip install -e .

# verify that reV was installed successfully
python3 -c 'import reV'