import { useState, useEffect } from 'react'
import styles from './App.module.css'
import { apiService } from './services/apiService'

function App() {
  const [pingResult, setPingResult] = useState<string>('')
  const [loading, setLoading] = useState(false)

  const testConnection = async () => {
    setLoading(true)
    try {
      const result = await apiService.ping()
      setPingResult(result)
    } catch (error) {
      setPingResult('Erreur de connexion à l\'API')
      console.error('Erreur:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    testConnection()
  }, [])

  return (
    <div className={styles.app}>
      <header className={styles.header}>
        <h1>Mon Projet Fullstack</h1>
        <p>React + TypeScript + Express</p>
      </header>

      <main className={styles.main}>
        <div className={styles.card}>
          <h2>Test de connexion API</h2>
          <button 
            onClick={testConnection} 
            disabled={loading}
            className={styles.button}
          >
            {loading ? 'Test en cours...' : 'Tester la connexion'}
          </button>
          
          {pingResult && (
            <div className={styles.result}>
              <strong>Résultat:</strong> {pingResult}
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

export default App
