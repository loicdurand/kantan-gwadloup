# Étapes à exécuter dans le terminal pour installer tous les outils (Arch Linux)

  ## 1. Installer Flutter, Java, Node.js et Android SDK
  paru -S --needed jdk-openjdk nodejs npm flutter android-sdk android-sdk-platform-tools

  ## 2. Configurer les variables d'environnement (ajoute dans ~/.config/fish/config.fish)
  ## set -x ANDROID_HOME /opt/android-sdk
  ## set -x PATH $PATH $ANDROID_HOME/platform-tools $ANDROID_HOME/cmdline-tools/latest/bin

  ## 3. Accepter les licences Android
  flutter doctor --android-licenses

  ## 4. Installer Firebase CLI (nécessite Node.js)
  npm install -g firebase-tools

  ## 5. Installer FlutterFire CLI
  dart pub global activate flutterfire_cli

  ## 6. Ajouter le path Dart dans fish config
  ## set -x PATH $PATH $HOME/.pub-cache/bin

  ## 7. Recharger le shell
  ## source ~/.config/fish/config.fish

  ## 8. Dans le dossier du projet
  flutter pub get
  flutterfire configure   # (nécessite un login Firebase)

  ## 9. Vérifier que tout est OK
  flutter doctor
