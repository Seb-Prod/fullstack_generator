import mysql from 'mysql2/promise'
import dotenv from 'dotenv'

dotenv.config()

// Configuration de la base de données
const dbConfig = {
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
}

// Création du pool de connexions
export const pool = mysql.createPool(dbConfig)

// Fonction de test de connexion
export const testConnection = async () => {
  try {
    const connection = await pool.getConnection()
    console.log('✅ Connexion à la base de données réussie')
    connection.release()
    return true
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données:', error)
    return false
  }
}

// Service de base de données
export class DatabaseService {
  static async query(sql: string, params?: any[]) {
    try {
      const [results] = await pool.execute(sql, params)
      return results
    } catch (error) {
      console.error('Erreur lors de l\'exécution de la requête:', error)
      throw error
    }
  }

  static async getConnection() {
    return await pool.getConnection()
  }
}

// Test de connexion au démarrage
testConnection()
