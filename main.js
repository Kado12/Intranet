const express = require('express')
const app = express()
const dotenv = require('dotenv')
dotenv.config({path:'./env/.env'})
const {join} = require('path')
const connection = require('./database/db.js')
app.set('views', join(__dirname, 'views'))
app.set('view engine', 'ejs')
app.use(express.static(join(__dirname, 'public')))

/*app.get('/', (req, res)=>{
    const query = 'SELECT * FROM estudiantes'
    connection.query(query, (err, result)=>{
        if(err){
            throw err
        }
        res.render('index', {data: result})
    })
})*/











// Guardar el puerto en una variable
const PUERTO = process.env.PORT || 3000 
// Inicializar el servidor
app.listen(PUERTO)
console.log(`EL SERVIDOR ESTÁ CONECTADO EN EL PUERTO: ${PUERTO}`)