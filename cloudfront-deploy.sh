#!/bin/bash

# This file *should* automatically deploy the frontend build artifacts to a specified
# AWS Cloudfront Distribution

# If we don't set this, the aws cli calls will use 'less' and the script will hang
export AWS_PAGER=""

aws sts assume-role --role-arn $ROLE_ARN --role-session-name manual-cli-test > sts-output

# Extracts the AWS Credentials from the response
export AWS_ACCESS_KEY_ID=$ROLE_ACCESS_KEY_ID=$(cat sts-output | sed -n 's/\s*"AccessKeyId": "\([a-zA-Z0-9]*\)",.*/\1/p')
export AWS_SECRET_ACCESS_KEY=$ROLE_SECRET_ACCESS_KEY=$(cat sts-output | sed -n 's/\s\+"SecretAccessKey": "\(.\+\)",\s*/\1/p')
export AWS_SESSION_TOKEN=$ROLE_SESSION_TOKEN=$(cat sts-output | sed -n 's/\s\+"SessionToken": "\(.\+\)",\s*/\1/p')

aws s3 sync --delete ./packages/frontend/dist/ s3://$POLYRATINGS_S3_URI
aws --output text cloudfront create-invalidation --distribution-id $POLYRATINGS_DISTRIBUTION_ID --paths "/*"
