#!/usr/bin/env bash

FORCE=0
BOOTSTRAP=0
ENABLE_AADBOOK=${ENABLE_AADBOOK:-0}
ENABLE_AP=${ENABLE_AP:-0}
ENABLE_B1=${ENABLE_B1:-0}
ENABLE_BR=${ENABLE_BR:-0}
ENABLE_CB=${ENABLE_CB:-0}
ENABLE_CG=${ENABLE_CG:-0}
ENABLE_DOTFILES=${ENABLE_DOTFILES:-0}
ENABLE_GOOBOOK=${ENABLE_GOOBOOK:-0}
ENABLE_KEYRING=${ENABLE_KEYRING:-0}
ENABLE_LG=${ENABLE_LG:-0}
ENABLE_MUTT_NOTMUCH_PY=${ENABLE_MUTT_NOTMUCH_PY:-0}
ENABLE_TMUX=${ENABLE_TMUX:-0}
ENABLE_GEMS=${ENABLE_GEMS:-0}
ENABLE_VIM=${ENABLE_VIM:-0}
ENABLE_RLWRAP=${ENABLE_RLWRAP:-0}
ENABLE_Z=${ENABLE_Z:-0}

for i; do
    if [ "$i" == '--force' ]; then
        FORCE=1
    elif [ "$i" == '--bootstrap' ]; then
        BOOTSTRAP=1
    elif [ "$i" == '--os-linux' ]; then
        ENABLE_AP=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_LG=1
        ENABLE_RLWRAP=1
        ENABLE_TMUX=1
        ENABLE_GEMS=1
        ENABLE_VIM=1
        ENABLE_Z=1
    elif [ "$i" == '--os-mac' ]; then
        ENABLE_AADBOOK=1
        ENABLE_AP=1
        ENABLE_B1=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_GOOBOOK=1
        ENABLE_LG=1
        ENABLE_KEYRING=1
        ENABLE_MUTT_NOTMUCH_PY=1
        ENABLE_RLWRAP=1
        ENABLE_GEMS=1
        ENABLE_Z=1
    elif [ "$i" == '--os-win-top' ]; then
        ENABLE_AP=1
        ENABLE_B1=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_KEYRING=1
        ENABLE_GEMS=1
        ENABLE_LG=1
        ENABLE_RLWRAP=1
        ENABLE_Z=1
    elif [ "$i" == '--os-win-station' ]; then
        ENABLE_AP=1
        ENABLE_BR=1
        ENABLE_CB=1
        ENABLE_CG=1
        ENABLE_DOTFILES=1
        ENABLE_GEMS=1
        ENABLE_LG=1
        ENABLE_RLWRAP=1
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

(
    if [ $BOOTSTRAP -eq 1 ]; then
        ensure_dir  ".mail"
        ensure_dir  "local/bin"
        ensure_dir  "local/man/man1"
        ensure_dir  "rubygems/bin"
        ensure_link "dotfiles" "dotfiles"
        ensure_link "opt"      "opt"
    fi
)

(
    if [ $ENABLE_DOTFILES -eq 1 ]; then
        cd dotfiles
        bash install.sh "$@"
        ( set +ex . ~/.bashrc )
    fi
)

(
    if [ $ENABLE_AADBOOK -eq 1 ]; then
        cd opt/aadbook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            python3w -m virtualenv venv
            vpython setup.py install \
              --install-scripts=~/local/bin
        fi
    fi
)

(
    if [ $ENABLE_B1 -eq 1 ]; then
        cd opt/bunny1
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            python3w -m virtualenv venv
            vpip install -r requirements.txt
        fi
    fi
)

(
    if [ $ENABLE_BR -eq 1 ]; then
        cd opt/br
        test $FORCE -eq 1 && rm -f ~/local/bin/br
        if [ ! -f ~/local/bin/br ]; then
          make install PREFIX=~/local
        fi
    fi
)

(
    if [ $ENABLE_CB -eq 1 ]; then
        cd opt/cb
        test $FORCE -eq 1 && rm -f ~/local/bin/cb
        if [ ! -f ~/local/bin/cb ]; then
          make install PREFIX=~/local
        fi
    fi
)

(
    if [ $ENABLE_AP -eq 1 ]; then
        cd opt/ap
        test $FORCE -eq 1 && make clean
        if [ ! -d bin ]; then
            make
            make install PREFIX=~/local
        fi
    fi
)

(
    if [ $ENABLE_CG -eq 1 ]; then
        cd opt/cg
        test $FORCE -eq 1 && make clean
        if [ ! -d bin ]; then
            make
            make install PREFIX=~/local
        fi
    fi
)

(
    if [ $ENABLE_GOOBOOK -eq 1 ]; then
        cd opt/goobook
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            python3w -m virtualenv venv
            vpython setup.py install \
              --install-scripts=~/local/bin
        fi
    fi
)

(
    if [ $ENABLE_KEYRING -eq 1 ]; then
        cd opt/keyring
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            python3w -m virtualenv venv
            vpip install -r requirements.txt
        fi
    fi
)

(
    if [ $ENABLE_LG -eq 1 ]; then
        cd opt/lg
        test $FORCE -eq 1 && make clean
        if [ ! -d bin ]; then
            make
            make install PREFIX=~/local
        fi
    fi
)

(
    if [ $ENABLE_MUTT_NOTMUCH_PY -eq 1 ]; then
        cd opt/mutt-notmuch-py
        test $FORCE -eq 1 && rm -rf venv
        if [ ! -d venv ]; then
            virtualenvw venv
            vpython setup.py install \
              --install-scripts=~/local/bin
        fi
    fi
)

(
    if [ $ENABLE_TMUX -eq 1 ]; then
        cd opt/tmux
        test $FORCE -eq 1 && test -f 'tmux' && make clean
        if [ ! -f tmux ]; then
            sh autogen.sh
            ./configure \
              --prefix=$HOME/local \
              --mandir=$HOME/local/man
            make
            make install
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
                    --enable-python3interp=yes \
                    --enable-perlinterp=yes \
                    --enable-cscope \
                    --enable-fail-if-missing \
                    --prefix=$HOME/local \
                    --mandir=$HOME/local/man
            make
            make install
        fi
    fi
)

(
    if [ $ENABLE_GEMS -eq 1 ]; then
        rdoclastine=$(tail -1 /usr/share/rubygems/rubygems/rdoc.rb || echo 'end')
        if [ "$rdoclastine" != 'end' ]; then
            echo \
                'You seem to be running a bogus version of rubygems. ' \
                'If you cannot download a more recent version please' \
                'manually patch the file as discussed here:' \
                'https://github.com/rubygems/rubygems/issues/2483.'
            exit 1
        fi

        gems=$(echo \
          cowsay \
          lolcat \
          tmuxinator \
        )
        for gem in cowsay lolcat tmuxinator; do
            if test $FORCE -eq 1 || ! hash $gem 2>/dev/null; then
                if [ $gem = "tmuxinator" ]; then
                    if [ -n "$OS_WIN" ]; then
                        gem install tmuxinator -v 0.7.1
                    else
                        gem install tmuxinator
                    fi
                else
                    gem install $gem

                fi
            fi
        done
    fi
)

(
    if [ $ENABLE_RLWRAP -eq 1 ]; then
        cd opt/rlwrap
        test $FORCE -eq 1 && make clean
        if [ ! -f src/rlwrap ]; then
            autoreconf --install
            ./configure \
              --prefix=$HOME/local
            make
            make install
        fi
    fi
)

(
    if [ $ENABLE_Z -eq 1 ]; then
        ensure_link "opt/z/z.1" "local/man/man1/z.1"
    fi
)
