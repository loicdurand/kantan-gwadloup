const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const reports = db.collection('reports');

const values = {
  sargassesLevel: 2,
  wavesLevel: 2,
  crowdLevel: 2,
  noiseLevel: 2,
  "rating": 1,
};

const beaches = [
  {
    "beachId": "anse-bertrand-plage-de-la-chapelle",
    "beachName": "Anse-Bertrand - Plage de la Chapelle",
    "comment": "Une très jolie plage, avec parfois quelques vagues. Le point fort est l'aire de jeu sur place et la facilité à trouver de l'ombre!",
    ...values
  },
  {
    "beachId": "Bouillante---Plage-de-Malendure",
    "beachName": "Bouillante - Plage de Malendure",
    "comment": "Une jolie plage de sable brun, où l'on voit facilement des tortues marines. Prenez masque et tuba et appréciez.",
    ...values
  },
  {
    "beachId": "Deshaies---Plage-de-la-Grande-Anse",
    "beachName": "Deshaies - Plage de la Grande Anse",
    "comment": "L'une des plus belles plages de l'île. Les vagues peuvent être fortes, mais la vue est incroyable!",
    ...values
  },
  {
    "beachId": "Deshaies---Plage-de-la-Perle",
    "beachName": "Deshaies - Plage de la Perle",
    "imagePat": "deshaies-plage-de-grande-anse-min.jpg",
    "comment": "Cette plage est sublime! Il peut certes y avoir pas mal de vagues, mais ne quittez pas la Guadeloupe sans y être passés.",
    ...values
  },
  {
    "beachId": "Le-Gosier---Plage-de-la-Datcha",
    "beachName": "Le Gosier - Plage de la Datcha",
    "comment": "Vue magnifique sur l'îlet, juste en face. Ambiance festive (comprenez: bruyante), mais le sable est doux et il n'y a pas de vagues.",
    ...values
  },
  {
    "beachId": "Le-Gosier---Ilet-du-Gosier",
    "beachName": "Le Gosier - Îlet du Gosier",
    "comment": "Quel endroit fantastique! Pas de vague, eaux turquoises et sable fin et... Le côté Robinson Crusoé en plus!",
    ...values
  },
  {
    "beachId": "La-desirade---Plage-A-Fifi",
    "beachName": "La désirade - Plage à Fifi",
    "comment": "La Désirade, si vous la visitez en dehors de la saison des sargasses, c'est quelque chose!",
    ...values
  },
  {
    "beachId": "Le-Moule---Plage-de-l'autre-bord",
    "beachName": "Le Moule - Plage de l'autre bord",
    "comment": "Jolie vue, sable doux. Quelques vagues, qui secouent mais amusent beaucoup les enfants!",
    ...values
  },
  {
    "beachId": "Les-Saintes---Plage-du-pain-de-sucre",
    "beachName": "Les Saintes - Plage du pain de sucre",
    "comment": "Le paradis, tout simplement! À voir absolument.",
    ...values
  },
  {
    "beachId": "Marie-Galante---Plage-de-la-Feuillere",
    "beachName": "Marie-Galante - Plage de la Feuillère",
    "comment": "Si vous vous demandez pourquoi tout le monde parle de Marie-Galante!",
    ...values
  },
  {
    "beachId": "Port-Louis---Plage-du-Souffleur",
    "beachName": "Port-Louis - Plage du Souffleur",
    "comment": "Très belle plage. Magnifique, même! L'eau est souvent calme et d'une clarté hallucinante!",
    ...values
  },
  {
    "beachId": "Ste-Anne---Plage-de-la-Caravelle",
    "beachName": "Ste-Anne - Plage de la Caravelle",
    "comment": "La carte postale par excellence: mer calme, eau limpide, sable blanc et cocotiers. Evidemment, beaucoup de monde sur place!",
    ...values
  },
  {
    "beachId": "Ste-Anne---Plage-du-Bourg",
    "beachName": "Ste-Anne - Plage du Bourg",
    "comment": "Très appréciée pour son absence de vagues, la blancheur de son sable et les commerces tout proches. Beaucoup de monde en général.",
    ...values
  },
  {
    "beachId": "Ste-Rose---Plage-de-Cluny",
    "beachName": "Ste-Rose - Plage de Cluny",
    "comment": "Très agréable, pour son sable, pour la vue et pour son authenticité. Peut-être parfois bruyante, mais l'une de nos préférées malgré tout!",
    ...values
  },
  {
    "beachId": "St-Francois---Plage-des-raisins-clairs",
    "beachName": "St-François - Plage des raisins clairs",
    "comment": "St-François, ça vaut le détour! Ne serait-ce pour tout ce que l'on peut faire sur place.",
    ...values
  }

];

async function deleteReports() {
  try {
    const snapshot = await reports.get();
    for (const doc of snapshot.docs) {
      const data = doc.data();
      await reports.doc(doc.id).delete();
      console.log(`Supprimé : ${data.beachName}`);
    }
    console.log('Phase de suppression terminée.');
  } catch (error) {
    console.error('Erreur :', error);
  }
}

async function insertBeaches() {
  try {
    for (const beach of beaches) {
      beach.beachId = beach.beachId.toLocaleLowerCase().replace('---', '-');
      await reports.add(beach);
      console.log(`Inséré : ${beach.beachName} (beachId: ${beach.beachId})`);
    }
    console.log('Migration terminée !');
  } catch (error) {
    console.error('Erreur lors de l\'insertion :', error);
  }
}

deleteReports().then(() => {
  // process.exit(0);
  insertBeaches().then(() => process.exit(0));


});
