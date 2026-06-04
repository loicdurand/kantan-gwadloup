Étapes pour l'auth Google

  1. Obtenir votre empreinte SHA-1 de debug

  Si le keystore n'existe pas encore, génère-le d'abord :

  keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"

  Puis récupère l'empreinte :

  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

  Copiez la valeur SHA1 affichée.

  2. Ajouter l'empreinte dans la Firebase Console

  1. Allez sur https://console.firebase.google.com
  2. Sélectionnez le projet sablessargasses
  3. ⚙ Paramètres du projet → onglet General
  4. Dans la section de votre app Android (com.loicdurand.sargassoti), cliquez sur Add fingerprint
  5. Collez votre SHA-1

  3. Re-télécharger google-services.json

  Toujours dans les paramètres Firebase, téléchargez le nouveau google-services.json et placez-le dans android/app/.

  4. (Optionnel) Re-générer firebase_options.dart

  flutterfire configure

  Cela mettra à jour lib/firebase_options.dart avec la config la plus récente.

  5. Vérifier que Google Sign-In est activé

  Dans la Firebase Console → Authentication → Sign-in method, assurez-vous que Google est activé.
