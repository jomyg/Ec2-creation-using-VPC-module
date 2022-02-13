# Ec2-creation-using-VPC-module
Creating EC2 using terraform on custom VPC. The creation of VPC is fully automated and i have setup the VPC provision as a module.

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)]()

## Description:
Amazon Virtual Private Cloud (Amazon VPC) enables you to launch Amazon Web Services resources into a virtual network you've defined. This virtual network resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

A Terraform module is a collection of standard configuration files in a dedicated directory. Terraform modules encapsulate groups of resources dedicated to one task, reducing the amount of code you have to develop for similar infrastructure components.

## Pre-requisites:

1) IAM Role (Role needs to be attached on terraform running server)
2) Basic knowledge about AWS services especially VPC, EC2 and IP Subnetting.
3) Terraform and its installation.

> Click here to [download](https://www.terraform.io/downloads.html) and  [install](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started) terraform.

Installation steps I followed:
```sh
wget https://releases.hashicorp.com/terraform/0.15.3/terraform_0.15.3_linux_amd64.zip
unzip terraform_0.15.3_linux_amd64.zip 
ls 
terraform  terraform_0.15.3_linux_amd64.zip    
mv terraform /usr/bin/
which terraform 
/usr/bin/terraform
```
