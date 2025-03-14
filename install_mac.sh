#!/bin/bash
LOGFILE="install_log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "🚀 Начало установки всех программ..."

# ==============================
# 1️⃣ Запрос пароля sudo в начале (чтобы не вводить его повторно)
# ==============================
echo "🔑 Введите пароль администратора (sudo), чтобы продолжить установку..."
sudo -v

# Поддерживаем сессию sudo активной, пока выполняется скрипт
while true; do sudo -v; sleep 60; done &

# ==============================
# 2️⃣ Проверка отключения VPN перед установкой
# ==============================
echo "🔴 Перед установкой отключите VPN и нажмите Enter для продолжения..."
read -r  # Ждём подтверждения пользователя

VPN_STATUS=$(scutil --nc list | grep -i 'connected')

if [[ -n "$VPN_STATUS" ]]; then
    echo "⚠️  VPN всё ещё включён! Отключите VPN и попробуйте снова."
    exit 1  # Завершаем скрипт, если VPN не отключён
fi

echo "✅ VPN отключён. Продолжаем установку..."

# ==============================
# 3️⃣ Проверка подключения к интернету
# ==============================
echo "🌍 Проверяем подключение к интернету..."
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "❌ Нет доступа к интернету! Проверьте соединение и попробуйте снова."
    exit 1
fi
echo "✅ Интернет доступен."

# ==============================
# 4️⃣ Установка Homebrew (если не установлен)
# ==============================
if ! command -v brew &>/dev/null; then
    echo "📦 Устанавливаем Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew уже установлен."
fi

brew update && brew upgrade

# ==============================
# 5️⃣ Функция для проверки, установлено ли приложение
# ==============================
is_installed() {
    local app_name="$1"
    if [[ -d "/Applications/$app_name.app" ]]; then
        echo "✅ $app_name уже установлен. Пропускаем."
        return 0
    else
        return 1
    fi
}

# ==============================
# 6️⃣ Установка основных инструментов разработки
# ==============================
echo "🛠️ Устанавливаем основные инструменты разработки..."

brew install --cask pycharm-ce
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask sublime-text
brew install --cask postman

# ==============================
# 7️⃣ Установка офисных приложений
# ==============================
echo "📑 Устанавливаем офисные приложения..."
brew install --cask onlyoffice

# ==============================
# 8️⃣ Утилиты для системы
# ==============================
echo "⚙️ Устанавливаем системные утилиты..."
brew install --cask keka
brew install --cask appcleaner
brew install --cask onyx
brew install --cask daisydisk
brew install --cask hiddenbar
brew install --cask force-paste  # Заменено вместо pure-paste
brew install --cask cheatsheet
brew install --cask lulu
brew install --cask macs-fan-control
brew install --cask rocket
brew install --cask raycast
brew install --cask shottr
brew install --cask keepingyouawake  # Заменено вместо amphetamine
brew install --cask karabiner-elements

# ==============================
# 9️⃣ Обработка мультимедиа
# ==============================
echo "🎥 Устанавливаем мультимедийные приложения..."
brew install --cask imageoptim
brew install --cask vlc
brew install --cask iina
brew install --cask obs

# ==============================
# 🔟 Интернет-приложения (мессенджеры, облачные хранилища, браузеры)
# ==============================
echo "📡 Устанавливаем интернет-приложения..."
brew install --cask telegram
brew install --cask cyberduck
brew install --cask dropbox
brew install --cask folx
brew install --cask yandex

# ==============================
# 🔐 Безопасность и пароли
# ==============================
echo "🔐 Устанавливаем менеджеры паролей и блокировщики..."
brew install --cask bitwarden
brew install --cask adguard

# ==============================
# 📅 Организация и продуктивность
# ==============================
echo "📅 Устанавливаем приложения для продуктивности..."
brew install --cask obsidian
brew install --cask notion
brew install --cask dash
brew install --cask pomodone

# ==============================
# 🐳 Установка Docker (требует sudo)
# ==============================
echo "🐳 Устанавливаем Docker..."
if is_installed "Docker"; then
    echo "✅ Docker уже установлен."
else
    brew install --cask docker
fi

# ==============================
# 🖴 Установка NTFS-3G и macFUSE (требует sudo)
# ==============================
echo "🖴 Устанавливаем NTFS-3G и macFUSE..."
brew install ntfs-3g
brew install --cask macfuse
sudo mkdir -p /Volumes/NTFS

# ==============================
# 🔄 Очистка и завершение
# ==============================
echo "🧹 Очистка временных файлов..."
brew cleanup

echo "✅ Установка завершена! Проверь $LOGFILE если что-то пошло не так."
