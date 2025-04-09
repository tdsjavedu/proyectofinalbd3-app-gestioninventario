const mongoose = require('mongoose');

mongoose.connect('mongodb+srv://josorio408:6GgoPJLAidSsIC7j@historialtransacciones.zfk6fzq.mongodb.net/?retryWrites=true&w=majority&appName=historialTransacciones', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'Error de conexión a MongoDB:'));
db.once('open', () => {
  console.log('Conectado a MongoDB Atlas');
});

module.exports = mongoose;