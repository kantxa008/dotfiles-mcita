#!/bin/bash
set -e # Hata olursa dur

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}>>> Dotfiles Kurulumu: Modüler Yapı (Stow)${NC}"

# 1. Gerekli Paketlerin Kontrolü ve Kurulumu
echo -e "${GREEN}>>> Temel paketler (stow, zsh, git) kuruluyor...${NC}"
sudo apt update && sudo apt install -y git stow zsh curl

# 2. Çakışan Dosyaların Temizlenmesi (Yedekleme)
# Stow, hedefte dosya varsa çalışmaz. O yüzden var olan .zshrc vb. kaldırılmalı.

backup_file() {
    if [ -f "$HOME/$1" ] && [ ! -L "$HOME/$1" ]; then
        echo -e "${YELLOW}Uyarı: $1 mevcut. Yedeği alınıyor ($1.backup)...${NC}"
        mv "$HOME/$1" "$HOME/$1.backup"
    elif [ -L "$HOME/$1" ]; then
        echo "Mevcut sembolik link kaldırılıyor: $1"
        rm "$HOME/$1"
    fi
}

# Zsh ve Bash dosyalarını kontrol et ve yedekle
backup_file ".zshrc"
backup_file ".bashrc"
backup_file ".p10k.zsh" # Eğer zsh klasöründe p10k ayarı varsa

# 3. Stow ile Linkleme İşlemi
echo -e "${GREEN}>>> Yapılandırma dosyaları linkleniyor...${NC}"

# Scriptin çalıştığı klasöre (dotfiles) emin olalım
cd "$(dirname "$0")"

# 'zsh' klasörünün içindekileri ~ dizinine linkle
if [ -d "zsh" ]; then
    stow -v zsh
    echo "Zsh yapılandırması yüklendi."
fi

# 'bash' klasörünün içindekileri ~ dizinine linkle
if [ -d "bash" ]; then
    stow -v bash
    echo "Bash yapılandırması yüklendi."
fi

# Eğer ileride 'tmux', 'mpv' gibi klasörler açarsanız buraya ekleyebilirsiniz:

# setup.sh içine eklenecek/güncellenecek kısım:

# 'mpv' klasörü var mı kontrol et
if [ -d "mpv" ]; then
    echo -e "${GREEN}>>> MPV ayarları yükleniyor...${NC}"
    
    # Hedefte gerçek bir klasör varsa stow hata verir, onu kaldır.
    if [ -d "$HOME/.config/mpv" ] && [ ! -L "$HOME/.config/mpv" ]; then
        echo "Mevcut MPV klasörü yedeğe alınıyor..."
        mv "$HOME/.config/mpv" "$HOME/.config/mpv.backup.$(date +%s)"
    fi

    stow -R mpv
fi

# stow -v tmux
# stow -v mpv

# 4. Zsh Eklentileri ve Ayarlar
echo -e "${GREEN}>>> Zsh eklentileri hazırlanıyor...${NC}"

# Zoxide Kurulumu (Scriptlerinizde geçtiği için şart)
if ! command -v zoxide &> /dev/null; then
    curl -sS https://webinstall.dev/zoxide | bash
fi

# Varsayılan kabuğu değiştir
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo -e "${BLUE}>>> Varsayılan kabuk Zsh yapılıyor...${NC}"
    chsh -s $(which zsh)
fi

echo -e "${BLUE}>>> Kurulum Bitti! Yeni bir terminal açın.${NC}"
