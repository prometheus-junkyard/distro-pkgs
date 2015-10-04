#!/usr/bin/env bash

# Copyright 2015 The Prometheus Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

version=$1
os=$2
arch=$3

base_url=https://github.com/prometheus/prometheus/releases/download
base_dir=$( cd "$(dirname "$0")" && pwd )/prometheus

echo $base_dir

build() {
  version=$1
  os=$2
  arch=$3

  cd $base_dir
  src_dir=$base_dir/source/v$version

  rm -rf prometheus/source/v$version

  mkdir -p $base_dir/builds
  mkdir -p $src_dir

  cd $src_dir

  curl -L $base_url/$version/prometheus-$version.$os-$arch.tar.gz | tar -xzv --strip 1

  cd $base_dir

  # If the package files already exist, fpm will fail.
  rm -f builds/prometheus_0.16.0rc2_amd64.deb
  rm -f builds/prometheus-0.16.0rc2-1.x86_64.rpm

  fpm -s dir -t deb -p builds \
  -a $arch \
  -v $version \
  --name 'prometheus' \
  --license "Apache Software License 2.0" \
  --maintainer "Fabian Reinartz <fabian@soundcloud.com>" \
  $src_dir/prometheus=/usr/bin/prometheus \
  $src_dir/promtool=/usr/bin/promtool


  fpm -s dir -t rpm -p builds \
  --rpm-os linux \
  -a $( echo $arch | sed -e 's/amd64/x86_64/' ) \
  -v $version \
  --name 'prometheus' \
  --license "Apache Software License 2.0" \
  --maintainer "Fabian Reinartz <fabian@soundcloud.com>" \
  $src_dir/prometheus=/usr/bin/prometheus \
  $src_dir/promtool=/usr/bin/promtool
}

build $version $os $arch