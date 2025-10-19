# Ansible Static Server

Этот проект разворачивает сервер для раздачи статики (изображений) через **nginx** с помощью **Ansible**.  
Статика скачивается с Google Drive, пользователи и SSH настраиваются через Ansible роли.

---

## Содержание

- `– Dockerfile`  
- `– docker-compose.yml`
- `roles/` – Ansible роли:
  - `users` – управление пользователями и группами
  - `zsh_ohmyzsh` – установка Zsh и Oh My Zsh
  - `ssh_hardening` – жесткая настройка SSH
  - `packages` – установка утилит (htop, ncdu, git, nano)
  - `nginx` – установка и настройка nginx
  - `deploy_static` – скачивание и размещение статики
- `vars/users.yaml` – пример vars для пользователей  
- `inventory.ini` – пример inventory для локального контейнера  
- `site.yml` – основной playbook  


## Шаги для запуска на Mac

### 1. Собираем и поднимаем Docker контейнер

```bash
docker compose down -v
docker compose up -d --build
```
Контейнер будет слушать:
	•	SSH: 127.0.0.1:2222
	•	HTTP: 127.0.0.1:8080 (или 80, если свободен)

### 2. Настраиваем known_hosts (при пересоздании контейнера)

```bash
ssh-keygen -R "[127.0.0.1]:2222"
```

### 3. Проверяем доступ по SSH

```bash
ssh tester@127.0.0.1 -p 2222
```

### 4. Проверяем Ansible-подключение

```bash
ansible all -i inventory.ini -m ping
```
Должно вернуть pong. 

### 5. Запускаем playbook

```bash
ansible-playbook -i inventory.ini site.yml
```
Роли создадут пользователей, настроят SSH, установят утилиты, nginx и разместят статику. 

### 6. Проверяем статику

Список файлов:
```bash
curl http://127.0.0.1:8080/images/
```

Отдельный файл:
```bash
curl http://127.0.0.1:8080/images/1419136.svg --output test.svg
```

### 7. Логи nginx

```bash
docker exec -it <container_name> tail -f /var/log/nginx/access.log
```

### Примечания:
	•	В Ansible inventory уже настроены параметры для отключения строгой проверки ключей SSH (StrictHostKeyChecking=no)
	•	Для обновления статики playbook можно запускать повторно — роли идемпотентны
	•	При смене контейнера Docker старые SSH-ключи нужно удалять из ~/.ssh/known_hosts