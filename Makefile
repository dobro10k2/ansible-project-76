.PHONY: tf-init tf-plan tf-apply tf-destroy tf-fmt tf-lint \
        ansible-ping install setup deploy vault-encrypt vault-decrypt vault-edit \
        ansible-lint ansible-fix

# === Terraform ===
tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply -auto-approve

tf-destroy:
	cd terraform && terraform destroy

# Автоматическое исправление форматирования кода Terraform
tf-fmt:
	cd terraform && terraform fmt

# Проверка синтаксиса и форматирования кода Terraform
tf-lint:
	cd terraform && terraform fmt -check
	cd terraform && terraform validate

# === Ansible ===
# Пинг серверов для проверки доступности
ansible-ping:
	ansible all -i inventory.ini -m ping

# Установка ролей и коллекций из Ansible Galaxy
install:
	ansible-galaxy install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml

# --- Команды Ansible Vault ---
vault-encrypt:
	ansible-vault encrypt ansible/group_vars/webservers/vault.yml --vault-password-file .vault_pass

vault-decrypt:
	ansible-vault decrypt ansible/group_vars/webservers/vault.yml --vault-password-file .vault_pass

vault-edit:
	ansible-vault edit ansible/group_vars/webservers/vault.yml --vault-password-file .vault_pass
# -----------------------------

# Запуск подготовки серверов (установка pip и docker через скачанные роли)
setup:
	ansible-playbook -i inventory.ini playbook.yml --tags setup --vault-password-file .vault_pass

# Деплой приложения (запускает только базу и редмайн)
deploy:
	ansible-playbook -i inventory.ini playbook.yml --tags deploy --vault-password-file .vault_pass

# Запуск линтера кода Ansible
ansible-lint:
	ansible-lint playbook.yml ansible/playbook.yml ansible/group_vars/

# Автоматическое исправление некоторых ошибок стиля и правил в Ansible
ansible-fix:
	ansible-lint --write playbook.yml ansible/playbook.yml ansible/group_vars/
