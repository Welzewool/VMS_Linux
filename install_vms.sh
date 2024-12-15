#!/bin/bash

# Проверка запуска от имени root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать с правами суперпользователя (sudo)."
   exit 1
fi

# Проверка наличия файла установки
INSTALLER="VMS_1_0_0_20150820_install.run"
if [[ ! -f "$INSTALLER" ]]; then
    echo "Файл $INSTALLER не найден. Убедитесь, что он находится в той же директории, что и скрипт."
    exit 1
fi

# Обновление системы
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# Установка необходимых зависимостей
echo "Установка зависимостей..."
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y libqt5opengl5:i386 libxrender1:i386

# Присвоение прав на выполнение установочного файла
chmod +x "$INSTALLER"

# Запуск установочного файла
echo "Запуск установочного файла..."
./"$INSTALLER"

# Настройка прав и исправление библиотеки
echo "Настройка прав доступа..."
chmod 777 -R /opt/VMS
mv /opt/VMS/libxcb.so.1 /opt/VMS/libxcb.so.1.old

# Создание ярлыков
DESKTOP_FILE="VMS.desktop"
cat > "$DESKTOP_FILE" <<EOL
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Icon=/opt/VMS/icon.xpm
Name=VMS
Exec=/opt/VMS/VMS.sh
Comment=VMS
Categories=Application;Internet;Network;
EOL

# Копирование ярлыка на рабочий стол и в системное меню
echo "Копирование ярлыков..."
USER_HOME=$(eval echo "~$SUDO_USER")
cp "$DESKTOP_FILE" "$USER_HOME/Рабочий стол/"
cp "$DESKTOP_FILE" "$USER_HOME/.local/share/applications/"
chmod +x "$USER_HOME/Рабочий стол/VMS.desktop"
chmod +x "$USER_HOME/.local/share/applications/VMS.desktop"

# Завершение
echo "Установка завершена. Теперь вы можете запустить VMS через ярлык на рабочем столе или в меню приложений."
exit 0
