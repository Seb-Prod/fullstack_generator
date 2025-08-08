#!/usr/bin/env node

// Clear console
console.clear();
console.log("🚀 Lancement de l'environnement de développement...\n");

const { spawn } = require("child_process");
const { exec } = require("child_process");
const path = require("path");

let concurrentlyProcess;
let isShuttingDown = false;

function startServices() {
  concurrentlyProcess = spawn(
    "npx",
    [
      "concurrently",
      "--names",
      "💻 CLIENT,📡 SERVER",
      "--prefix-colors",
      "cyan,magenta",
      "--prefix",
      "{name}",
      "--kill-others-on-fail",
      "--handle-input",
      "npm run dev --prefix client",
      "npm run dev --prefix server",
    ],
    { 
      stdio: "pipe",
      detached: false
    }
  );

  // Rediriger les sorties vers la console avec filtrage
  concurrentlyProcess.stdout.on('data', (data) => {
    if (!isShuttingDown) {
      process.stdout.write(data);
    }
  });

  concurrentlyProcess.stderr.on('data', (data) => {
    if (!isShuttingDown) {
      const dataStr = data.toString();
      // Filtrer les messages d'arrêt de concurrently
      const shutdownMessages = [
        'exited with code',
        'Sending SIGTERM to other processes',
        'SIGTERM received'
      ];
      
      const shouldFilter = shutdownMessages.some(msg => dataStr.includes(msg));
      
      if (!shouldFilter) {
        process.stderr.write(data);
      }
    }
  });

  concurrentlyProcess.on("close", (code) => {
    if (!isShuttingDown) {
      if (code === 0) {
        console.log("\n✅ Services arrêtés proprement. À bientôt !");
      } else {
        console.log("\n⚠️  Services arrêtés. À bientôt !");
      }
      process.exit(0);
    }
  });

  concurrentlyProcess.on("error", (err) => {
    console.error("❌ Erreur lors du démarrage:", err.message);
    if (!isShuttingDown) {
      process.exit(1);
    }
  });
}

function gracefulShutdown(signal = 'SIGTERM') {
  if (isShuttingDown) return;
  
  isShuttingDown = true;
  console.log("\n🛑 Arrêt des services en cours...");
  
  if (concurrentlyProcess && !concurrentlyProcess.killed) {
    // Essayer d'abord un arrêt gracieux
    concurrentlyProcess.kill(signal);
    
    // Si le processus ne se ferme pas dans les 5 secondes, forcer l'arrêt
    setTimeout(() => {
      if (concurrentlyProcess && !concurrentlyProcess.killed) {
        console.log("⚡ Arrêt forcé des services...");
        concurrentlyProcess.kill('SIGKILL');
      }
    }, 5000);
  }
  
  // Nettoyer stdin
  if (process.stdin.isRaw) {
    process.stdin.setRawMode(false);
  }
  
  // Attendre un peu plus longtemps pour que les processus se terminent proprement
  // avant d'afficher le message final
  setTimeout(() => {
    console.log("👋 Services arrêtés. À bientôt !");
    process.exit(0);
  }, 1500);
}

// Démarrer les services
startServices();

// Messages après démarrage (attendre quelques secondes)
setTimeout(() => {
  console.log("\n⚡ Raccourcis utiles :");
  console.log("   • Ctrl+C pour arrêter les services");
  console.log("   • o pour ouvrir dans le navigateur");
  console.log("   • q pour quitter");
  console.log("   • r pour redémarrer");
  console.log("   • h pour l'aide");
  console.log("\n✨ Bon développement ! ✨\n");

  // Activer les raccourcis clavier
  setupKeyboardShortcuts();
}, 3000);

function setupKeyboardShortcuts() {
  // S'assurer que stdin est en mode raw et écoute
  if (!process.stdin.isRaw) {
    process.stdin.setRawMode(true);
  }
  if (process.stdin.isPaused()) {
    process.stdin.resume();
  }
  process.stdin.setEncoding("utf8");

  // Enlever les anciens listeners pour éviter les doublons
  process.stdin.removeAllListeners("data");

  process.stdin.on("data", (key) => {
    // Ctrl+C
    if (key === "\u0003") {
      gracefulShutdown('SIGINT');
      return;
    }

    // Touche 'o' pour ouvrir le navigateur
    if (key === "o" || key === "O") {
      console.log("\n🌐 Ouverture du navigateur...\n");
      const command =
        process.platform === "win32"
          ? "start"
          : process.platform === "darwin"
          ? "open"
          : "xdg-open";
      exec(`${command} http://localhost:{{ FRONTEND_PORT }}`, (error) => {
        if (error) {
          console.log("⚠️  Impossible d'ouvrir le navigateur automatiquement");
          console.log("🔗 Ouvrez manuellement : http://localhost:{{ FRONTEND_PORT }}");
        }
      });
    }

    // Touche 'c' pour ouvrir Visual Studio Code
    if (key === "c" || key === "C") {
      console.log("\n💻 Ouverture de Visual Studio Code...\n");
      exec("code .", (error) => {
        if (error) {
          console.log("⚠️  Impossible d'ouvrir VS Code automatiquement");
          console.log("💡 Vérifiez que 'code' est dans votre PATH ou ouvrez VS Code manuellement");
        }
      });
    }

    // Touche 'q' pour quitter
    if (key === "q" || key === "Q") {
      gracefulShutdown();
      return;
    }

    // Touche 'r' pour redémarrer
    if (key === "r" || key === "R") {
      console.log("\n🔄 Redémarrage des services...\n");
      isShuttingDown = true;
      
      if (concurrentlyProcess && !concurrentlyProcess.killed) {
        concurrentlyProcess.kill('SIGTERM');
      }
      
      setTimeout(() => {
        isShuttingDown = false;
        startServices();
      }, 2000);
    }

    // Afficher l'aide avec 'h'
    if (key === "h" || key === "H") {
      console.log("\n📖 Aide - Raccourcis disponibles :");
      console.log("   • o = Ouvrir dans le navigateur (http://localhost:3000)");
      console.log("   • c = Ouvrir dans Visual Studio Code");
      console.log("   • q = Quitter proprement");
      console.log("   • r = Redémarrer les services");
      console.log("   • h = Afficher cette aide");
      console.log("   • Ctrl+C = Arrêter\n");
    }
  });
}

// Gérer les signaux système
process.on("SIGINT", () => gracefulShutdown('SIGINT'));
process.on("SIGTERM", () => gracefulShutdown('SIGTERM'));

// Gérer la fermeture inattendue
process.on("beforeExit", () => {
  if (concurrentlyProcess && !concurrentlyProcess.killed) {
    concurrentlyProcess.kill('SIGTERM');
  }
});

// Gérer les erreurs non capturées
process.on("uncaughtException", (error) => {
  console.error("❌ Erreur non capturée:", error.message);
  gracefulShutdown();
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ Promesse rejetée non gérée:", reason);
  gracefulShutdown();
});