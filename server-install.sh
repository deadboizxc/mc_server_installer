#!/bin/bash

SERVER_DIR=mc_server

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

# Вибір ядра сервера Minecraft
print_color_text "Виберіть ядро сервера Minecraft:" "\e[36m"
print_color_text "1. Paper" "\e[32m"
print_color_text "2. Purpur" "\e[32m"
echo -n -e "\e[36mВаш вибір (1/2): \e[91m" && read server_core
sleep 1
clear

# Перевірка на існування теки mc_server
if [ ! -d "$HOME/$SERVER_DIR" ]; then
    mkdir "$HOME/$SERVER_DIR"
fi

# Перевірка вибору ядра сервера
case $server_core in
  1)
    server_core_name="Paper"
    server_core_url="https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/8999ab98f5779901780c3ef7a3f8b7b86a7e4281/paper-versions.json"

    print_color_text "Завантаження інформації про версії сервера $server_core_name..." "\e[36m"
    version_info=$(curl -s "$server_core_url")
    if [ $? -ne 0 ]; then
        print_color_text "Помилка при завантаженні інформації про версії сервера." "\e[31m"
        exit 1
    fi
    sleep 1
    clear
    print_color_text "Доступні версії Minecraft для ядра $server_core_name:" "\e[36m"
    jq -r '.versions | keys[]' <<< "$version_info" | while IFS= read -r version; do
        print_color_text "$version" "\e[32m"
    done
    echo -n -e "\e[36mВиберіть версію Minecraft для встановлення: \e[91m" && read minecraft_version
    if ! jq -r --arg ver "$minecraft_version" '.versions | keys[] | select(. == $ver)' <<< "$version_info" >/dev/null; then
        print_color_text "Обрана версія не знайдена." "\e[31m"
        exit 1
    fi
    minecraft_url=$(jq -r --arg ver "$minecraft_version" '.versions[$ver]' <<< "$version_info")
    if [ -z "$minecraft_url" ]; then
        print_color_text "Обрана версія не знайдена." "\e[31m"
        exit 1
    fi
    sleep 1
    clear
    print_color_text "Завантаження Minecraft версії $minecraft_version з ядром $server_core_name..." "\e[36m"
    if ! wget -O "$HOME/$SERVER_DIR/server.jar" "$minecraft_url"; then
        print_color_text "Помилка при завантаженні сервера Minecraft." "\e[31m"
        exit 1
    fi
    ;;

  2)
    server_core_name="Purpur"
    # Завантаження і вивід версій Purpur
    url='https://api.purpurmc.org/v2/purpur'
    response=$(curl -s "$url")

    if [ $? -eq 0 ]; then
        print_color_text "Завантаження інформації про версії сервера $server_core_name..." "\e[36m"
        sleep 1
        print_color_text "Доступні версії Minecraft для ядра $server_core_name:" "\e[36m"
        while IFS= read -r version; do
            print_color_text "$version" "\e[32m"
        done <<< $(echo "$response" | jq -r '.versions[]')
    else
        print_color_text "Помилка при запиті: $?" "\e[31m"
        exit 1
    fi

    # Запит версії Purpur
    echo -n -e "\e[36mВиберіть версію Minecraft для встановлення: \e[91m" && read minecraft_version

    # Завантаження ядра Purpur
    purpur_url="https://api.purpurmc.org/v2/purpur/$minecraft_version/latest/download"
    clear

    print_color_text "Завантаження версії $minecraft_version Purpur..." "\e[36m"
    if ! wget -O "$HOME/$SERVER_DIR/server.jar" "$purpur_url"; then
        print_color_text "Помилка при завантаженні сервера Minecraft." "\e[31m"
        exit 1
    fi
    ;;

  *)
    print_color_text "Недійсний вибір ядра сервера." "\e[31m"
    exit 1
    ;;
esac


# Створення файлу eula.txt
echo "eula=true" > $HOME/$SERVER_DIR/eula.txt
sleep 1
clear

# Інструкції для запуску сервера
print_color_text "Для запуску сервера виконайте наступну команду:" "\e[36m"
print_color_text "java -jar $HOME/$SERVER_DIR/server.jar" "\e[91m"
