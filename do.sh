#!/bin/bash

srcdir=~/dotfiles
backup=~/dotfiles/backup

# On Windows, symlinks require either Admin or Developer Mode
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "$WINDIR" ]]; then
    # Check Developer Mode via registry
    devmode=$(reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" \
        /v AllowDevelopmentWithoutDevLicense 2>/dev/null | grep -o "0x[0-9a-fA-F]*" | tail -1)
    is_admin=$(net session 2>&1 | grep -c "There are no entries")

    if [[ "$devmode" != "0x1" && "$is_admin" -eq 0 ]]; then
        echo "ERROR: On Windows, symlinks require either:"
        echo "  - Developer Mode enabled (Settings > System > For Developers)"
        echo "  - Running as Administrator"
        exit 1
    fi
fi

install () {
    for file in ${@}; do
        echo "processing file $file..."
        base="$(basename $file)"
        path="$(dirname $file)"

        # some paths are special
        if [[ "$path" == "bin" ]] || [[ "$path" == "Library" ]]; then
            dest="$HOME/$file"
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "$WINDIR" ]] && [[ "$file" == config/nvim/* ]]; then
            # On Windows, nvim config lives in ~/AppData/Local/nvim/ instead of ~/.config/nvim/
            dest="$HOME/AppData/Local/nvim/${file#config/nvim/}"
        else
            dest="$HOME/.$file"
        fi

        dir="$(dirname $dest)"

        if [[ -f "$dest" ]]; then
            if [[ ! -L "$dest" ]]; then
                [[ "$path" == "." ]] && path=''
                [[ -e "$backup/$path" ]] || mkdir -p "$backup/$path"
                echo "  destination file exists and is not a symlink"
                echo "  backing it up to $backup/$path/$base"
                cp "$dest" "$backup/$path/$base"
            fi

            rm "$dest"
        fi

        echo "  symlinking $srcdir/$file to $dest"

        if [[ ! -d "$dir" ]]; then
            mkdir -p $dir
        fi

        ln -s "$srcdir/$file" "$dest"
    done
}

uninstall () {
    for file in ${@}; do
        echo "processing file $file..."
        base="$(basename $file)"
        path="$(dirname $file)"

        if [[ "$path" == "bin" ]] || [[ "$path" == "Library" ]]; then
            dest="$HOME/$file"
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "$WINDIR" ]] && [[ "$file" == config/nvim/* ]]; then
            # On Windows, nvim config lives in ~/AppData/Local/nvim/ instead of ~/.config/nvim/
            dest="$HOME/AppData/Local/nvim/${file#config/nvim/}"
        else
            dest="$HOME/.$file"
        fi

        if [[ -f "$dest" && -L "$dest" ]]; then
            [[ "$path" == "." ]] && path=''
            echo "  destination file exists and is a symlink, restoring"

            if [[ ! -f "$backup/$path/$base" ]]; then
                echo " backup file doesn't exists! leaving symlink in place"
            else
                rm "$dest"
                cp "$backup/$path/$base" "$dest"
            fi
        fi
    done
}

cd "$srcdir"
files=`find . -type f ! -name 'do.sh' ! -name '.gitignore' ! -path 'backup/*' ! -path '.git/*' -a -print | sed 's|^\./||'`

case $1 in
    install)
        install $files
        ;;
    uninstall)
        uninstall $files
        ;;
    *)
        echo "usage: do.sh (install|uninstall)"
esac

cd ~
unset install
unset uninstall
