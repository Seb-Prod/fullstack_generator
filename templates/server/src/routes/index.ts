import { Router } from 'express'
import { pingController } from '../controllers/pingController'

const router = Router()

// Route de test
router.get('/ping', pingController.ping)

// Ajouter d'autres routes ici
// router.use('/users', userRoutes)
// router.use('/auth', authRoutes)

export default router
