#!/usr/bin/env bash

FORCE=0
ENABLE_AADBOOK=0
ENABLE_B1=0
ENABLE_CG=1
ENABLE_DOTFILES=1
ENABLE_GOOBOOK=0
ENABLE_JSLS=1
ENABLE_KEYRING=1
ENABLE_NATIVEFIED_APPS=0
ENABLE_OFFLINEIMAP=1
ENABLE_TLS=1
ENABLE_TMUX=1
ENABLE_URLVIEW=1
ENABLE_VIM=1
ENABLE_WINPTY=0

for i; do
    if [ "$i" == '--force' ]; then
        FORCE=1
    elif [ "$i" == '--os-linux' ]; then
      ENABLE_AADBOOK=0
      ENABLE_B1=0
      ENABLE_CG=1
      ENABLE_DOTFILES=1
      ENABLE_GOOBOOK=0
      ENABLE_JSLS=1
      ENABLE_KEYRING=0
      ENABLE_NATIVEFIED_APPS=0
      ENABLE_OFFLINEIMAP=0
      ENABLE_TLS=1
      ENABLE_TMUX=1
      ENABLE_URLVIEW=1
      ENABLE_VIM=1
      ENABLE_WINPTY=0
    elif [ "$i" == '--os-mac' ]; then
      ENABLE_AADBOOK=1
      ENABLE_B1=1
      ENABLE_CG=1
      ENABLE_DOTFILES=1
      ENABLE_GOOBOOK=1
      ENABLE_JSLS=1
      ENABLE_KEYRING=1
      ENABLE_NATIVEFIED_APPS=0
      ENABLE_OFFLINEIMAP=1
      ENABLE_TLS=1
      ENABLE_TMUX=0
      ENABLE_URLVIEW=1
      ENABLE_VIM=0
      ENABLE_WINPTY=0
    elif [ "$i" == '--os-win' ]; then
      ENABLE_AADBOOK=1
      ENABLE_B1=1
      ENABLE_CG=1
      ENABLE_DOTFILES=1
      ENABLE_GOOBOOK=1
      ENABLE_JSLS=1
      ENABLE_KEYRING=1
      ENABLE_NATIVEFIED_APPS=0
      ENABLE_OFFLINEIMAP=1
      ENABLE_TLS=1
      ENABLE_TMUX=0
      ENABLE_URLVIEW=1
      ENABLE_VIM=0
      ENABLE_WINPTY=1
    elif [ "$i" == '--enable-aadbook' ]; then
        ENABLE_AADBOOK=1
    elif [ "$i" == '--enable-b1' ]; then
        ENABLE_B1=1
    elif [ "$i" == '--disable-cg' ]; then
        ENABLE_CG=0
    elif [ "$i" == '--disable-dotfiles' ]; then
        ENABLE_DOTFILES=0
    elif [ "$i" == '--enable-goobook' ]; then
        ENABLE_GOOBOOK=1
    elif [ "$i" == '--disable-jsls' ]; then
        ENABLE_JSLS=0
    elif [ "$i" == '--disable-keyring' ]; then
        ENABLE_KEYRING=0
    elif [ "$i" == '--enable-nativefied-apps' ]; then
        ENABLE_NATIVEFIED_APPS=1
    elif [ "$i" == '--disable-offlineimap' ]; then
        ENABLE_OFFLINEIMAP=0
    elif [ "$i" == '--disable-tls' ]; then
        ENABLE_TLS=0
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
OS_WIN=$(uname -s | grep -e CYGWIN -e Microsoft)

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

ensure_link "dotfiles" "dotfiles"
ensure_link "opt"      "opt"

(
    if [ $ENABLE_AADBOOK -eq 1 ]; then
        cd opt/aadbook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
            venv-python setup.py develop
        fi
    fi
)

(
    if [ $ENABLE_B1 -eq 1 ]; then
        cd opt/bunny1
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenv venv
            venv-pip install -r requirements.txt
        fi
    fi
)

(
    sbcl \
        --load ~/opt/quicklisp/quicklisp.lisp \
        --eval '(quicklisp-quickstart:install)' \
        --eval '(ql:quickload :deploy)' \
        --eval '(quit)'
)

(
    if [ $ENABLE_CG -eq 1 ]; then
        cd opt/cg
        test $FORCE -eq 1 && rm -f ~/quicklisp/local-projects/cg
        if [ ! -L ~/quicklisp/local-projects/cg ]; then
            ln -s $(pwd) ~/quicklisp/local-projects/cg
        fi
        test $FORCE -eq 1 && make clean
        if [ ! -d bin ]; then
            make
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
            virtualenvw venv --python=python3
            venv-python setup.py develop
        fi
    fi
)

(
    if [ $ENABLE_JSLS -eq 1 ]; then
        cd opt/js-langserver
        test $FORCE -eq 1 && rm -rf node_modules
        if [ ! -d node_modules ]; then
            npm install
        fi
    fi
)

(
    if [ $ENABLE_KEYRING -eq 1 ]; then
        cd opt/keyring
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
            venv-pip install -r requirements.txt
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
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
            venv-pip install -r requirements.txt
            venv-python setup.py build
            venv-python setup.py install
            mkdir -p ~/.mail
        fi
    fi
)

(
    if [ $ENABLE_TLS -eq 1 ]; then
        cd opt/typescript-language-server
        test $FORCE -eq 1 && rm -rf node_modules
        if [ ! -d node_modules ]; then
            npm install
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
