# ~/dotfiles/nb/nb.sh
# nb için kişisel kabuk modülü. bash ve zsh ile aynı şekilde çalışır.
#
# Kabuk dosyana (~/.zshrc ve/veya ~/.bashrc) şu satırla yüklenir:
#   [ -f "${DOTFILES:-$HOME/dotfiles}/nb/nb.sh" ] && source "${DOTFILES:-$HOME/dotfiles}/nb/nb.sh"

# ------------------------------------------------------------------
# 1. Ayarlar
# ------------------------------------------------------------------

# Fonksiyonların yazacağı notebook. Önceden tanımlıysan ona dokunmaz.
NOT_DEFTERI="${NOT_DEFTERI:-home}"

# O notebook'un diskteki yeri. nb, NB_DIR tanımlı değilse ~/.nb kullanır.
NOT_DIZINI="${NB_DIR:-$HOME/.nb}/$NOT_DEFTERI"

# yeni() fonksiyonunun şablonu: bu dosyanın yanındaki sablon.md
NOT_SABLONU="${DOTFILES:-$HOME/dotfiles}/nb/sablon.md"

# nb notları $EDITOR ile açar. Başka bir editör seçtiysen ona dokunmaz.
export EDITOR="${EDITOR:-nano}"

# zsh'de aynı adda bir alias varken fonksiyon tanımlamak hata verir.
# Dosya ikinci kez yüklendiğinde sorun çıkmasın diye önce alias'ı kaldır.
if [ -n "$ZSH_VERSION" ]; then
  unalias yakala 2>/dev/null
fi

# ------------------------------------------------------------------
# 2. Yardımcı: metinden dosya adı üret
#    "nano'da Satır Kaydırma" -> "nano-da-satir-kaydirma"
# ------------------------------------------------------------------
_not_dosya_adi() {
  printf '%s' "$1" \
    | sed -e 's/ç/c/g; s/ğ/g/g; s/ı/i/g; s/ö/o/g; s/ş/s/g; s/ü/u/g' \
          -e 's/Ç/c/g; s/Ğ/g/g; s/İ/i/g; s/Ö/o/g; s/Ş/s/g; s/Ü/u/g' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# ------------------------------------------------------------------
# 3. yakala: editör açmadan gelen kutusuna tek satırlık not
#    kullanım: yakala "Syncthing sürümleme ayarına bak #linux"
# ------------------------------------------------------------------
yakala() {
  if [ $# -eq 0 ]; then
    echo 'kullanım: yakala "not metni"' >&2
    return 1
  fi
  nb add "${NOT_DEFTERI}:gelen/$(date +%Y%m%d%H%M%S).md" --content "$*"
}

# ------------------------------------------------------------------
# 4. bugun: bugünün günlük notunu aç, yoksa oluştur
#    kullanım: bugun
# ------------------------------------------------------------------
bugun() {
  local tarih dosya
  tarih="$(date +%F)"
  dosya="gunluk/$tarih.md"

  if [ -f "$NOT_DIZINI/$dosya" ]; then
    nb edit "${NOT_DEFTERI}:$dosya"
  else
    nb add "${NOT_DEFTERI}:$dosya" --title "$tarih"
  fi
}

# ------------------------------------------------------------------
# 5. yeni: şablonlu kalıcı bilgi notu
#    kullanım: yeni "Başlık" [klasör] [etiket1,etiket2]
#    örnek:    yeni "nano'da satır kaydırma nasıl açılır" konular linux,nano
# ------------------------------------------------------------------
yeni() {
  if [ -z "$1" ]; then
    echo 'kullanım: yeni "Başlık" [klasör] [etiket1,etiket2]' >&2
    return 1
  fi
  if [ ! -f "$NOT_SABLONU" ]; then
    echo "Şablon bulunamadı: $NOT_SABLONU" >&2
    return 1
  fi

  local baslik="$1"
  local klasor="${2:-konular}"
  local ad
  ad="$(_not_dosya_adi "$baslik")"
  [ -z "$ad" ] && ad="$(date +%Y%m%d%H%M%S)"

  local -a etiket=()
  [ -n "$3" ] && etiket=(--tags "$3")

  nb add "${NOT_DEFTERI}:$klasor/$ad.md" \
    --title "$baslik" \
    --template "$NOT_SABLONU" \
    "${etiket[@]}"
}

# ------------------------------------------------------------------
# 6. nbresim: panodaki resmi resimler/ klasörüne kaydet,
#    nota yapıştırılacak markdown satırını yaz
#    kullanım: nbresim [ad]
# ------------------------------------------------------------------
nbresim() {
  local ad="${1:-ekran-$(date +%Y%m%d-%H%M%S)}"
  ad="$(_not_dosya_adi "${ad%.png}")"

  local klasor="$NOT_DIZINI/resimler"
  local hedef="$klasor/$ad.png"
  mkdir -p "$klasor"

  if [ -n "$WAYLAND_DISPLAY" ]; then
    wl-paste --type image/png > "$hedef" 2>/dev/null
  else
    xclip -selection clipboard -t image/png -o > "$hedef" 2>/dev/null
  fi

  if [ ! -s "$hedef" ]; then
    rm -f "$hedef"
    echo "Panoda PNG resim yok ya da xclip/wl-clipboard kurulu değil." >&2
    return 1
  fi

  echo "![$ad](resimler/$ad.png)"
}

# ------------------------------------------------------------------
# 7. zsh: yakala'ya yazılan ? ve * karakterleri dosya kalıbı sayılmasın
# ------------------------------------------------------------------
if [ -n "$ZSH_VERSION" ]; then
  alias yakala='noglob yakala'
fi
