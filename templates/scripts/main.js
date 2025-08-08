#!/usr/bin/env node

const readline = require('readline');
const { spawn } = require('child_process');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.clear();
console.log('🛠️ Générateur interactif');
console.log('--------------------------');
console.log('1 - Générer un composant React');
console.log('2 - Générer un hook personnalisé');
console.log('3 - Générer une page');
console.log('4 - Annuler');
console.log('--------------------------');

rl.question('👉 Que souhaites-tu générer ? [1-4] : ', (answer) => {
  rl.close();

  const scriptMap = {
    '1': 'generate-component.js',
    '2': 'generate-hook.js',
    '3': 'generate-page.js'
  };

  const scriptName = scriptMap[answer];

  if (!scriptName) {
    console.log('\n❌ Opération annulée.\n');
    process.exit(0);
  }

  const scriptPath = path.join(__dirname, scriptName);
  const child = spawn('node', [scriptPath], {
    stdio: 'inherit'
  });

  child.on('close', (code) => {
    console.log(`✅ Script "${scriptName}" terminé avec le code ${code}`);
  });

  child.on('error', (err) => {
    console.error('❌ Erreur lors de l\'exécution du script :', err);
  });
});