// server.js
const express = require('express');
const bodyParser = require('body-parser');

const port = 3000;

//importar rutas
const historialRoutes = require('./routes/syncRoutes');

const app = express();

// Middleware
app.use(bodyParser.json());

//Usar las rutas

app.use('/api/historial', historialRoutes);

//app.listen(3000, () => {
  //console.log('Servidor escuchando en puerto 3000');
//});





// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
