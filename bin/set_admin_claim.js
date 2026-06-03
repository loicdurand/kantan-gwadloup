/**
 * Script pour définir le custom claim "admin" sur un utilisateur Firebase.
 *
 * Usage :
 *   node bin/set_admin_claim.js <email>
 *
 * Prérequis :
 *   - Placer le fichier serviceAccountKey.json dans le dossier bin/
 *   - Installer firebase-admin : npm install firebase-admin
 *
 * Exemple :
 *   node bin/set_admin_claim.js mon.email@gmail.com
 */

const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const email = process.argv[2];

if (!email) {
  console.error('❌ Veuillez fournir un email : node bin/set_admin_claim.js <email>');
  process.exit(1);
}

async function setAdminClaim() {
  try {
    // Recherche de l'utilisateur par email
    const userRecord = await admin.auth().getUserByEmail(email);
    console.log(`✅ Utilisateur trouvé : ${userRecord.displayName || userRecord.email} (${userRecord.uid})`);

    // Définition du custom claim admin
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });
    console.log(`🎉 Custom claim "admin: true" défini avec succès pour ${email}`);

    // Vérification
    const updatedUser = await admin.auth().getUser(userRecord.uid);
    console.log(`📋 Claims actuels : ${JSON.stringify(updatedUser.customClaims)}`);
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.error(`❌ Aucun utilisateur trouvé avec l'email : ${email}`);
      console.error('   L\'utilisateur doit d\'abord se connecter via Google Sign-In pour apparaître dans Firebase Auth.');
    } else {
      console.error('❌ Erreur :', error.message);
    }
    process.exit(1);
  }
}

setAdminClaim().then(() => process.exit(0));