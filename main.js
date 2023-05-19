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
                req.session.cod = results[0].usr_id
                //console.log(req.session.cod)
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
            res.render('index-e',{
                login: true,
                name: req.session.name,
                data: asig
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
    const getAsignatura = () => {
        return new Promise((resolve, reject) => {
            connection.query('SELECT asignatura.asi_id, asignatura.asi_desc, profesor.pro_usr_id, usuario.usr_nombres, usuario.usr_apellidos,curso.crs_id,curso.crs_grado,curso.crs_seccion,curso_horario.curhor_dia,horario.hor_hora_inicio,horario.hor_hora_fin FROM asignatura INNER JOIN curso_profesor ON asignatura.asi_id = curso_profesor.asi_id INNER JOIN curso ON curso_profesor.crs_id = curso.crs_id INNER JOIN curso_horario ON curso_profesor.curpro_id = curso_horario.curpro_id INNER JOIN horario ON curso_horario.hor_id = horario.hor_id INNER JOIN profesor ON curso_profesor.pro_usr_id = profesor.pro_usr_id INNER JOIN usuario ON profesor.pro_usr_id = usuario.usr_id WHERE asi_desc = ?', [idAsignatura], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    req.session.hordia = result[0].curhor_dia
                    req.session.nomasig = result[0].asi_desc
                    req.session.prof = result[0].usr_nombres + ' ' + result[0].usr_apellidos
                    req.session.horario = result[0].hor_hora_inicio + '-' + result[0].hor_hora_fin
                    resolve(result)
                }
            });
        });
    };
    const getEstudiante = () => {
        return new Promise((resolve, reject) => {
            connection.query('SELECT usuario.usr_id, estudiante.crs_id, curso.crs_grado, curso.crs_seccion FROM usuario INNER JOIN estudiante ON usuario.usr_id = estudiante.est_usr_id INNER JOIN curso ON estudiante.crs_id = curso.crs_id WHERE usr_id = ?', [req.session.cod], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    req.session.seccion = result[0].crs_seccion;
                    resolve(result)
                }
            });
        });
    };
    try {
        const [asignatura, estudiante] = await Promise.all([getAsignatura(), getEstudiante()])
        console.log('Información obtenida exitosamente.')
        res.redirect('/asig-estu')
    } catch (error) {
        console.error(error)
        res.status(500).send('Error al obtener información.')
    }
})
// Renderizar pagina de asignatura
app.get('/asig-estu', (req,res) => {
    if(req.session.loggedin && req.session.type == 1){
        res.render('e-asig',{
            login: true,
            name: req.session.name,
            nomasig: req.session.nomasig,
            prof: req.session.prof,
            horario: req.session.horario,
            hordia: req.session.hordia,
            seccion: req.session.seccion
        })
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

//#region JHEAN
app.get('/e-notas', (req,res) => {
    res.render('e-notas')
})
app.get('/d-seleccion-docente', (req,res) => {
    res.render('d-seleccion-docente')
})
//#endregion

// Guardar el puerto en una variable
const PUERTO = process.env.PORT || 3000 
// Inicializar el servidor
app.listen(PUERTO)
console.log(`EL SERVIDOR ESTÁ CONECTADO EN EL PUERTO: ${PUERTO}`)