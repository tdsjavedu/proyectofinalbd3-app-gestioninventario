const mysql = require('../db/mysql');
const mongoose = require('../db/mongo');

// Modelo de Mongo
const TransaccionSchema = new mongoose.Schema({
    idTransaccion: Number,
    fecha: Date,
    Producto_idProducto: Number,
    Usuarios_idUsuarios: Number,
    cantidad: Number,
    Usuario_Almacenes_idAlmacenes: Number,
    cantidad: Number,
});
const Transaccion = mongoose.model('Transaccion', TransaccionSchema);

exports.sincronizarTransacciones = (req, res) => {
    console.log('Iniciando sincronización desde MySQL...');
  mysql.query('SELECT * FROM transacciones', async (err, resultados) => {
    if (err) {
        console.error('Error en consulta MySQL:', err);
        return res.status(500).send(err);
    }


    console.log(`Se encontraron ${resultados.length} registros en MySQL.`);
    console.log('Datos obtenidos de MySQL:', resultados);

    try {
      await Transaccion.deleteMany({});
      console.log('Colección Mongo limpia.');
        // Insertar los resultados en MongoDB
      await Transaccion.insertMany(resultados);
      console.log('Datos insertados en MongoDB correctamente.');

      res.status(200).send('Sincronización completada con MongoDB');
    } catch (mongoError) {
        console.error('Error insertando en MongoDB:', mongoError);
      res.status(500).send(mongoError);
    }
  });
};

exports.simularTransaccion = async (req, res) => {
  const nueva = new Transaccion(req.body);
  try {
    await nueva.save();
    res.status(201).send('Transacción histórica guardada');
  } catch (err) {
    res.status(500).send(err);
  }
};