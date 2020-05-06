#!/bin/bash

set -e # exit when any command fails

FILE=$1
FIXTURE_FILE=$2

echo "Checking ${FILE} against ${FIXTURE_FILE}…"

cat "${FIXTURE_FILE}" | while IFS=: read key value lowerbound upperbound
do
  NUM=`jq '.features | map(select(.properties.'${key}' == "'${value}'")) | length' ${FILE}`

  echo " → Checking if ${NUM} ${key}=${value} are within range (${lowerbound}‥${upperbound})…"
  ((NUM <= ${lowerbound} || NUM >= ${upperbound})) && exit 1

  continue # Without this, script exits with 1 for some reason
done
