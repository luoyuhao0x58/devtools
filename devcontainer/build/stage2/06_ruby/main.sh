#! /bin/bash
set +u -exo pipefail

versions=$@

source "$BUILD_UTILS_PATH"

gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
gitclone https://github.com/rvm/rvm.git rvm
sed "s|DEFAULT_SOURCES=(github.com/rvm/rvm bitbucket.org/mpapis/rvm)|DEFAULT_SOURCES=(bitbucket.org/mpapis/rvm)|" rvm/binscripts/rvm-installer | bash -s stable
echo "ruby_url=$MIRROR_RUBY_BIN" >>~/.rvm/user/db

source ~/.bash_profile

for version in $versions; do
  rvm install $version
done
rvm use $version --default
gem sources --remove "$(gem sources | tail -n 1)"
gem sources -a "$MIRROR_RUBY_GEM"