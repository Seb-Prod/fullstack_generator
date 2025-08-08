const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Vérifier si un argument de ligne de commande a été fourni
const inputPath = process.argv[2];
const targetDirectory = process.argv[3]; // Nouveau paramètre optionnel

if (inputPath) {
  // Mode ligne de commande (comme le premier script)
  createComponent(inputPath, targetDirectory);
} else {
  // Mode interactif (comme le second script)
  rl.question('🧱 Nom du composant (ou chemin/nom pour sous-dossiers) : ', (input) => {
    if (!input) {
      console.error('❌ Nom invalide.');
      rl.close();
      process.exit(1);
    }
    
    rl.question('📁 Dossier cible (components/pages/hooks/utils ou chemin personnalisé) [components] : ', (directory) => {
      rl.close();
      createComponent(input, directory || 'components');
    });
  });
}

function createComponent(inputPath, targetDirectory = 'components') {
  // Séparer le chemin et le nom du composant
  const pathParts = inputPath.split(/[\/\\]/);
  let rawComponentName = pathParts[pathParts.length - 1];

  // Forcer la majuscule sur la première lettre du composant
  const componentName = rawComponentName.charAt(0).toUpperCase() + rawComponentName.slice(1);

  // Reconstruire le chemin cible avec le dossier spécifié
  const componentPathParts = [...pathParts.slice(0, -1), componentName];
  const baseDir = path.join(__dirname, '..', 'client', 'src', targetDirectory, ...componentPathParts);

  const tsxFile = path.join(baseDir, `${componentName}.tsx`);
  const cssFile = path.join(baseDir, `${componentName}.module.css`);
  const indexFile = path.join(baseDir, `index.ts`);

  // Vérifier si le composant existe déjà
  if (fs.existsSync(tsxFile)) {
    console.error(`❌ Le composant "${componentName}" existe déjà dans ${baseDir}`);
    process.exit(1);
  }

  // Templates
  const tsxContent = `import React from 'react';
import styles from './${componentName}.module.css';

interface ${componentName}Props {
  /** Classes CSS additionnelles */
  className?: string;
  /** Contenu enfant du composant */
  children?: React.ReactNode;
  // Ajouter d'autres props ici
}

/**
 * Composant ${componentName} - Description du composant
 * 
 * @param props - Les propriétés du composant ${componentName}
 * @param props.text - Texte affiché dans le bouton
 * @returns JSX.Element
 * 
 * @example
 * \`\`\`tsx
 * <${componentName} className="custom-class">
 *   Contenu du composant
 * </${componentName}>
 * \`\`\`
 */
const ${componentName}: React.FC<${componentName}Props> = () => {
  return (
    <div className={styles.container}>
      <h2>${componentName}</h2>
    </div>
  );
};

export default ${componentName};
`;

  const cssContent = `.container {
  padding: 1rem;
  background-color: #f9f9f9;
  border-radius: 8px;
}
`;

  const indexContent = `export { default } from './${componentName}';
`;

  // Création du dossier
  if (!fs.existsSync(baseDir)) {
    fs.mkdirSync(baseDir, { recursive: true });
  }

  // Création des fichiers
  try {
    fs.writeFileSync(tsxFile, tsxContent);
    fs.writeFileSync(cssFile, cssContent);
    fs.writeFileSync(indexFile, indexContent);

    // Message de succès
    const relativePath = pathParts.join('/');
    console.log(`✅ Composant "${componentName}" créé dans client/src/${targetDirectory}/${relativePath}/`);
    console.log(`📁 Fichiers créés :`);
    console.log(`   - ${componentName}.tsx`);
    console.log(`   - ${componentName}.module.css`);
    console.log(`   - index.ts`);
    console.log(`\n👉 Exemple d'import :`);
    console.log(`import ${componentName} from '@/${targetDirectory}/${relativePath}';`);
    console.log(`\n<${componentName} />`);
  } catch (error) {
    console.error(`❌ Erreur lors de la création des fichiers : ${error.message}`);
    process.exit(1);
  }
}