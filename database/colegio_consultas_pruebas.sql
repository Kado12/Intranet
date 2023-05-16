use db_colegio;

select * from nota_alumno;
select * from evaluacion;
select * from asistencia;
select * from sesion;
select * from estudiante;

-- Lista general de todas las Sesiones
select asi_desc, crs_grado, crs_seccion, uni_titulo, ses_titulo from sesion
inner join unidad on unidad.uni_id = unidad.uni_id
inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
inner join curso on curso.crs_id = curso_profesor.crs_id;

-- Horario de un estudiante
select asi_desc, horario.hor_id, hor_hora_inicio, hor_hora_fin, curhor_dia from curso_profesor
inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
inner join horario on horario.hor_id = curso_horario.hor_id
where curso_profesor.crs_id = 1;

-- Lista de Estudiantes
select usr_id, usr_nombres, usr_apellidos, crs_grado, crs_seccion 
from curso
left join estudiante on curso.crs_id = estudiante.crs_id
inner join usuario on estudiante.est_usr_id = usuario.usr_id;

-- Lista de Tareas del 1ro A
select crs_grado, crs_seccion, asi_desc, eva_titulo, ses_titulo from evaluacion
inner join sesion on sesion.ses_id = evaluacion.ses_id
inner join unidad on unidad.uni_id = sesion.uni_id
inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
inner join curso on curso.crs_id = curso_profesor.crs_id
inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
where eva_tipo = 1 and curso_profesor.crs_id =1;


/* TESTEO DE PROCEDIMIENTOS ALMACENADOS */
use db_colegio;

-- validación del usuario
CALL SP_validacion_usuario('45678912','45678912'); /* Id y Contraseña del usuario */

-- Datos del usuario (Salida diferente, según el tipo de usuario)
CALL SP_datos_usuario('45678912'); /* Id del usuario */

-- Horario del usuario (estudiante o profesor)
CALL SP_horario_usuario('45678912'); /* Id del usuario */

-- Cursos del estudiante
CALL SP_cursos_estudiante(2); /* ID del Aula */

-- Información del Curso Seleccionado por el Estudiante
CALL SP_informacion_curso(1); /* ID de Aula-Profesor */

-- Unidades y sesiones
CALL SP_unidades(1); /* ID de Aula-Profesor */

-- Sesión Contenido
CALL SP_sesion_contenido(1); /* ID de la Sesión */