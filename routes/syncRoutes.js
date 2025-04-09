const express = require('express');
const router = express.Router();
const controller = require('../controllers/syncController');

// Ruta para sincronizar desde MySQL a MongoDB
router.get('/sync', controller.sincronizarTransacciones);

// Ruta para simular transacción (enviar desde Postman)
router.post('/simular', controller.simularTransaccion);

module.exports = router;