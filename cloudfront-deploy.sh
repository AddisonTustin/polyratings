#!/bin/bash

# This file *should* automatically deploy the frontend build artifacts to a specified
# AWS Cloudfront Distribution

export AWS_PAGER=""

CURRENT_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
CURRENT_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

aws sts assume-role --role-arn $ROLE_ARN --role-session-name manual-cli-test > sts-output
ROLE_ACCESS_KEY_ID=$(cat sts-output | sed -n 's/\s*"AccessKeyId": "\([a-zA-Z0-9]*\)",.*/\1/p')
ROLE_SECRET_ACCESS_KEY=$(cat sts-output | sed -n 's/\s\+"SecretAccessKey": "\(.\+\)",\s*/\1/p')
ROLE_SESSION_TOKEN=$(cat sts-output | sed -n 's/\s\+"SessionToken": "\(.\+\)",\s*/\1/p')

export AWS_ACCESS_KEY_ID=$ROLE_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROLE_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROLE_SESSION_TOKEN

# aws s3 sync --delete ./packages/frontend/dist/ s3://$POLYRATINGS_S3_URI
aws s3 sync packages/frontend/dist/ s3://$POLYRATINGS_S3_URI --exclude "*.js" --delete
aws s3 sync packages/frontend/dist/ s3://$POLYRATINGS_S3_URI --exclude "*" --include "*.js" --no-guess-mime-type --content-type "application/javascript"
aws --output text cloudfront create-invalidation --distribution-id $POLYRATINGS_DISTRIBUTION_ID --paths "/*"
