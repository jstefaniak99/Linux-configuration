#!/bin/bash

# Funkcja do instalacji pakietów
install_packages() {
    echo "Aktualizuję pakiety..."
    sudo apt update && sudo apt upgrade -y

    echo "Instaluję tmux, zsh, curl, git..."
    sudo apt install -y tmux zsh curl git
}

# Instalacja Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Instaluję Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    else
        echo "Oh My Zsh już jest zainstalowane."
    fi
}

# Ustawienie zsh jako domyślnej powłoki
set_default_shell() {
    echo "Ustawiam Zsh jako domyślną powłokę..."
    chsh -s $(which zsh)
}

# Klonowanie repozytorium konfiguracyjnego
clone_config_repo() {
    REPO_URL="https://github.com/twoj-uzytkownik/dotfiles.git"
    CONFIG_DIR="$HOME/.config"

    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Klonuję repozytorium konfiguracyjne..."
        git clone $REPO_URL $CONFIG_DIR
    else
        echo "Repozytorium konfiguracyjne już istnieje w $CONFIG_DIR."
    fi
}

# Wykonanie funkcji
install_packages
install_oh_my_zsh
set_default_shell
clone_config_repo

echo "Instalacja zakończona! Uruchom ponownie terminal, aby zastosować zmiany."
