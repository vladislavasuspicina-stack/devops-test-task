# Загрузка на GitHub

## Подготовка

1. Убедитесь, что у вас установлен Git:
   ```bash
   git --version
   ```

2. Создайте аккаунт на [github.com](https://github.com) если его еще нет

## Создание репозитория на GitHub

1. Перейдите на [github.com](https://github.com)
2. Нажмите кнопку **"+" → "New repository"** в верхнем правом углу
3. Задайте параметры:
   - **Repository name:** `devops-test-task`
   - **Description:** DevOps Test Task - Docker and Nginx setup
   - **Public** (публичный репозиторий)
   - Оставьте остальные параметры по умолчанию
   - **НЕ** инициализируйте с README (у нас он уже есть)
4. Нажмите **"Create repository"**

## Загрузка локального репозитория

После создания репозитория на GitHub вы увидите инструкции. Выполните следующие команды в папке проекта:

### Вариант 1: Если вы клонировали этот проект

```bash
cd devops-test-task
git remote add origin https://github.com/YOUR_USERNAME/devops-test-task.git
git branch -M main
git push -u origin main
```

### Вариант 2: Если вы создавали проект вручную

```bash
cd devops-test-task
git remote add origin https://github.com/YOUR_USERNAME/devops-test-task.git
git branch -M main
git push -u origin main
```

## Замените YOUR_USERNAME на ваше имя пользователя GitHub

Например, если ваше имя `john-doe`, то:
```bash
git remote add origin https://github.com/john-doe/devops-test-task.git
```

## Проверка загрузки

После выполнения команды `git push`, перейдите на страницу репозитория:
```
https://github.com/YOUR_USERNAME/devops-test-task
```

Вы должны увидеть все файлы проекта на GitHub.

## Настройка SSH для GitHub (опционально, но рекомендуется)

Для удобства можно настроить SSH:

1. Генерируйте SSH ключ:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Добавьте публичный ключ в GitHub:
   - Перейдите в Settings → SSH and GPG keys → New SSH key
   - Давайте файл `~/.ssh/id_ed25519.pub` (含容 публичного ключа)
   - Укажите название (например, "My Computer")

3. Используйте SSH URL вместо HTTPS:
   ```bash
   git remote add origin git@github.com:YOUR_USERNAME/devops-test-task.git
   ```

## Убедитесь в корректности URL

Проверьте, что remote настроен правильно:
```bash
git remote -v
```

Вывод должен быть похож на:
```
origin  https://github.com/YOUR_USERNAME/devops-test-task.git (fetch)
origin  https://github.com/YOUR_USERNAME/devops-test-task.git (push)
```

Или для SSH:
```
origin  git@github.com:YOUR_USERNAME/devops-test-task.git (fetch)
origin  git@github.com:YOUR_USERNAME/devops-test-task.git (push)
```

## Дальнейшие коммиты

После первой загрузки, для дальнейших изменений просто используйте:
```bash
git add .
git commit -m "описание изменений"
git push
```

## Финальное требование

Убедитесь, что репозиторий **публичный** и доступен по адресу:
```
https://github.com/YOUR_USERNAME/devops-test-task
```

Скопируйте эту ссылку и предоставьте ее при сдаче задания.
