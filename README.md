### Hexlet tests and linter status:
[![Actions Status](https://github.com/tofuoverdose/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/tofuoverdose/devops-for-programmers-project-77/actions)

### Before starting
Install the required dependencies:
- Ansible
- Terraform

Obtain vault password and put it in `.vault_pass` in root folder of the project.

### Working with terraform
Terraform Cloud is used for storing the state remotely. Before changing the infrastructure, login in Terraform Cloud with token:
```shell
terraform login
```

Initialize Terraform project afterwards:
```shell
make tf-init
```

```shell
make tf-apply
```