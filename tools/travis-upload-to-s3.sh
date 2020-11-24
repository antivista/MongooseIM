#!/bin/bash

source tools/travis-helpers.sh

set -euo pipefail

CT_REPORTS=$(ct_reports_dir)

if [ ! -d "${CT_REPORTS}" ]; then
    echo "Skip uploading, because $CT_REPORTS directory does not exist"
    exit 0
fi

echo "Uploading test results to s3"
echo $(s3_url ${CT_REPORTS})

FILE_COUNT=$(find "${CT_REPORTS}" -type f | wc -l)
echo "Uploading $FILE_COUNT files"

AWS_BUCKET="${AWS_BUCKET:-mongooseim-ct-results}"

aws configure set default.s3.max_concurrent_requests 64

time aws s3 cp ${CT_REPORTS} s3://${AWS_BUCKET}/${CT_REPORTS} --acl public-read --recursive --quiet
