use db_colegio;

select * from nota_alumno;
select * from evaluacion;
select * from asistencia;
select * from sesion;
select * from estudiante;

select asi_desc, crs_grado, crs_seccion, uni_titulo, ses_titulo, ses_fecha from sesion
inner join unidad on unidad.uni_id = unidad.uni_id
inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
inner join curso on curso.crs_id = curso_profesor.crs_id;

select usr_id, usr_nombres, usr_apellidos, crs_grado, crs_seccion 
from curso
left join estudiante on curso.crs_id = estudiante.crs_id
inner join usuario on estudiante.est_usr_id = usuario.usr_id;
