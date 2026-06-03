#!/bin/bash

git init 2>/dev/null || true

# Mise à jour et paquets de base (inclut JDK 17 pour le SDK Android)
sudo apt-get update && sudo apt-get install -y cmake curl git unzip xz-utils zip libglu1-mesa wget openjdk-17-jdk-headless

# JAVA_HOME doit être défini avant toute utilisation du SDK Android
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Installation Flutter (stable 3.27.0)
FLUTTER_VERSION="3.27.0"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}
tar xf ${FLUTTER_ARCHIVE}
sudo mv flutter /opt/flutter
sudo chown -R ubuntu:ubuntu /opt/flutter

# ANDROID_HOME doit être défini dans le shell courant AVANT son utilisation
export ANDROID_HOME=/opt/android-sdk

# Persistance dans .bashrc : ANDROID_HOME en premier pour que PATH puisse le référencer
grep -q 'ANDROID_HOME' /home/ubuntu/.bashrc || {
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /home/ubuntu/.bashrc
  echo 'export ANDROID_HOME=/opt/android-sdk' >> /home/ubuntu/.bashrc
  echo 'export PATH="$PATH:/opt/flutter/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"' >> /home/ubuntu/.bashrc
  echo 'export ADB_SERVER_SOCKET=tcp:host.docker.internal:5037' >> /home/ubuntu/.bashrc
}

# Installation Android SDK CLI
sudo mkdir -p $ANDROID_HOME/cmdline-tools
sudo chown -R ubuntu:ubuntu $ANDROID_HOME
cd $ANDROID_HOME/cmdline-tools

# Télécharge SDK Tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip
mv cmdline-tools latest
rm -f cmdline-tools.zip
chmod +x $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager

# Acceptation licences
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

# Installation paquets essentiels
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "cmake;3.22.1"

# Installation Node.js 22.x LTS
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation Firebase CLI 13.7.0
sudo npm install -g firebase-tools@13.7.0

# Config Flutter
export PATH="$PATH:/opt/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
flutter precache
flutter doctor --android-licenses

echo "Environnement CLI prêt ! Android SDK installé manuellement."
echo "Vérifiez: 'flutter doctor' et 'adb version'."