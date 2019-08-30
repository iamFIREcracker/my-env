#!/usr/bin/env bash

FORCE=0
ENABLE_AADBOOK=${ENABLE_AADBOOK:-0}
ENABLE_B1=${ENABLE_B1:-0}
ENABLE_BR=${ENABLE_BR:-0}
ENABLE_CB=${ENABLE_CB:-0}
ENABLE_CG=${ENABLE_CG:-0}
ENABLE_DOTFILES=${ENABLE_DOTFILES:-0}
ENABLE_GOOBOOK=${ENABLE_GOOBOOK:-0}
ENABLE_JSLS=${ENABLE_JSLS:-0}
ENABLE_KEYRING=${ENABLE_KEYRING:-0}
ENABLE_MUTT_NOTMUCH_PY=${ENABLE_MUTT_NOTMUCH_PY:-0}
ENABLE_NATIVEFIED_APPS=${ENABLE_NATIVEFIED_APPS:-0}
ENABLE_OFFLINEIMAP=${ENABLE_OFFLINEIMAP:-0}
ENABLE_QUICKLISP=${ENABLE_QUICKLISP:-0}
ENABLE_TLS=${ENABLE_TLS:-0}
ENABLE_TMUX=${ENABLE_TMUX:-0}
ENABLE_URLVIEW=${ENABLE_URLVIEW:-0}
ENABLE_VIM=${ENABLE_VIM:-0}
ENABLE_WINPTY=${ENABLE_WINPTY:-0}
ENABLE_Z=${ENABLE_Z:-0}

for i; do
    if [ "$i" == '--force' ]; then
        FORCE=1
    elif [ "$i" == '--os-linux' ]; then
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_JSLS=1
        ENABLE_QUICKLISP=1
        ENABLE_TLS=1
        ENABLE_TMUX=1
        ENABLE_URLVIEW=1
        ENABLE_VIM=1
        ENABLE_Z=1
    elif [ "$i" == '--os-mac' ]; then
        ENABLE_AADBOOK=1
        ENABLE_B1=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_GOOBOOK=1
        ENABLE_JSLS=1
        ENABLE_KEYRING=1
        ENABLE_MUTT_NOTMUCH_PY=1
        ENABLE_OFFLINEIMAP=1
        ENABLE_QUICKLISP=1
        ENABLE_TLS=1
        ENABLE_URLVIEW=1
        ENABLE_Z=1
    elif [ "$i" == '--os-win-top' ]; then
        ENABLE_B1=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_DOTFILES=1
        ENABLE_KEYRING=1
        ENABLE_URLVIEW=1
        ENABLE_WINPTY=1
        ENABLE_Z=1
    elif [ "$i" == '--os-win-station' ]; then
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_DOTFILES=1
        ENABLE_WINPTY=1
        ENABLE_Z=1
    else
        echo "Unsupported option: $i"
        exit 1
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
    ln -s "$1" "$2"
}

function ensure_dir {
    test $FORCE -eq 1 && remove "$HOME/$1"
    test -d "$HOME/$1" || create_dir "$HOME/$1"
}

function remove {
    rm -rf "$1"
}

function create_dir {
    mkdir -p $1
}

ensure_dir  "local/bin"
ensure_dir  "local/man/man1"
ensure_link "dotfiles" "dotfiles"
ensure_link "opt"      "opt"

(
    if [ $ENABLE_AADBOOK -eq 1 ]; then
        cd opt/aadbook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
        fi
        test $FORCE -eq 1 && rm -f ~/local/bin/aadbook
        if [ ! -f ~/local/bin/aadbook ]; then
            venv-python setup.py install \
              --install-scripts=~/local/bin
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
    if [ $ENABLE_BR -eq 1 ]; then
        cd opt/br
        test $FORCE -eq 1 && rm -f ~/local/bin/br
        if [ ! -f ~/local/bin/br ]; then
          PREFIX=~/local/bin make install
        fi
    fi
)

(
    if [ $ENABLE_CB -eq 1 ]; then
        cd opt/cb
        test $FORCE -eq 1 && rm -f ~/local/bin/cb
        if [ ! -f ~/local/bin/cb ]; then
          PREFIX=~/local/bin make install
        fi
    fi
)

(
    if [ $ENABLE_QUICKLISP -eq 1 ]; then
        test $FORCE -eq 1 && rm -rf ~/quicklisp/
        if [ ! -d ~/quicklisp ]; then
            sbcl \
                --load ~/opt/quicklisp/quicklisp.lisp \
                --eval '(quicklisp-quickstart:install)' \
                --eval '(ql:quickload :deploy)' \
                --eval '(quit)'

        fi
    fi
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
        fi
        test $FORCE -eq 1 && rm -f ~/local/bin/goobook
        if [ ! -f ~/local/bin/goobook ]; then
            venv-python setup.py install \
              --install-scripts=~/local/bin
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
    if [ $ENABLE_MUTT_NOTMUCH_PY -eq 1 ]; then
        cd opt/mutt-notmuch-py
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
        fi
        test $FORCE -eq 1 && rm -f ~/local/bin/mutt-notmuch-py
        if [ ! -f ~/local/bin/mutt-notmuch-py ]; then
            venv-python setup.py install \
              --install-scripts=~/local/bin
        fi
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
        test $FORCE -eq 1 && test -f 'urlview' && (make clean || true)
        if [ ! -f urlview -a ! -f urlview.exe ]; then
            ./configure \
              --prefix=$HOME/local \
              --mandir=$HOME/local/man
            autoreconf -vfi # https://github.com/sigpipe/urlview/issues/7
            make
        fi
    fi
)

(
    if [ $ENABLE_VIM -eq 1 ]; then
        cd opt/vim
        test $FORCE -eq 1 && make clean
        if [ ! -f src/vim ]; then
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

(
    if [ $ENABLE_Z -eq 1 ]; then
        ensure_link "opt/z/z.1" "local/man/man1/z.1"
    fi
)
