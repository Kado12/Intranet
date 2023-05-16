use db_colegio;

-- Validación del usuario
DELIMITER $$
CREATE PROCEDURE SP_validacion_usuario(in Dni varchar(8), Contra varchar(16))
BEGIN
	SELECT usr_id as 'ID', tip_id as 'TIPO'
    FROM usuario
    WHERE usr_id = Dni AND usr_pass = Contra;
END$$
DELIMITER ;
-- CALL SP_validacion_usuario('45678912','45678912');

-- Datos del usuario
DELIMITER $$
CREATE PROCEDURE SP_datos_usuario(in Dni varchar(8))
BEGIN
	DECLARE TipoUsuario INT;
    
    SET TipoUsuario = (SELECT tip_id from usuario where usr_id = Dni);
    
    IF TipoUsuario = 1 THEN
		SELECT usr_id as 'ID', usr_nombres as 'NOMBRES', usr_apellidos as 'APELLIDOS',
        tip_desc as 'TIPO',
        usr_correo as 'CORREO',usr_telefono as 'CELULAR',
		usr_ubicacion as 'UBICACIÓN', usr_direccion as 'DIRECCIÓN',
		estudiante.crs_id as 'ID AULA', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN'
		FROM usuario
		inner join estudiante on estudiante.est_usr_id = usuario.usr_id
		inner join curso on curso.crs_id = estudiante.crs_id
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
		WHERE usr_id = Dni;
        
	ELSEIF TipoUsuario = 2 THEN
		SELECT usr_id as 'ID', usr_nombres as 'NOMBRES',
        tip_desc as 'TIPO',
		usr_apellidos as 'APELLIDOS',usr_correo as 'CORREO',usr_telefono as 'CELULAR',
		usr_ubicacion as 'UBICACIÓN', usr_direccion as 'DIRECCIÓN'
		FROM usuario
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
		WHERE usr_id = Dni;
        
	ELSEIF TipoUsuario = 3 THEN
		SELECT usr_id as 'ID', usr_nombres as 'NOMBRES', usr_apellidos as 'APELLIDOS',
        tip_desc as 'TIPO'
		FROM usuario
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
		WHERE usr_id = Dni;
	ELSE 
		SELECT 'ERROR: Usuario no encontrado';
	END IF;

END$$
DELIMITER ;
-- CALL SP_datos_usuario('45678912');
-- CALL SP_datos_usuario('45679212');
-- CALL SP_datos_usuario('45679267');
-- CALL SP_datos_usuario('123');

-- Horario de un estudiante
DELIMITER $$
CREATE PROCEDURE SP_horario_usuario(in DNI int)
BEGIN
	DECLARE aula int;
    DECLARE TipoUsuario INT;
    
    SET TipoUsuario = (SELECT tip_id from usuario where usr_id = DNI);
    
    IF TipoUsuario = 1 THEN
		SET aula = (select crs_id from estudiante where est_usr_id = DNI);
		SELECT asignatura.asi_id as 'ID', asi_desc as 'ASIGNATURA', MIN(hor_hora_inicio) as 'HORA INICIO', MAX(hor_hora_fin) as 'HORA FINAL', curhor_dia as 'DÍA' from curso_profesor
		inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
		inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
		inner join horario on horario.hor_id = curso_horario.hor_id
		where curso_profesor.crs_id = aula group by asignatura.asi_id, curhor_dia order by curso_horario.curhor_id;
        
	ELSEIF TipoUsuario = 2 THEN
		SELECT curso.crs_id as 'ID', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN', MIN(hor_hora_inicio) as 'HORA INICIO', MAX(hor_hora_fin) as 'HORA FINAL', curhor_dia as 'DÍA' from curso_profesor
		inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
		inner join curso on curso.crs_id = curso_profesor.crs_id
		inner join horario on horario.hor_id = curso_horario.hor_id
		where curso_profesor.pro_usr_id = DNI group by curso.crs_id, curhor_dia order by curso_horario.curhor_id;
	ELSE
		SELECT 'ERROR: Este usuario no tiene horario.'; 
	END IF;
		
