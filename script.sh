#!/bin/sh
# Copyright 2020 University Of Helsinki (The National Library Of Finland)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

if test -z "${PLUGIN_TAG_PATTERN}";then
  echo 'Setting tag_pattern is mandatory'
  exit 1
fi

echo "Cloning upstream repository"
git clone -q https://github.com/oracle/node-oracledb repo
cd repo

TAG=`git tag -l ${PLUGIN_TAG_PATTERN}|grep -E '^v[0-9\.]+$'|sort -r|head -n1`

echo "Checking out tag ${TAG}"
git checkout -q $TAG

PACKAGE_VERSION=`node -e 'console.log(require("./package").version)'`

if test ${PACKAGE_VERSION} = `npm info @natlibfi/oracledb-aleph version`;then
  echo 'No changes in upstream, exiting.'
  exit 0
fi

echo "Cloning submodules"
git clone -b main --depth=1 https://github.com/oracle/odpi odpi

echo "Applying patches"
patch -p0 < ../fix-name.patch
patch -p0 < ../fix-charset.patch

