#!/bin/bash
yell() { echo "$0: $*" >&2;   }
die() { yell "$*"; exit 111;   }
bail() { yell "$*"; exit 0;  }
try() { "$@" || die "cannot $*";   }
just_in_case() { "$@" || true; }

SCRIPT_PATH="../scripts"
BIN_PATH="../build"
DIST="gs://ranl/agglomeration"
THRESHOLD=0.2

#try . /root/google-cloud-sdk/path.bash.inc
just_in_case rm *.dat
just_in_case rm *.bz2
just_in_case rm *.raw
just_in_case rm param.txt
