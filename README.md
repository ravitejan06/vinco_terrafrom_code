# Exchange IAC
## Getting started
This contains Terraform code for both Production and Test environment and how to execute terraform commands.
## Documentation

•	We will be deploying Infrastructure via terraform by making use of an IAM user which we call terraform user. And these users are already created for you in each environment.\
•	The very first step is to configure AWS settings from the terraform command line. This is to create a communication from terraform to a specific account\
o	Run "aws configure" command\
o	Provide the Access Key, Secret Key, and the Region Code of the Specific Account i.e., either Prod or Test account.\
o	The Access Key and Secret Key of both prod and test terraform users are shared via an email.\
•	I have added few local modules to make use of within few layers in order to prevent errors and pushed to the repository already.\
•	The Terraform folder contains folders for both Prod and Test environment and each environment has layers.\
•	The layers are _main, 000base, 100data, 200compute and so on.\
•	Change to the desired directory/layer using cd command.\
•	Run terraform init command to download public modules and provider plug ins. [ Need to run terraform init in each layer ]\
•	If you want to change any account and resource attribute values for example environment, account id, region, vpc cidr, subnet cidrs, subnet names, instance type, db username, password, engine version etc in any layer, kindly edit the values inside terraform.tfvars file and few values can be changed directly inside module/resource block attribute values inside each layer.\
•	Once the required changes are made, you can run terraform plan  and if everything looks fine you can proceed with the terraform apply  command.\
•	Repeat the process for each layer. [Here layers are an individual folder that holds code for resources]\
•	If you are creating a new resource in any of the layer, please input the variables required in variables.tf folder and their values in terraform.tfvars file. Also, please input the outputs that are going to be required in the outputs.tf file, so that other layers can make use of these output values.\
•	A data block must be defined if you are going to access resource ids or its values that are in any other layer into current layer.\
•	If you want to make changes to an AWS resource, just update the new values inside the code and run terraform plan  and terraform apply  commands. This just updates the resource instead of completely destroying it unless it needs to be replaced completely.\
•	If you want to destroy resources in a certain layer, change directory to that particular layer and run terraform destroy command. Be careful when you use destroy command.

NOTE: 1. Please run 200compute layer code before 100data as the SGs of 100data resources has an inbound from 200compute resources.\ 
2. Please read the entire plan whenever you use terraform apply and terraform destroy commands before typing “yes” to see what are being created or what changes are being made.\
3. When you switch from one environment to other environment and want to deploy changes, please run aws configure and enter the credentials[Access Key, Secret Key & region] of that particular account.\
4. Ignore any S3 argument deprecated warning as it doesn’t harm us and still works.



## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://gitlab.com/aurouz-exchange/exchange-iac.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://gitlab.com/aurouz-exchange/exchange-iac/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Automatically merge when pipeline succeeds](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/index.html)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing(SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

