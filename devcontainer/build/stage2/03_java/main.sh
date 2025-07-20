#! /bin/bash
set +u

versions=$@

curl -s "https://get.sdkman.io?ci=true&rcupdate=false" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

for version in $versions; do
  sdk install java $version
done
sdk default java $version

echo 'source "$HOME/.sdkman/bin/sdkman-init.sh"' >>~/.bashrc