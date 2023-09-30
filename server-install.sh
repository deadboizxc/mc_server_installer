#!/bin/bash

SERVER_DIR=mc_server

# Проверка на существование папки mc_server
if [ ! -d "$HOME/$SERVER_DIR" ]; then
    mkdir "$HOME/$SERVER_DIR"
fi

# Функция для вывода текста цветом
print_color_text() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}\e[0m"
}

# Обновление системы
clear
print_color_text "Обновление системы..." "\e[36m"
apt update && apt upgrade -y
sleep 1
clear

# Установка OpenJDK и wget
print_color_text "Установка OpenJDK и wget..." "\e[36m"
apt install openjdk-17-jdk wget jq nano -y
sleep 1
clear

# Запрос пользователя о скачивании ngrok
echo -n -e "\e[36mХотите скачать и установить ngrok? (yes/no/y/n): \e[0m" && read download_ngrok

# Проверка ответа пользователя и установка ngrok при необходимости
if [ "$download_ngrok" == "yes" ] || [ "$download_ngrok" == "y" ]; then
    # Проверка на существование ссылки на ngrok
    if ! wget --spider https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz 2>/dev/null; then
        print_color_text "Ссылка на ngrok не доступна." "\e[31m"
        exit 1
    fi
    # Если ссылка на ngrok доступна, то можно скачать и установить ngrok
    print_color_text "Скачивание и установка ngrok..." "\e[36m"
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
    tar xvzf ngrok-v3-stable-linux-arm64.tgz -C /usr/local/bin
fi
sleep 1
clear


# Загрузка JSON-файла с информацией о версиях Minecraft
print_color_text "Загрузка информации о версиях Minecraft..." "\e[36m"
version_info=$(curl -s https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/8999ab98f5779901780c3ef7a3f8b7b86a7e4281/paper-versions.json)

# Проверка на наличие ошибок при загрузке JSON
if [ $? -ne 0 ]; then
    print_color_text "Ошибка при загрузке информации о версиях Minecraft." "\e[31m"
    exit 1
fi
sleep 1

# Вывод доступных версий Minecraft
print_color_text "Доступные версии Minecraft:" "\e[36m" # Используйте "\e[0m" для желтого цвета
jq -r '.versions | keys[]' <<< "$version_info" | while IFS= read -r version; do
  print_color_text "$version" "\e[32m"
done

# Запрос пользователя для выбора версии
echo -n -e "\e[36mВыберите версию Minecraft для установки: \e[91m" && read minecraft_version

# Проверка, существует ли выбранная версия в списке доступных версий
if ! jq -r --arg ver "$minecraft_version" '.versions | keys[] | select(. == $ver)' <<< "$version_info" >/dev/null; then
    print_color_text "Выбранная версия не найдена." "\e[31m"
    exit 1
fi



# URL для выбранной версии Minecraft
minecraft_url=$(jq -r --arg ver "$minecraft_version" '.versions[$ver]' <<< "$version_info")
# Проверка наличия URL
if [ -z "$minecraft_url" ]; then
    print_color_text "Выбранная версия не найдена." "\e[31m"
    exit 1
fi
sleep 1
clear


# Загрузка выбранной версии Minecraft
print_color_text "Загрузка Minecraft версии $minecraft_version..." "\e[36m"
if ! wget -O $HOME/$SERVER_DIR/server.jar "$minecraft_url"; then
    print_color_text "Ошибка при загрузке сервера Minecraft." "\e[31m"
    exit 1
fi

# Создание файла eula.txt
echo "eula=true" > $HOME/$SERVER_DIR/eula.txt
sleep 1
clear

# Инструкции для запуска сервера
print_color_text "Для запуска сервера выполните следующую команду:" "\e[36m"
print_color_text "java -jar $HOME/$SERVER_DIR/server.jar" "\e[91m"
