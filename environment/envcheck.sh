
#!/bin/bash -e
figlet "ENVCHECK"

printf "Checking Environment Integrity.\n\n"

echo "[ENVCHECK] Checking if .bashrc is beeing sorced by bash."
if [ -z ${BASHPROFILE+x} ]; then
  echo "[ENVCHECK] Adding 'source ~/.bashrc' to ~/.bash_profile"
  echo 'export BASHPROFILE="TRUE"' >> ~/.bashrc
  echo 'source ~/.bashrc' >> ~/.bash_profile
else
  echo "[ENVCHECK] Great! Bash"
fi

echo "[ENVCHECK] Checking for JAVA_HOME env var."
if [ -z ${JAVA_HOME+x} ]; then
  echo "[ENVCHECK] Adding JAVA_HOME to .bashrc file."
  echo 'export JAVA_HOME="/opt/jdk"' >> ~/.bashrc
else
  echo "[ENVCHECK] Great! JAVA_HOME exists! Moving on..."
fi

echo "[ENVCHECK] Checking for ANDROID_HOME env var."
if [ -z ${ANDROID_HOME+x} ]; then
  echo "[ENVCHECK] Adding ANDROID_HOME to .bashrc file."
  #TODO: Change this to a generic expression
  echo 'export ANDROID_HOME="/home/skraelings/Android/Sdk"' >> ~/.bashrc
else
  echo "[ENVCHECK] Great! ANDROID_HOME exists! Moving on..."
fi

echo "[ENVCHECK] Checking if Test Running Folder exists."
if [ -d "/testcloud/workspace" ]; then
  echo "[ENVCHECK] /testcloud/workspace folder exists"
else
  echo "[ENVCHECK] Creating /testcloud/workspace folder"
  mkdir -p /testcloud/workspace

  echo "Installing Testcloud Base dependencies"
  cd /testcloud/workspace
  rvm --rvmrc --create use 2.3@calabash
  gem install calabash-common
  gem install cucumber
  gem install calabash-cucumber
  gem install calabash-android
  gem install bundler
fi

echo "[ENVCHECK] Checking if mongodb folder exists."
if [ -d "/data/db" ]; then
  echo "[ENVCHECK] '/data/db' folder exists."
else
  echo "[ENVCHECK] Couldn't find mongodb /data/db folder. Creating"
  mkdir -p /data/db
fi

echo '[ENVCHECK] Checking for Android Key for Calabash-Android.'
cd
if [ -d ".android" ]; then
  echo "[ENVCHECK] '~/.android' folder exists."
else
  echo "[ENVCHECK] couldn't find '~/.android' folder."
  keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
fi

echo "[ENVCHECK] Checking if STF folder exists."
if [ -d "/testcloud/stf" ]; then
  echo "[ENVCHECK] /testcloud/stf folder exists"
else
  echo "[ENVCHECK] Creating /testcloud/stf folder"
  mkdir -p /testcloud/stf/log
fi