END$$
DELIMITER ;
-- CALL SP_horario_usuario('45678912');
-- CALL SP_horario_usuario('45679212');

-- Cursos de un estudiante para el dia actual
DELIMITER $$
CREATE PROCEDURE SP_cursos_dia(in Aula int)
BEGIN
	select asignatura.asi_id as 'ID', asi_desc as 'ASIGNATURA',
    curhor_dia as 'DÍA'
    from curso_profesor
    inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
    inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
    where curso_profesor.crs_id = aula
    GROUP BY curso_profesor.asi_id,curso_horario.curhor_dia  ORDER BY curso_horario.curhor_id;
END$$
DELIMITER ;
-- CALL SP_cursos_dia(1);

-- Lista de Cursos de un estudiante
DELIMITER $$
CREATE PROCEDURE SP_cursos_estudiante(in Aula int)
BEGIN
	select curso_profesor.curpro_id as 'ID', asi_desc as 'ASIGNATURA',
    concat(usr_nombres, ' ', usr_apellidos) as 'PROFESOR'
    from curso_profesor
    inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
    inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
    inner join profesor on profesor.pro_usr_id = curso_profesor.pro_usr_id
    inner join usuario on usuario.usr_id = profesor.pro_usr_id
    where curso_profesor.crs_id = aula
    GROUP BY curso_profesor.asi_id, curso_profesor.curpro_id  ORDER BY curso_profesor.asi_id;
END$$
DELIMITER ;
-- CALL SP_cursos_estudiante(2);

-- Información del Curso Seleccionado por el Estudiante
DELIMITER $$
CREATE PROCEDURE SP_informacion_curso(in Aula_Profesor int)
BEGIN
	SELECT curpro_id as 'ID', asi_desc as 'ASIGNATURA', CONCAT(usr_nombres, ' ', usr_apellidos) as 'PROFESOR', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN'
	from curso_profesor
	inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
	inner join curso on curso.crs_id = curso_profesor.crs_id
	inner join profesor on profesor.pro_usr_id = curso_profesor.pro_usr_id
	inner join usuario on usuario.usr_id = profesor.pro_usr_id
	where curso_profesor.curpro_id = Aula_Profesor;
    
    SELECT MIN(hor_hora_inicio) as 'HORA INICIO', MAX(hor_hora_fin) as 'HORA FINAL', curhor_dia as 'DÍA' from curso_profesor
	inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
	inner join horario on horario.hor_id = curso_horario.hor_id
	where curso_profesor.curpro_id = Aula_Profesor group by curso_profesor.asi_id, curhor_dia order by curso_horario.curhor_id;
END$$
DELIMITER ;
-- CALL SP_informacion_curso(1);

-- Unidades
DELIMITER $$
CREATE PROCEDURE SP_unidades(in Aula_Profesor int)
BEGIN
	select sesion.ses_id as 'ID SESIÓN', ses_titulo as 'SESIÓN TÍTULO', unidad.uni_id as 'ID UNIDAD', uni_titulo as 'TITULO UNIDAD'
	from unidad
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	inner join sesion on sesion.uni_id = unidad.uni_id
	where curso_profesor.curpro_id = Aula_Profesor order by sesion.ses_id;
END$$
DELIMITER ;
-- CALL SP_unidades(1);

-- Sesión Contenido
DELIMITER $$
CREATE PROCEDURE SP_sesion_contenido(in idSesion int)
BEGIN
	select arc_id as 'ID CLASE', arc_titulo as 'TÍTULO', arc_link as 'LINK'
	from archivos
	where ses_id = idSesion;
    
    select eva_id as 'ID EVALUACIÓN', eva_titulo as 'TÍTULO', eva_tipo as 'TIPO'
	from evaluacion
	where ses_id = idSesion;
END $$
DELIMITER ;
-- CALL SP_sesion_contenido(1);
