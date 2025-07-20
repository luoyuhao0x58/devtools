#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y gnupg2 pinentry-tty

# configure gnupg
rm -rf ~/.gnupg && mkdir ~/.gnupg
echo 'export GPG_TTY=$(tty)' >>~/.bashrc
printf 'pinentry-program /usr/bin/pinentry\ndefault-cache-ttl 604800\nmax-cache-ttl 604800\n' >~/.gnupg/gpg-agent.conf
chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/gpg-agent.conf