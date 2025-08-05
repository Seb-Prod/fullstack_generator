import { Request, Response } from 'express'

export const pingController = {
  ping: (req: Request, res: Response) => {
    try {
      res.json({
        message: 'pong',
        timestamp: new Date().toISOString(),
        server: 'Express + TypeScript',
        status: 'OK'
      })
    } catch (error) {
      console.error('Erreur dans pingController:', error)
      res.status(500).json({
        error: 'Erreur lors du ping',
        message: error instanceof Error ? error.message : 'Erreur inconnue'
      })
    }
  }
}
