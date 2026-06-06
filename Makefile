.PHONY: tf-init tf-plan tf-apply tf-destroy ansible-ping install setup deploy

# === Terraform ===
tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply -auto-approve

tf-destroy:
	cd terraform && terraform destroy

# === Ansible ===
# Пинг серверов для проверки доступности
ansible-ping:
	cd ansible && ansible all -i inventory.ini -m ping

# Установка ролей и коллекций из Ansible Galaxy
install:
	cd ansible && ansible-galaxy install -r requirements.yml
	cd ansible && ansible-galaxy collection install -r requirements.yml

# Запуск подготовки серверов (установка pip и docker через скачанные роли)
setup:
	cd ansible && ansible-playbook -i inventory.ini playbook.yml --tags setup

# Деплой приложения (запускает только базу и редмайн)
deploy:
	cd ansible && ansible-playbook -i inventory.ini playbook.yml --tags deploy
