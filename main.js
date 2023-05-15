const express = require('express')
const app = express()
app.use(express.urlencoded({ extended:false}))
app.use(express.json())
const session = require('express-session')
app.use(session({
    secret: 'secret',
    resave: true,
    saveUninitialized: true
}))
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

// Hla poncho
// Ruta de pagina de Logeo
app.get('/',(req,res)=>{
    res.render('index')
})
// Autenticación de inicio de sesión 
app.post('/auth', async (req, res)=>{
    const user = req.body.user
    const pass = req.body.pass
    if(user && pass){
        connection.query("SELECT * FROM usuario WHERE usr_id = ?", [user], async (err, results)=>{
            if (results.length == 0 || !(await pass == results[0].usr_pass)){
                res.render('index',{
                    alert: true,
                    alertTitle: "Error",
                    alertMessage: "Usuario o Contraseña incorrecta",
                    alertIcon: "error",
                    showConfirmButton: true,
                    timer: false,
                    ruta: ''
                })
            } else {
                const tipo = results[0].tip_id
                if(tipo == 1){
                    ruta = 'maine'
                }
                if(tipo == 2){
                    ruta = 'mainp'
                }
                if(tipo == 3){
                    ruta = 'maind'
                }
                req.session.ruta = 'maine'
                req.session.type = results[0].tip_id
                req.session.loggedin = true
                req.session.name =results[0].usr_nombres +' '+ results[0].usr_apellidos
                res.render('index', {
                    alert: true,
                    alertTitle: "Conexion exitosa",
                    alertMessage: "Ingreso correcto",
                    alertIcon: "success",
                    showConfirmButton: false,
                    timer: 1500,
                    ruta: `${ruta}`
                })
            }
        })
    } else {
        res.render('index', {
            alert: true,
            alertTitle: "Advertencia",
            alertMessage: "Coloca tus datos pe sonso 👊🏼",
            alertIcon: "warning",
            showConfirmButton: true,
            timer: false,
            ruta: ''
        })
    }
})
// Verificación de sesión de cada página
app.get('/maine', (req, res) => {
    if(req.session.loggedin && req.session.type == 1){
        connection.query('SELECT * FROM asignatura', (err, asig) =>{
            if (err) {
                throw err;
            } else {
                res.render('index-e',{
                    login: true,
                    name: req.session.name,
                    data: asig
                })
            }
        })
        /*res.render('index-e',{
            login: true,
            name: req.session.name
        })*/
    }else{
        res.render('index-e',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
app.get('/mainp', (req, res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('index-p',{
            login: true,
            name: req.session.name
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
app.get('/maind', (req, res) => {
    if(req.session.loggedin && req.session.type == 3){
        res.render('index-d',{
            login: true,
            name: req.session.name
        })
    }else{
        res.render('index-d',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Asignaturas
app.get('/asig-estu', (req,res) => {
    if(req.session.loggedin && req.session.type == 1){
        connection.query('SELECT * FROM asignatura', (err, asig) =>{
            
            if (err) {
                throw err;
            } else {
                res.render('e-asig',{
                    login: true,
                    name: req.session.name,
                    data: asig
                })
            }
        })
        /*res.render('index-e',{
            login: true,
            name: req.session.name
        })*/
    }else{
        res.render('index-e',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})




// Cerrar sesión
app.get('/logout', (req, res)=>{
    req.session.destroy(()=>{
        res.redirect('/')
    })
})

//PONCHO
app.get('/cursos-e', (req,res) => {
    res.render('cur-uni')
})
app.get('/unidades-e', (req,res) => {
    res.render('unidades-e')
})




// Guardar el puerto en una variable
const PUERTO = process.env.PORT || 3000 
// Inicializar el servidor
app.listen(PUERTO)
console.log(`EL SERVIDOR ESTÁ CONECTADO EN EL PUERTO: ${PUERTO}`)