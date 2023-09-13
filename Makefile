tf_base = terraform -chdir=./terraform
tf_secrets_file = terraform/linode.secrets.auto.tfvars
vault_pass_file = .vault_pass

tf-secrets-encrypt:
	@ansible-vault encrypt $(tf_secrets_file) --vault-password-file $(vault_pass_file)

tf-secrets-decrypt:
	@ansible-vault decrypt $(tf_secrets_file) --vault-password-file $(vault_pass_file)

tf-init:
	@$(tf_base) init

tf-apply:
	$(tf_base) apply

tf-fmt:
	@$(tf_base) fmt

tf-output:
	@$(tf_base) output -json