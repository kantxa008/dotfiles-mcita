# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light aloxaf/fzf-tab


# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
autoload -Uz tetriscurses
alias tetris=tetriscurses


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
	#Home ve End tuşlarını ayarla
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
	# Alt + Delete ile kelime silme:
bindkey "^[[3;3~" backward-kill-word

	# --- Navigasyon (Ok Tuşları) ---
	# Alt + Sol Ok (Kelime başına git)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word


# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Shell integrations
# eval "$(fzf --zsh)"


# Zoxide başlatma komutu (Path'e ekleyerek)
export PATH=$PATH:$HOME/.local/bin
unalias zi 
eval "$(zoxide init zsh)"

# --- SSH ANAHTAR YÖNETİMİ (Keychain) ---
# Terminal her açıldığında id_ed25519 anahtarını hazır tutar.
eval $(keychain --eval --quiet git_gozgenc)



alias mpv='flatpak run io.mpv.Mpv'



# PubChem Hızlı Arama Fonksiyonu
kimya() {
    python3 -c "
import sys
import pubchempy as pcp
try:
    query = '$1'
    print(f'\n🔍  {query} aranıyor...')
    compounds = pcp.get_compounds(query, 'name')
    if compounds:
        c = compounds[0]
        print('-' * 40)
        print(f'📌  Isim: {query.capitalize()}')
        print(f'🧪  Formül: {c.molecular_formula}')
        print(f'⚖️  Mol. Ağırlığı: {c.molecular_weight} g/mol')
        print(f'🆔  CID: {c.cid}')
        print(f'📜  IUPAC: {c.iupac_name}')
        print(f'🔗  Link: https://pubchem.ncbi.nlm.nih.gov/compound/{c.cid}')
        print('-' * 40)
    else:
        print('❌ Bileşik bulunamadı.')
except Exception as e:
    print(f'Hata: {e}')
"
}


# ChemPy Molar Kütle Hesaplayıcı
mass() {
    python3 -c "
from chempy import Substance
try:
    formula = '$1'
    s = Substance.from_formula(formula)
    print(f'\n🧪  {formula} için Molar Kütle:')
    print(f'➡️  {s.molar_mass():.4f} g/mol')
except Exception as e:
    print('❌ Geçersiz formül.')
"
}



# ChemSpider Arama (API Key Varsa)
spider() {
    python3 -c "
from chemspipy import ChemSpider
cs = ChemSpider('BURAYA_API_ANAHTARINIZI_YAZIN')
try:
    query = '$1'
    print(f'\n🕷️  ChemSpider: {query} aranıyor...')
    results = cs.search(query)
    if results:
        c = results[0]  # İlk sonucu al
        print(f'📌  CSID: {c.csid}')
        print(f'🧪  Formül: {c.formula}')
        print(f'⚖️  Ağırlık: {c.molecular_weight}')
        print(f'🔗  Link: https://www.chemspider.com/Chemical-Structure.{c.csid}.html')
    else:
        print('❌ Sonuç yok.')
except Exception as e:
    print(f'Hata (API Key kontrol edin): {e}')
"
}


#Ses Sorununu Kontrol Et ve Düzelt!
audio_status() {
    print "==== Audio Diagnostic Report ===="

    print "\n1. ALSA Hardware Status:"
    local alsa_status
    alsa_status=$(amixer sget Master 2>/dev/null | grep -o '\[o[nf]*\]' | head -n 1)
    if [[ "$alsa_status" == "[off]" ]]; then
        print "   Status: 🔴 MUTED — Fix: amixer sset Master unmute"
    else
        print "   Status: ✅ ${alsa_status:-Bilinmiyor}"
    fi

    print "\n2. WirePlumber Software Status:"
    local wp_out
    wp_out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if echo "$wp_out" | grep -q "MUTED"; then
        print "   🔴 MUTED — Fix: wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
    else
        print "   ✅ $wp_out"
    fi

    print "\n3. PipeWire Sink State:"
    pactl list short sinks 2>/dev/null | while read -r idx name driver fmt state; do
        case "$state" in
            SUSPENDED) print "   Sink $idx ($name): 🔴 SUSPENDED" ;;
            RUNNING)   print "   Sink $idx ($name): ✅ RUNNING" ;;
            IDLE)      print "   Sink $idx ($name): 🟡 IDLE" ;;
            *)         print "   Sink $idx ($name): ❓ $state" ;;
        esac
    done

    print "================================="
}

audio_fix() {
    print "🔧 Running automated fixes..."

    # 1. ALSA hardware unmute (en sık atlanan adım)
    print "  → ALSA unmute..."
    amixer sset Master unmute 2>/dev/null
    amixer sset Master 100% 2>/dev/null
    amixer sset PCM unmute 2>/dev/null   # bazı sistemlerde PCM ayrı mute olabiliyor

    # 2. WirePlumber software unmute
    print "  → WirePlumber unmute..."
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0

    # 3. Servisleri yeniden başlat
    print "  → PipeWire servisleri yeniden başlatılıyor..."
    systemctl --user restart wireplumber pipewire pipewire-pulse

    # 4. Servislerin hazır olmasını bekle
    sleep 2

    # 5. Fix sonrası durum kontrolü
    print "\n✅ Fix tamamlandı. Güncel durum:"
    audio_status

    print "\nHâlâ sorun varsa: alsamixer → F6 ile kart seç → MM kanalları Space ile aç"
}





# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
