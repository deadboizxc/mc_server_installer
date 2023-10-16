#!/bin/bash

# Функція для виведення тексту кольором
print_color_text() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}\e[0m"
}

# Оновлення системи
clear
print_color_text "Оновлення системи..." "\e[36m"
sleep 1
clear
apt update -y && apt upgrade -y
sleep 1
clear

# Встановлення необхідних пакетів
print_color_text "Встановлення необхідних пакетів..." "\e[36m"
pkg install wget git proot proot-distro openssh -y
sleep 1
clear

# Інструкції для встановлення сервера
print_color_text "Для встановлення сервера потрібно завантажити дистрибутив Linux" "\e[36m"
sleep 1
print_color_text "Для цього потрібно ввести команду: \e[91mproot-install distro\e[0m" "\e[36m"
sleep 1
print_color_text "Приклад встановлення Ubuntu:" "\e[36m"
sleep 1
print_color_text "\e[91mproot-distro install ubuntu\e[0m" "\e[91m"
sleep 1
