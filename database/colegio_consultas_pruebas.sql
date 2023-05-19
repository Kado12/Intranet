use db_colegio;

select * from nota_alumno;
select * from evaluacion;
select * from asistencia;
select * from sesion;
select * from estudiante;
select * from horario;

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

/* Actualizar horario
UPDATE horario
SET hor_hora_inicio = CASE 
                    WHEN hor_id = 4 THEN '10:30:00'
                    WHEN hor_id = 5 THEN '11:15:00'
                    WHEN hor_id = 6 THEN '12:00:00'
                    WHEN hor_id = 7 THEN '12:45:00'
                    ELSE hor_hora_inicio
                END,
    hor_hora_fin = CASE 
                    WHEN hor_id = 4 THEN '11:15:00'
                    WHEN hor_id = 5 THEN '12:00:00'
                    WHEN hor_id = 6 THEN '12:45:00'
                    WHEN hor_id = 7 THEN '13:30:00'
                    ELSE hor_hora_fin
                END
WHERE hor_id IN (4,5,6,7);
*/



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

-- Evaluaciones
CALL SP_evaluaciones(1); /* ID de Aula-Profesor */

-- Notas de Estudiante
CALL SP_notas_estudiante('45678912', 1); /* ID de Estudiante e ID de Aula-Profesor */

-- aulas de un profesor
CALL SP_aulas('45679212'); /* ID de Profesor */

-- Lista de estudiantes de un Aula y una Asignatura
CALL SP_lista_estudiantes_aula(1); /* ID de Aula-Profesor */

-- Información de fecha con respecto a una sesión
CALL SP_informacion_fecha('2023-04-03'); /* La fecha actual */

-- Lista de Unidades de un Aula
CALL SP_lista_unidades_aula(1); /* ID de Aula-Profesor */

-- Lista de Sesiones de una Unidad
CALL SP_lista_sesiones_unidad(1); /* ID de la Unidad */

-- Lista de Fechas de una Sesión
CALL SP_lista_fechas_sesion(1); /* ID de la Sesión */

-- Agregar Nueva Fecha
CALL SP_agregar_fecha(1, '2023-05-16'); /* ID de la Sesión y nueva fecha */

-- Agregar falta de estudiantes
CALL SP_agregar_falta(1, '45678912,45678913,45678917'); /* ID de fecha-sesion y una cadena de ID'S de Estudiantes separados por coma */

-- Editar Sesion
CALL SP_editar_sesion(1, 'Sesión 1'); /* ID y nuevo título de la sesión */

-- Editar Evaluación
CALL SP_editar_evaluacion(1, 'Problemas de Matemáticas', 'Resolver problemas Matemáticos que involucren conceptos como álgebra, geometría, trigonometría, etc.' , '2023-04-03 08:10:00', '2023-04-10 10:10:00', 'www.colegio/tareas/JJJ',1); /* ID, titulo, descripcion, fecha inicio, fecha fin, link, tipo evaluacion */

-- Información Evaluación
CALL SP_informacion_evaluacion(1); /* ID de la evaluación */

-- Guardar Calificación
CALL SP_guardar_calificacion(19,'45678912',1); /* Calificación, ID del estudiante e ID de la evaluación */

-- Agregar Nueva Sesión
CALL SP_agregar_sesion(221,'Sesión 4'); /* ID de la Unidad y título de la nueva sesión */

-- Agregar Nueva Clase
CALL SP_agregar_clase('Diapositivas','www.colegio/archivos/ASD', 1); /* Titulo, link de la Nueva Clase (archivos) e ID de la Sesión selecionada */

-- Agregar Nueva Evaluación con Sesión existente
CALL SP_agregar_evaluacion_sesionExiste('Problemas de Integrales', 'Resolver 5 problemas de integrales', '2023-04-03 08:20:00', '2023-04-10 10:20:00', 'www.colegio/tareas/HHH', 1, 1); /* Titulo, Desripcion, Fecha de Inicio, Fecha Final, Link, Tipo de la nueva evaluación y el ID de la sesión seleccionada */

-- Agregar Nueva Evaluación con Sesión NO existente
CALL SP_agregar_evaluacion_sesionNoExiste( 1,'Sesión 6', 'Problemas de Integrales 3', 'Resolver 5 problemas de integrales', '2023-04-03 08:20:00', '2023-04-10 10:20:00', 'www.colegio/tareas/HHH', 1,1); /* ID de la Unidad, Titulo de la nueva Sesión, Titulo, Desripcion, Fecha de Inicio, Fecha Final, Link, Tipo de la nueva evaluación y el ID de la sesión seleccionada */

-- Notas de estudiantes de un Aula
select ROW_NUMBER() OVER (ORDER BY evaluacion.eva_id and usr_apellidos) AS 'N°', CONCAT(usr_apellidos, ' ' ,usr_nombres) as 'ESTUDIANTE', not_calificacion as 'NOTA', nota_alumno.eva_id as 'ID EVALUACIÓN'
from nota_alumno
left join estudiante on estudiante.est_usr_id = nota_alumno.est_usr_id
inner join usuario on usuario.usr_id = estudiante.est_usr_id
inner join evaluacion on evaluacion.eva_id = nota_alumno.eva_id
where estudiante.est_usr_id 
IN (
	select estudiante.est_usr_id
	from estudiante
	inner join curso on curso.crs_id = estudiante.crs_id
	inner join curso_profesor on curso_profesor.crs_id = curso.crs_id
	where curso_profesor.curpro_id = 1
)
AND nota_alumno.eva_id
IN (
	select evaluacion.eva_id
    from evaluacion
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where curso_profesor.curpro_id = 1
) order by evaluacion.eva_id and usr_apellidos;