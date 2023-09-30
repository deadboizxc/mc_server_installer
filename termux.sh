#!/bin/bash

# Функция для вывода текста цветом
print_color_text() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}\e[0m"
}

# Обновление системы
clear
print_color_text "Обновление системы..." "\e[36m"
sleep 1
clear
apt update -y && apt upgrade -y
sleep 1
clear

# Установка необходимых пакетов
print_color_text "Установка необходимых пакетов..." "\e[36m"
pkg install wget git proot proot-distro openssh -y
sleep 1
clear

# Инструкции для установки сервера
print_color_text "Для установки сервера нужно скачать дистрибьютив Linux" "\e[36m"
sleep 1
print_color_text "Для этого нуджно ввести команду: \e[91mproot-install distro\e[0m" "\e[36m"
sleep 1
print_color_text "Пример установки Ubuntu:" "\e[36m"
sleep 1
print_color_text "\e[91mproot-distro install ubuntu\e[0m" "\e[91m"
sleep 1

