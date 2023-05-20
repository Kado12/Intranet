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
    console.log(req.session.loggedin)
    console.log(req.session.type)
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
    connection.query('CALL SP_obtener_informacion_curso(?)', [parseInt(idAsignatura)], (err, results) => {
        req.session.curprof = parseInt(idAsignatura)
        req.session.profesor = results[0][0].PROFESOR
        req.session.descurso = results[0][0].DESCRIPCION_ASIGNATURA
        req.session.diashor = results[0]
        res.redirect('/asig-estu')
    })
})

//PROCEDIMIENTO PARA DIRECTORA
app.post('/acciondesempeno', async(req,res) => {
    const btnAlumnado = Object.keys(req.body);
    const tipoBtn = btnAlumnado.join('');
    if(tipoBtn == 'btnAlumnado'){
        res.redirect('/d-alum-g')
    }else if (tipoBtn == 'btnDocente'){
        res.redirect('/d-doce-c')
    }
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
    connection.query('CALL SP_obtener_datos(?)', [req.session.curprof], (err, results) => {
        console.log(results)
        req.session.archivos = results[0]
        req.session.evaluaciones = results[1]
        if(botonSeleccionado.join('')=='unidades'){
            res.redirect('/e-unidad')
        }else if(botonSeleccionado.join('')=='evaluaciones'){
            res.redirect('/e-evalu')
        }else{
            res.redirect('/e-notas')
        }
    })
})
// Renderizar página de accion de estudiante - unidades
app.get('/e-unidad', (req,res) => {
    if(req.session.loggedin && req.session.type == 1){
        res.render('e-unidades', {
            name: req.session.name,
            archivos: req.session.archivos,
            evaluaciones: req.session.evaluaciones,
            login: true
        })
    } else{
        res.render('index-e',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }  
})
// Renderizar página de accion de estudiante - evaluaciones
app.get('/e-evalu', (req,res)=>{
    if(req.session.loggedin && req.session.type == 1){
        res.render('e-evalu', {
            name: req.session.name,
            archivos: req.session.archivos,
            evaluaciones: req.session.evaluaciones,
            login: true,
            nomCurso: req.session.descurso
        })
    }else{
        res.render('index-e',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Renderizar página de accion de estudiante - calificaciones
app.get('/e-notas', (req,res) => {
    if(req.session.loggedin && req.session.type == 1){
        connection.query('CALL SP_notas_estudiante(?, ?)', [req.session.cod, req.session.curprof], (err, results) => {
            req.session.notas = results[0]
            req.session.promedio = results[1]
            res.render('e-calificaciones',{
                login: true,
                name: req.session.name,
                notas: req.session.notas,
                promedio: req.session.promedio,
                nomC: req.session.descurso
            })
        })
    }else{
        res.render('index-e',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
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

//EWAPLS
app.get('/asistencia', (req,res) => {
    res.render('asistencia-profesor')
})

app.get('/calificacionT', (req,res) => {
    res.render('calificacion-tareas-profesor')
})

app.get('/calificacionP', (req,res) => {
    res.render('calificacion-practicas-profesor')
})
app.get('/d-alum-c', (req,res) => {
    res.render('d-alum-c')
})

app.get('/calificacionN', (req,res) => {
    res.render('calificacion-notas-profesor')
})
//USANDO NODE
app.get('/e-evalu', (req,res)=>{
    res.render('e-evalu')
})
//PATRICK
app.get('/d-alum-s', (req,res) => {
    res.render('d-alum-s')
})
app.get('/d-alum-g', (req,res) => {
    res.render('d-alum-g')
    
})
app.get('/d-doce-c', (req,res) => {
    res.render('d-coce-c')
})
app.get('/d-doce-d', (req,res) => {
    res.render('d-doce-d')
})//#region JHEAN

app.get('/d-seleccion-docente', (req,res) => {
    res.render('d-seleccion-docente')
})
//#endregion


// Cerrar sesión
app.get('/logout', (req, res)=>{
    req.session.destroy(()=>{
        res.redirect('/')
    })
})
// Guardar el puerto en una variable
const PUERTO = process.env.PORT || 3000 
// Inicializar el servidor
app.listen(PUERTO)
console.log(`EL SERVIDOR ESTÁ CONECTADO EN EL PUERTO: ${PUERTO}`)