#!/bin/bash

cat <<EOF >./properties.txt
AWS_REGION=$AWS_REGION
AWS_ACCOUNT=$AWS_ACCOUNT
AWS_PROFILE=$AWS_PROFILE
XILUTION_ENVIRONMENT=$XILUTION_ENVIRONMENT
XILUTION_ORGANIZATION_ID=$XILUTION_ORGANIZATION_ID
EOF
