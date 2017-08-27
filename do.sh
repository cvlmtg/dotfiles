#!/bin/bash

source=~/dotfiles
backup=~/dotfiles/backup

install () {
    for file in ${@}; do
        echo "processing file $file..."
        base="$(basename $file)"
        path="$(dirname $file)"

        # "bin/" is treated specially
        if [[ "$path" == "bin" ]]; then
            dest="$HOME/$file"
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

        echo "  symlinking $source/$file to $dest"

        if [[ ! -d "$dir" ]]; then
            mkdir -p $dir
        fi

        ln -s "$source/$file" "$dest"
    done
}

uninstall () {
    for file in ${@}; do
        echo "processing file $file..."
        base="$(basename $file)"
        path="$(dirname $file)"

        if [[ "$path" == "bin" ]]; then
            dest="$HOME/$file"
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

cd "$source"
files=`find * -type f ! -name 'do.sh' ! -name '.gitignore' ! -path 'backup/*' ! -path '.git/*' -a -print`

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
