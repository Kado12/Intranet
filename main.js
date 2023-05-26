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
// Verificación de sesión de cada página - estudiante
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
    connection.query('CALL SP_obtener_informacion_curso(?)', [parseInt(idAsignatura)], (err, results) => {
        req.session.curprof = parseInt(idAsignatura)
        req.session.profesor = results[0][0].PROFESOR
        req.session.descurso = results[0][0].DESCRIPCION_ASIGNATURA
        req.session.diashor = results[0]
        res.redirect('/asig-estu')
    })
})

//PROCEDIMIENTO PARA DIRECTORA MAIN
app.post('/acciondesempeno', async(req,res) => {
    const btnAlumnado = Object.keys(req.body);
    const tipoBtn = btnAlumnado.join('');
    if(tipoBtn == 'btnAlumnado'){
        res.redirect('/d-alum-g')
    }else if (tipoBtn == 'btnDocente'){
        res.redirect('/d-doce-c')
    }
})
//PROCEDIMIENTO DIRECTORA -> DESEMPEÑO ALUMNADO
app.get('/d-alum-g', (req,res) => {
    if(req.session.loggedin && req.session.type==3){
        res.render('d-alum-g', {
            login: true,
            name: req.session.name
        })
    }else {
        res.render('d-alum-g', {
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})

//PROCEDIMIENTO DIRECTORA -> DESEMPEÑO DOCENTE
app.get('/d-doce-c', (req,res) => {
    if(req.session.loggedin && req.session.type == 3){
        res.render('d-doce-c',{
            login:true,
            name:req.session.name
        })
    }else{
        res.render('d-doce-c',{
            login:false,
            name: 'Debe iniciar sessión'
        })
    }
})
//PROCEDIMIENTO BOTONES ALUMNADO GRADO->SECCION
app.post('/desempenoalumnado', async(req,res) => {
    res.redirect('/d-alum-s')
})
//PROCEDIMIENTO BOTONES ALUMNADO SECCION->CURSO
app.post('/alumseccioncurso', async(req,res) => {
    res.redirect('/d-alum-c')
})
//PROCEDIMIENTO BOTONES DOCENTE CURSOS -> DOCENTES
app.post('/doce-docentes-docente', async(req,res) => {
    res.redirect('d-seleccion-docente')
})
app.post('/doce-curso-seccion', async(req,res) => {
    res.redirect('d-doce-d')
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

// Página index-p - Profesor
app.get('/mainp', (req, res) => {
    if(req.session.loggedin && req.session.type == 2){
        connection.query('CALL SP_aulas(?)', [req.session.cod], (err, results) => {
            req.session.infoAula = results[0] 
            res.render('index-p',{
                login: true,
                name: req.session.name,
                infoAula: req.session.infoAula
            })
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Formulario /vaula
app.post('/vaula', async (req, res) => {
    const btnSeleccionado = Object.keys(req.body).find(key => key.startsWith('gs_'))
    const idAula = btnSeleccionado.replace('gs_', '')
    const gs = idAula.split('')
    const grado = parseInt(gs[0])
    const seccion = gs[1]
    const getDatosAula = () => {
        return new Promise((resolve, reject) => {
            connection.query('CALL SP_datos_aula(?, ?, ?)', [req.session.cod, seccion, grado], (err, results) => {
                if (err) {
                    reject(err)
                } else{
                    req.session.aulaInfo = results[0]
                    req.session.curprof = results[0][0].IDCURPROF
                    req.session.gradoAula = results[0][0].GRADOAULA
                    req.session.seccionAula = results[0][0].SECCAULA
                    resolve(results)
                }
            })
        })
    }
    const getEstudiantes = () => {
        return new Promise((resolve, reject) => {
            connection.query('CALL SP_lista_estudiantes_aula(?)', [req.session.curprof], (err, results) => {
                if (err){
                    reject(err)
                } else{
                    req.session.alumnosAula = results[0]
                    resolve(results)
                }
            })
        })
    }
    try {
        const datosAula = await getDatosAula()
        const estudiantes = await getEstudiantes()
        res.redirect('/aula-prof')
    } catch (err) {
        console.log(err)
    }
})
// Página p-aula.ejs
app.get('/aula-prof', (req, res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('p-aula',{
            login: true,
            name: req.session.name,
            aulaInfo: req.session.aulaInfo,
            curprof: req.session.curprof,
            gradoAula: req.session.gradoAula,
            seccionAula: req.session.seccionAula,
            alumnosAula: req.session.alumnosAula
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Verificación de acción seleccionada por Profesor   ª!"ª!"ª!"ª!"ª!"ª!"ª!"ª!"ª"ª!"ª!"ª!"ª!"ª!
app.post('/accion-docente', async (req,res) => {
    const btnAccProfesor = Object.keys(req.body);
    const accionBtn = btnAccProfesor.join('');
    if (accionBtn == 'unidades') {
        connection.query('CALL SP_obtener_datos(?)', [req.session.curprof], (err, results) => {
            req.session.archivos = results[0]
            req.session.evaluaciones = results[1]
            res.redirect('/aula-unidades')
        })
    } else if (accionBtn == 'evaluaciones') {
        connection.query('CALL SP_obtener_datos(?)', [req.session.curprof], (err, results) => {
            req.session.archivos = results[0]
            req.session.evaluaciones = results[1]
            res.redirect('/aula-evaluaciones')
        })
    } else if (accionBtn == 'notas') {
        res.redirect('/aula-notas')
    } else {
        connection.query('CALL SP_lista_estudiantes_aula(?)', [req.session.curprof], (err, results) => {
            req.session.alumnos = results[0]
            res.redirect('/aula-asistencia')
        })
    }
})
app.get('/aula-unidades', (req, res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('p-aula-unidades',{
            login: true,
            name: req.session.name,
            aulaInfo: req.session.aulaInfo,
            curprof: req.session.curprof,
            archivos: req.session.archivos,
            evaluaciones: req.session.evaluaciones,
            gradoAula: req.session.gradoAula,
            seccionAula: req.session.seccionAula,
            alumnosAula: req.session.alumnosAula
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
// Editar Clase - por terminar
app.post('/editar-post', async(req, res) => {
    const nomClase = req.body.nomClase
    const linkClase = req.body.linkClase
    const sesionID = req.body.sesionID
    console.log(nomClase)
    console.log(linkClase)
    console.log(sesionID)
    connection.query('CALL SP_editar_ses(?,?,?)',[nomClase, linkClase, sesionID], async (err, results) => {
        res.redirect('/aula-unidades')
    })
})

// Entrar a evaluaciones - Profesor ---------ªªªªªªªªªªªªªª!"ª!"ª!"ª!"ª!"ª"!
app.get('/aula-evaluaciones', (req,res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('p-aula-evaluaciones',{
            login: true,
            name: req.session.name,
            archivos: req.session.archivos,
            evaluaciones: req.session.evaluaciones
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})

// Entrar a notas - Profesor
app.get('/aula-notas', (req,res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('p-aula-notas',{
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

// Entrar a asistencia - Profesor
app.get('/aula-asistencia', (req,res) => {
    if(req.session.loggedin && req.session.type == 2){
        res.render('p-aula-asistencia',{
            login: true,
            name: req.session.name,
            alumnos: req.session.alumnos
        })
    }else{
        res.render('index-p',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})




//PROCEDIMIENTO PARA DIRECTORA
app.post('/acciondesempeno', async(req,res) => {
    const btnAlumnado = Object.keys(req.body);
    const tipoBtn = btnAlumnado.join('');
    if(tipoBtn == 'btnAlumnado'){
        res.redirect('/d-alum-g')
    }else{
        res.redirect('/d-doce-c')
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
    if(req.session.loggedin && req.session.type == 3){
        res.render('d-alum-c',{
            name: req.session.name,
            login:true
        })
    }else{
        res.render('d-alum-c',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
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
    if(req.session.loggedin && req.session.type == 3){
        res.render('d-alum-s',{
            name: req.session.name,
            login:true
        })
    }else{
        res.render('d-alum-s',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})
app.get('/d-doce-d', (req,res) => {
    if(req.session.loggedin && req.session.type == 3){
        res.render('d-doce-d',{
            name: req.session.name,
            login:true
        })
    }else{
        res.render('d-doce-d',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
})//#region JHEAN

app.get('/d-seleccion-docente', (req,res) => {
    if(req.session.loggedin && req.session.type == 3){
        res.render('d-seleccion-docente',{
            name: req.session.name,
            login:true
        })
    }else{
        res.render('d-seleccion-docente',{
            login: false,
            name: 'Debe iniciar sessión'
        })
    }
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