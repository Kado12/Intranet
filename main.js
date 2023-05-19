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
// Ruta de pagina de Logeo
app.get('/',(req,res)=>{
    res.render('index')
})
// Autenticación de inicio de sesión 
app.post('/auth', async (req, res)=>{
    const user = req.body.user
    const pass = req.body.pass
    if(user && pass){
        connection.query('CALL SP_datos_usuario(?)', [user], async (err, results)=>{
            // Guardando los datos de usuario al iniciar sesión
            req.session.cod = results[0][0].ID
            req.session.pass = results[0][0].CONTRA
            req.session.name =results[0][0].NOMBRES +' '+ results[0][0].APELLIDOS
            req.session.type = results[0][0]['ID TIPO']
            // validando datos de sesión
            if (results.length == 0 || !(await pass == req.session.pass)){
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
                if(req.session.type == 1){
                    ruta = 'maine'
                    req.session.grado = results[0][0].GRADO
                    req.session.seccion = results[0][0]['SECCIÓN']
                    req.session.idaula = results[0][0]['ID AULA']
                } else if(req.session.type == 2){
                    ruta = 'mainp'
                } else{
                    ruta = 'maind'
                }
                req.session.loggedin = true
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
            alertMessage: "Coloca tus datos",
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
        connection.query('CALL SP_cursos_estudiante(?)', [req.session.idaula], (err, results) => {
            req.session.cursos = results[0]
            res.render('index-e',{
                login: true,
                name: req.session.name,
                data: req.session.cursos
            })
        })
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
// Verificación Asignaturas
app.post('/asignatura', async (req, res) => {
    const botonSeleccionado = Object.keys(req.body).find(key => key.startsWith('asignatura_'))
    const idAsignatura = botonSeleccionado.replace('asignatura_', '')
    console.log('Se ha seleccionado el botón con ID de asignatura:', idAsignatura)
    connection.query('CALL SP_obtener_informacion_curso(?)', [parseInt(idAsignatura)], (err, results) => {
        console.log(results[0])
        req.session.curprof = parseInt(idAsignatura)
        req.session.profesor = results[0][0].PROFESOR
        req.session.descurso = results[0][0].DESCRIPCION_ASIGNATURA
        req.session.diashor = results[0]
        console.log('Información obtenida exitosamente.')
        res.redirect('/asig-estu')
    })
})
// Renderizar página de asignatura
app.get('/asig-estu', (req,res) => {
    if(req.session.loggedin && req.session.type == 1){
        res.render('e-asig',{
            login: true,
            name: req.session.name,
            nomasig: req.session.descurso,
            prof: req.session.profesor,
            hotdia: req.session.diashor,
            seccion: req.session.seccion
        })
    }else{
        res.render('e-asig',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Verificación de acción seleccionada por Estudiante
app.post('/accion-estudiante', async (req, res) => {
    const botonSeleccionado = Object.keys(req.body)
    console.log('Se ha seleccionado la accion', botonSeleccionado.join(''))
    connection.query('CALL SP_obtener_datos(?)', [req.session.curprof], (err, results) => {
        console.log(results)
        req.session.archivos = results[0]
        req.session.evaluaciones = results[1]
        console.log(req.session.archivos.length)
        console.log(req.session.evaluaciones.length)
        res.redirect('/action-estu')
    })  
})
// Renderizar página de accion
app.get('/action-estu', (req,res) => {
    res.render('e-unidades', {
        name: req.session.name,
        archivos: req.session.archivos,
        evaluaciones: req.session.evaluaciones,
        login: true
    })
})
// Cerrar sesión
app.get('/logout', (req, res)=>{
    req.session.destroy(()=>{
        res.redirect('/')
    })
})
app.get('/e-evalu', (req,res)=>{
    res.render('e-evalu', {
        name: req.session.name,
        evaluaciones: req.session.evaluaciones,
        login: true
    })
})

//PONCHO
app.get('/cursos-e', (req,res) => {
    res.render('cur-uni')
})
// Unidades Estudiante
app.get('/unidades-e', (req,res) => {
    res.render('unidades-e')
})
// Unidades profesor
app.get('/unidades-pr', (req,res) => {
    res.render('unidades-pr')
})
//EVALUACIONES PROFESOR
app.get('/evalu-pr', (req,res)=> {
    res.render('evalu-pr')
})
//Aula Profesor
app.get('/aula-pr', (req,res)=> {
    res.render('aula-pr')
})
app.get('/evalu-e', (req,res)=>{
    res.render('evalu-e')
})
//USANDO NODE
app.get('/e-evalu', (req,res)=>{
    res.render('e-evalu')
})


// Guardar el puerto en una variable
const PUERTO = process.env.PORT || 3000 
// Inicializar el servidor
app.listen(PUERTO)
console.log(`EL SERVIDOR ESTÁ CONECTADO EN EL PUERTO: ${PUERTO}`)