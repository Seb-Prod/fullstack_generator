const fs = require('fs');
const path = require('path');

const inputPath = process.argv[2];

if (!inputPath) {
  console.error('❌ Merci de spécifier un nom de composant avec son chemin (relatif à componants/).');
  console.error('Ex: npm run create:component Sidebar/components/SidebarItem');
  process.exit(1);
}

// Séparer le chemin et le nom du composant
const pathParts = inputPath.split(/[\/\\]/);
let rawComponentName = pathParts[pathParts.length - 1];

// Forcer la majuscule sur la première lettre du composant
const componentName = rawComponentName.charAt(0).toUpperCase() + rawComponentName.slice(1);

// Reconstruire le chemin cible
const componentPathParts = [...pathParts.slice(0, -1), componentName];
const baseDir = path.join(__dirname, '..', 'client', 'src', 'componants', ...componentPathParts);

const tsxFile = path.join(baseDir, `${componentName}.tsx`);
const cssFile = path.join(baseDir, `${componentName}.module.css`);
const indexFile = path.join(baseDir, `index.ts`);

// Templates
const tsxContent = `import React from 'react';
import styles from './${componentName}.module.css';

interface ${componentName}Props {
  // Ajoute tes props ici
}

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
fs.writeFileSync(tsxFile, tsxContent);
fs.writeFileSync(cssFile, cssContent);
fs.writeFileSync(indexFile, indexContent);

// Message de succès
const relativePath = pathParts.join('/');
console.log(`✅ Composant "${componentName}" créé dans client/src/components/${relativePath}/`);

console.log(`
👉 Exemple d'import :
import ${componentName} from '@/componants/${relativePath}';

<${componentName} />
`);