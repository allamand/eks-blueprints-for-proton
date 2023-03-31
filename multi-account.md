# Multi-Account setup for AWS Proton

1. Create the AWSProtonCodeBuileProvisioning IAM Role
2. Create the secret github-blueprint-ssh-key

Add access to Account A s3 bucket in AWSProtonCodeBuildProvision role in Account B

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME_FOR_TERRAFORM_IN_ACCOUNT_A/*"
        }
    ]
}
```

In AccountA S3 bucket, add the Bucket Policy to authorize the cross-account access

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::ACCOUNT_B:role/AWSProtonCodeBuildProvisioning"
			},
			"Action": [
				"s3:*"
			],
			"Resource": "arn:aws:s3:::BUCKET_NAME_FOR_TERRAFORM_IN_ACCOUNT_A"
		}
	]
}
```

## Using deployment with CodeBuild

### Troubleshooting

#### Check the Sync status of your template

This command will show you the status of the template synchronisation.
```
aws proton get-template-sync-status --template-name eks-blueprint-codebuild --template-type SERVICE --template-version 1  
```

#### Assuming Proton Code Build Role in Account B

Uses this command to assume the AWSProtonCodeBuildProvisioning in your account (you may need to edit it's Trust relationships to allow you to assume that role)

```
export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::${ACCOUNT_ID}:role/AWSProtonCodeBuildProvisioning \
--role-session-name MySessionName \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))
```

you should hve something like this:

```
aws sts get-caller-identity
{
    "UserId": "AROAUD5VMKW7QAGD6RJM7:MySessionName",
    "Account": "ACCOUNT_B",
    "Arn": "arn:aws:sts::ACCOUNT_B:assumed-role/AWSProtonCodeBuildProvisioning/MySessionName"
}
```

#### Test access to the Account A Bucket S3

---

arn:aws:iam::382076407153:role/AWSProtonCodeBuildProvisioning

aws iam list-roles --query "Roles[?RoleName == 'AWSProtonCodeBuildProvisioning'].[RoleName, Arn]"

aws sts assume-role --role-arn "arn:aws:iam::382076407153:role/AWSProtonCodeBuildProvisioning" --role-session-name AWSProtonRole

export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::382076407153:role/AWSProtonCodeBuildProvisioning \
--role-session-name MySessionName \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))

Cross Account Proton Access
arn:aws:iam::283311363519:role/AWSProtonCodeBuildProvisioning

provide access to the bucket s3 to the proton RoleName

{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject",
"s3:PutObjectAcl"
],
"Resource": "arn:aws:s3:::aws-proton-terraform-bucket-382076407153/\*"

        }
    ]

}

Configure the bucket Policy for Account A to grand persmission to the IAM role in Account B

{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"AWS": "arn:aws:iam::283311363519:role/AWSProtonCodeBuildProvisioning"
},
"Action": [
"s3:GetObject",
"s3:PutObject",
"s3:PutObjectAcl"
],
"Resource": [
"arn:aws:s3:::aws-proton-terraform-bucket-382076407153/*"
]
}
]
}
