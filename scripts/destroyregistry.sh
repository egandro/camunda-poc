#!/bin/sh
set -o errexit

reg_name='kind-registry'

docker rm -f ${reg_name} || true
