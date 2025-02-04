#!/bin/bash
set -e  # Przerwij w razie błędu

# Funkcja do instalacji pakietów
install_packages() {
    echo "Aktualizuję pakiety i instaluję niezbędne narzędzia..."
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y tmux zsh curl git fzf
}

# Instalacja Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Instaluję Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    else
        echo "Oh My Zsh jest już zainstalowane."
    fi
}

# Ustawienie zsh jako domyślnej powłoki
set_default_shell() {
    echo "Ustawiam Zsh jako domyślną powłokę..."
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        chsh -s "$(which zsh)"
    else
        echo "Zsh jest już domyślną powłoką."
    fi
}

# Klonowanie repozytorium konfiguracyjnego (Twoje Linux-configuration)
clone_config_repo() {
    REPO_URL="https://github.com/jstefaniak99/Linux-configuration.git"
    CONFIG_DIR="$HOME/Linux-configuration"

    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Klonuję repozytorium konfiguracyjne do $CONFIG_DIR..."
        git clone "$REPO_URL" "$CONFIG_DIR"
    else
        echo "Repozytorium konfiguracyjne już istnieje w $CONFIG_DIR."
    fi
}

# Linkowanie plików z Linux-configuration
link_Linux-configuration() {
    Linux-configuration_DIR="$HOME/Linux-configuration"

    # Lista plików konfiguracyjnych do zlinkowania
    for file in .zshrc .p10k.zsh .gitconfig .tmux.conf; do
        if [ -f "$Linux-configuration_DIR/$file" ]; then
            # Backup istniejących plików (o ile nie są linkami)
            if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                echo "Plik $HOME/$file już istnieje – robię backup jako $file.backup"
                mv "$HOME/$file" "$HOME/$file.backup"
            fi
            ln -sf "$Linux-configuration_DIR/$file" "$HOME/$file"
            echo "Utworzono link: $HOME/$file → $Linux-configuration_DIR/$file"
        fi
    done
}

# Instalacja Powerlevel10k i wstawienie do .zshrc
install_powerlevel10k() {
    # 1. Klonowanie repo powerlevel10k
    if [ ! -d "$HOME/powerlevel10k" ]; then
        echo "Klonuję powerlevel10k do ~/powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
    else
        echo "Repozytorium powerlevel10k już istnieje w ~/powerlevel10k"
    fi

    # 2. Dodanie source do .zshrc (jeśli nie ma)
    if ! grep -Fxq "source ~/powerlevel10k/powerlevel10k.zsh-theme" "$HOME/.zshrc" 2>/dev/null; then
        echo "Dodaję linijkę source powerlevel10k.zsh-theme do .zshrc"
        echo '' >> "$HOME/.zshrc"
        echo '# Powerlevel10k theme' >> "$HOME/.zshrc"
        echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> "$HOME/.zshrc"
    fi

    # 3. Wstawienie plugins=(git zsh-autosuggestions)
    #    - jeśli w .zshrc nie ma "plugins=(", dopisz
    #    - jeśli jest, zastąp nową wartością
    if grep -qE '^plugins=\(' "$HOME/.zshrc"; then
        # Zamieniamy w linii z "plugins=(" wszystko na "plugins=(git zsh-autosuggestions)"
        sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions)/' "$HOME/.zshrc"
        echo "Zmieniono istniejący wpis plugins=(...) na (git zsh-autosuggestions)."
    else
        # Jeśli nie ma w ogóle – to dodajemy na końcu pliku .zshrc
        echo "Dodaję wpis plugins=(git zsh-autosuggestions) do .zshrc"
        echo '' >> "$HOME/.zshrc"
        echo '# Oh My Zsh plugins' >> "$HOME/.zshrc"
        echo 'plugins=(git zsh-autosuggestions)' >> "$HOME/.zshrc"
    fi
}

# Główna część skryptu
install_packages
install_oh_my_zsh
set_default_shell
clone_config_repo
link_Linux-configuration
install_powerlevel10k  # uruchamiamy na końcu

echo "Instalacja zakończona! Uruchom ponownie terminal lub wyloguj i zaloguj się ponownie, aby zastosować zmiany."
