#!/usr/bin/env bash

FORCE=1
ENABLE_B1=1
ENABLE_DOTFILES=0
ENABLE_NATIVEFIED_APPS=1
ENABLE_TMUX=0
ENABLE_VIM=0
for i; do
    if [ "$i" == '--force' ]; then
        FORCE=0
    elif [ "$i" == '--enable-b1' ]; then
        ENABLE_B1=0
    elif [ "$i" == '--disable-dotfiles' ]; then
        ENABLE_DOTFILES=1
    elif [ "$i" == '--enable-nativefied-apps' ]; then
        ENABLE_NATIVEFIED_APPS=0
    elif [ "$i" == '--disable-tmux' ]; then
        ENABLE_TMUX=1
    elif [ "$i" == '--disable-vim' ]; then
        ENABLE_VIM=1
    fi
done

WORKDIR="$(pwd)"

set -u
set -e
set -x

function ensure_link {
    test $FORCE -eq 0 && remove "$HOME/$2"
    test -L "$HOME/$2" || create_link "$WORKDIR/$1" "$HOME/$2"
}

function create_link {
    echo "L $2 -> $1"
    ln -s "$1" "$2"
}

function remove {
    echo "R $1"
    rm -rf "$1"
}

(
    if [ $ENABLE_B1 -eq 0 ]; then
        cd opt/bunny1
        test $FORCE -eq 0 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenv venv
        fi
        venv/bin/pip install -r requirements.txt
    fi
)

(
    if [ $ENABLE_DOTFILES -eq 0 ]; then
        cd dotfiles
        bash install.sh "$@"
    fi
)

(
    if [ $ENABLE_NATIVEFIED_APPS -eq 0 ]; then
        cd nativefied-apps/
        test $FORCE -eq 0 && rm -rf node_modules
        npm install
    fi
)

(
    if [ $ENABLE_TMUX -eq 0 ]; then
        cd opt/tmux
        test $FORCE -eq 0 && test -f 'tmux' && make clean
        if [ ! -f tmux ]; then
            sh autogen.sh
            ./configure 
            make
            sudo make install
        fi
    fi
)

(
    if [ $ENABLE_VIM -eq 0 ]; then
        cd opt/vim
        test $FORCE -eq 0 && make clean
        if [ ! -f vim ]; then
            ./configure \
                    --enable-terminal \
                    --with-features=huge \
                    --enable-multibyte \
                    --enable-largefile \
                    --enable-rubyinterp=yes \
                    --enable-pythoninterp=yes \
                    --enable-perlinterp=yes \
                    --enable-cscope \
                    --enable-fail-if-missing \
                    --prefix=/usr
            make
            sudo make install
        fi
    fi
)

ensure_link "dotfiles" "dotfiles"
ensure_link "opt"      "opt"
