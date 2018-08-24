#!/usr/bin/env bash

FORCE=0
ENABLE_B1=0
ENABLE_DOTFILES=1
ENABLE_GOOBOOK=0
ENABLE_KEYRING=1
ENABLE_NATIVEFIED_APPS=0
ENABLE_OFFLINEIMAP=1
ENABLE_TMUX=1
ENABLE_URLVIEW=1
ENABLE_VIM=1
ENABLE_WINPTY=0

for i; do
    if [ "$i" == '--force' ]; then
        FORCE=1
    elif [ "$i" == '--enable-b1' ]; then
        ENABLE_B1=1
    elif [ "$i" == '--disable-dotfiles' ]; then
        ENABLE_DOTFILES=0
    elif [ "$i" == '--enable-goobook' ]; then
        ENABLE_GOOBOOK=1
    elif [ "$i" == '--disable-keyring' ]; then
        ENABLE_KEYRING=0
    elif [ "$i" == '--enable-nativefied-apps' ]; then
        ENABLE_NATIVEFIED_APPS=1
    elif [ "$i" == '--disable-offlineimap' ]; then
        ENABLE_OFFLINEIMAP=0
    elif [ "$i" == '--disable-tmux' ]; then
        ENABLE_TMUX=0
    elif [ "$i" == '--disable-urlview' ]; then
        ENABLE_URLVIEW=0
    elif [ "$i" == '--disable-vim' ]; then
        ENABLE_VIM=0
    elif [ "$i" == '--enable-winpty' ]; then
        ENABLE_WINPTY=1
    fi
done

WORKDIR="$(pwd)"
OS_WIN=$(uname -s | grep CYGWIN)

set -u
set -e
set -x

function ensure_link {
    test $FORCE -eq 1 && remove "$HOME/$2"
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
    if [ $ENABLE_B1 -eq 1 ]; then
        cd opt/bunny1
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenv venv
            venv/bin/pip install -r requirements.txt
        fi
    fi
)

(
    if [ $ENABLE_DOTFILES -eq 1 ]; then
        cd dotfiles
        bash install.sh "$@"
    fi
)

(
    if [ $ENABLE_GOOBOOK -eq 1 ]; then
        cd opt/goobook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenv venv
            venv/bin/pip install -r requirements.txt
        fi
    fi
)

(
    if [ $ENABLE_KEYRING -eq 1 ]; then
        cd opt/goobook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            if [ -z "$OS_WIN" ]; then
                $(cygpath -u C:\\Python27\\Scripts\\virtualenv) venv
                $(cygpath -u C:\\Python27\\Scripts\\pip) install -r requirements.txt
            else
                virtualenv venv
                venv/bin/pip install -r requirements.txt
            fi
        fi
    fi
)

(
    if [ $ENABLE_NATIVEFIED_APPS -eq 1 ]; then
        cd nativefied-apps/
        test $FORCE -eq 1 && rm -rf node_modules
        npm install
    fi
)

(
    if [ $ENABLE_OFFLINEIMAP -eq 1 ]; then
        cd opt/offlineimap
        test $FORCE -eq 1 && test -d 'venv' && rm -rf venv
        if [ ! -d venv ]; then
            virtualenv venv
            venv/bin/pip install -r requirements.txt
            make
        fi
    fi
)

(
    if [ $ENABLE_TMUX -eq 1 ]; then
        cd opt/tmux
        test $FORCE -eq 1 && test -f 'tmux' && make clean
        if [ ! -f tmux ]; then
            sh autogen.sh
            ./configure 
            make
            sudo make install
        fi
    fi
)

(
    if [ $ENABLE_URLVIEW -eq 1 ]; then
        cd opt/urlview
        test $FORCE -eq 1 && test -f 'urlview' && make clean
        if [ ! -f urlview -a ! -f urlview.exe ]; then
            autoreconf -vfi # https://github.com/sigpipe/urlview/issues/7
            ./configure
            make
        fi
    fi
)

(
    if [ $ENABLE_VIM -eq 1 ]; then
        cd opt/vim
        test $FORCE -eq 1 && make clean
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

(
    if [ $ENABLE_WINPTY -eq 1 ]; then
        cd opt/winpty
        test $FORCE -eq 1 && make clean
        if [ ! -f build/winpty.exe ]; then
            ./configure
            make
        fi
    fi
)

ensure_link "dotfiles" "dotfiles"
ensure_link "opt"      "opt"
