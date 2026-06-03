// migrate_beaches.js
const admin = require('firebase-admin');

// Remplace par ton fichier JSON de service account (voir Étape 3)
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const reports = db.collection('reports');

async function migrateReports() {
  try {
    const snapshot = await reports.get();
    for (const doc of snapshot.docs) {
      const data = doc.data();
      await reports.doc(doc.id).update({
        beachId: data.beachId,
        beachName: data.beachName,
        comment: data.comment,
        sargassesLevel: 2,
        wavesLevel: 2,
        crowdLevel: 2,
        noiseLevel: 2,
        rating: 1,
      });
      console.log(`Migré : ${data.beachName}`);
    }
    console.log('Migration terminée !');
  } catch (error) {
    console.error('Erreur :', error);
  }
}

migrateReports().then(() => process.exit());