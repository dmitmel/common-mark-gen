#!/usr/bin/env bash


set -e

COMMON_MARK_GEN_HOME="$HOME/.common-mark-gen"
[ ! -d "$COMMON_MARK_GEN_HOME" ] && mkdir $COMMON_MARK_GEN_HOME

clear
cat << EOF
Welcome to CommonMark generator installer!
It'll automatically install generator script and all it's dependencies, if they're missing.

It'll install this things:
1. Ruby
2. Node.js
3. JavaScript libraries:
    3.1. highlight.js
    3.2. markdown-it
    3.3. markdown-it-abbr
    3.4. markdown-it-checkbox
    3.5. markdown-it-sub
    3.6. markdown-it-sup
    3.7. markdown-it-anchor
4. Github's Markdown CSS style to $COMMON_MARK_GEN_HOME/github-markdown.css
5. installing CommonMark helper generator script
6. installing CommonMark main generator script

Press any key to continue or ctrl+c to exit.
EOF

read -n 1
clear


echo "Step 1: installing Ruby"
echo
if [ "$(which ruby)" == "" ]; then
    echo "Ruby isn't installed on your machine."
    echo

    echo "[1] apt (Debian or Ubuntu)"
    echo "[2] yum (CentOS, Fedora, or RHEL)"
    echo "[3] portage (Gentoo)"
    echo "[4] pacman (Arch Linux)"
    echo "[5] Homebrew (OS X)"
    echo "[6] rvm"


    read -rp "Which way do you want to use to install Ruby? (1-6) " choice
    echo

    case "$choice" in
        1) sudo apt-get install ruby-full ;;
        2) sudo yum install ruby ;;
        3) sudo emerge dev-lang/ruby ;;
        4) sudo pacman -S ruby ;;
        5) brew install ruby ;;
        6) rvm install ruby --latest ;;
        *) echo "Not a valid choice." >&2
           exit 1 ;;
    esac
fi
clear


echo "Step 2: installing Node.js"
echo
if [ "$(which node)" == "" ]; then
    echo "Node.js isn't installed on your machine."
    echo

    echo "[1] apt (Debian or Ubuntu)"
    echo "[2] yum (CentOS, Fedora, or RHEL)"
    echo "[3] portage (Gentoo)"
    echo "[4] pacman (Arch Linux)"
    echo "[5] Homebrew (OS X)"
    echo "[6] pkg-ng (FreeBSD)"
    echo "[7] pkgin (NetBSD, SmartOS or illumos)"
    echo "[8] MacPorts (OS X)"
    echo "[9] xbps (Void Linux)"


    read -rp "Which way do you want to use to install Node.js? (1-9) " choice
    echo

    case "$choice" in
        1) sudo apt-get install nodejs npm ;;
        2) sudo yum install nodejs npm ;;
        3) sudo emerge nodejs ;;
        4) sudo pacman -S nodejs npm ;;
        5) brew install ruby ;;
        6) pkg install node ;;
        7) pkgin -y install nodejs ;;
        8) port install nodejs ;;
        9) xbps-install -Sy nodejs ;;
        *) echo "Not a valid choice." >&2
           exit 1 ;;
    esac
fi
clear


libs="highlight.js
markdown-it
markdown-it-abbr
markdown-it-checkbox
markdown-it-sub
markdown-it-sup
markdown-it-anchor"
echo "Step 3: installing JavaScript libraries:
$libs"
echo
npm install $(echo $libs | sed ':a;N;$!ba;s/\n/ /g')
clear


echo "Step 4: installing Github's Markdown CSS style"
echo
DEST_FILE="$COMMON_MARK_GEN_HOME/github-markdown.css"
curl https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css -o $DEST_FILE
clear

echo "Step 5: installing CommonMark helper generator script"
echo
DEST_FILE="$COMMON_MARK_GEN_HOME/md-to-html.js"
curl https://raw.githubusercontent.com/dmitmel/common-mark-gen/master/md-to-html.js -o $DEST_FILE
clear

echo "Step 6: installing CommonMark main generator script"
echo
DEST_FILE="$COMMON_MARK_GEN_HOME/common-mark-gen"
curl https://raw.githubusercontent.com/dmitmel/common-mark-gen/master/common-mark-gen.sh -o $DEST_FILE
chmod +x $DEST_FILE
clear
