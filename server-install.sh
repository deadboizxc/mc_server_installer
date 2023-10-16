#!/bin/bash

SERVER_DIR=mc_server

# Перевірка на існування теки mc_server
if [ ! -d "$HOME/$SERVER_DIR" ]; then
    mkdir "$HOME/$SERVER_DIR"
fi

# Функція для виведення тексту кольором
print_color_text() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}\e[0m"
}

# Оновлення системи
clear
print_color_text "Оновлення системи..." "\e[36m"
apt update && apt upgrade -y
sleep 1
clear

# Встановлення OpenJDK та wget
print_color_text "Встановлення OpenJDK та wget..." "\e[36m"
apt install openjdk-17-jdk wget jq nano -y
sleep 1
clear

# Запит користувача щодо завантаження ngrok
echo -n -e "\e[36mХочете завантажити та встановити ngrok? (yes/no/y/n): \e[0m" && read download_ngrok

# Перевірка відповіді користувача та встановлення ngrok за необхідності
if [ "$download_ngrok" == "yes" ] || [ "$download_ngrok" == "y" ]; then
    # Перевірка на існування посилання на ngrok
    if ! wget --spider https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz 2>/dev/null; then
        print_color_text "Посилання на ngrok недоступне." "\e[31m"
        exit 1
    fi
    # Якщо посилання на ngrok доступне, то можна завантажити та встановити ngrok
    print_color_text "Завантаження та встановлення ngrok..." "\e[36m"
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
    tar xvzf ngrok-v3-stable-linux-arm64.tgz -C /usr/local/bin
fi
sleep 1
clear

# Завантаження JSON-файлу з інформацією про версії Minecraft
print_color_text "Завантаження інформації про версії Minecraft..." "\e[36m"
version_info=$(curl -s https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/8999ab98f5779901780c3ef7a3f8b7b86a7e4281/paper-versions.json)

# Перевірка на наявність помилок при завантаженні JSON
if [ $? -ne 0 ]; then
    print_color_text "Помилка при завантаженні інформації про версії Minecraft." "\e[31m"
    exit 1
fi
sleep 1

# Виведення доступних версій Minecraft
print_color_text "Доступні версії Minecraft:" "\e[36m" # Використовуйте "\e[0m" для жовтого кольору
jq -r '.versions | keys[]' <<< "$version_info" | while IFS= read -r version; do
  print_color_text "$version" "\e[32m"
done

# Запит користувача для вибору версії
echo -n -e "\e[36mВиберіть версію Minecraft для встановлення: \e[91m" && read minecraft_version

# Перевірка, чи існує обрана версія в списку доступних версій
if ! jq -r --arg ver "$minecraft_version" '.versions | keys[] | select(. == $ver)' <<< "$version_info" >/dev/null; then
    print_color_text "Обрана версія не знайдена." "\e[31m"
    exit 1
fi

# URL для обраної версії Minecraft
minecraft_url=$(jq -r --arg ver "$minecraft_version" '.versions[$ver]' <<< "$version_info")

# Перевірка наявності URL
if [ -z "$minecraft_url" ]; then
    print_color_text "Обрана версія не знайдена." "\e[31m"
    exit 1
fi
sleep 1
clear

# Завантаження обраної версії Minecraft
print_color_text "Завантаження Minecraft версії $minecraft_version..." "\e[36m"
if ! wget -O $HOME/$SERVER_DIR/server.jar "$minecraft_url"; then
    print_color_text "Помилка при завантаженні сервера Minecraft." "\e[31m"
    exit 1
fi

# Створення файлу eula.txt
echo "eula=true" > $HOME/$SERVER_DIR/eula.txt
sleep 1
clear

# Інструкції для запуску сервера
print_color_text "Для запуску сервера виконайте наступну команду:" "\e[36m"
print_color_text "java -jar $HOME/$SERVER_DIR/server.jar" "\e[91m"
