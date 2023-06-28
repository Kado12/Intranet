use db_colegio;
/* ÚLTIMA ACTUALIZACIÓN - SÁBADO 03-junio-2023 HORAS 01:25 a.m. */

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
        SELECT usr_id as 'ID', usr_pass as 'CONTRA', usr_nombres as 'NOMBRES', usr_apellidos as 'APELLIDOS',
        usuario_tipo.tip_id as 'ID TIPO', tip_desc as 'TIPO',
        usr_correo as 'CORREO',usr_telefono as 'CELULAR',
        usr_ubicacion as 'UBICACIÓN', usr_direccion as 'DIRECCIÓN',
        estudiante.crs_id as 'ID AULA', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN'
        FROM usuario
        inner join estudiante on estudiante.est_usr_id = usuario.usr_id
        inner join curso on curso.crs_id = estudiante.crs_id
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
        WHERE usr_id = Dni;

    ELSEIF TipoUsuario = 2 THEN
        SELECT usr_id as 'ID', usr_pass as 'CONTRA', usr_nombres as 'NOMBRES',
        usuario_tipo.tip_id as 'ID TIPO',
        tip_desc as 'TIPO',
        usr_apellidos as 'APELLIDOS',usr_correo as 'CORREO',usr_telefono as 'CELULAR',
        usr_ubicacion as 'UBICACIÓN', usr_direccion as 'DIRECCIÓN'
        FROM usuario
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
        WHERE usr_id = Dni;

    ELSEIF TipoUsuario = 3 THEN
        SELECT usr_id as 'ID', usr_pass as 'CONTRA', usr_nombres as 'NOMBRES', usr_apellidos as 'APELLIDOS',
        usuario_tipo.tip_id as 'ID TIPO',
        tip_desc as 'TIPO'
        FROM usuario
        inner join usuario_tipo on usuario_tipo.tip_id = usuario.tip_id
        WHERE usr_id = Dni;
    ELSE 
        SELECT 'Usuario no encontrado' AS 'ERROR';
    END IF;

END$$
DELIMITER ;
-- CALL SP_datos_usuario('45678912');
-- CALL SP_datos_usuario('45679212');
-- CALL SP_datos_usuario('45679267');
-- CALL SP_datos_usuario('123');

-- Horario de un usuario
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
        
        select aula as 'ID AULA', c.crs_grado as 'GRADO', c.crs_seccion as 'SECCIÓN'
        from curso c
        where c.crs_id = aula;
        
	ELSEIF TipoUsuario = 2 THEN
		SELECT curso.crs_id as 'ID', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN', MIN(hor_hora_inicio) as 'HORA INICIO', MAX(hor_hora_fin) as 'HORA FINAL', curhor_dia as 'DÍA' from curso_profesor
		inner join curso_horario on curso_horario.curpro_id = curso_profesor.curpro_id
		inner join curso on curso.crs_id = curso_profesor.crs_id
		inner join horario on horario.hor_id = curso_horario.hor_id
		where curso_profesor.pro_usr_id = DNI group by curso.crs_id, curhor_dia order by curso_horario.curhor_id;
        
        select u.usr_id as 'ID PROFESOR', concat(usr_apellidos , ' ', u.usr_nombres) as 'PROFESOR', a.asi_desc as 'ASIGNATURA'
        from usuario u
        join profesor p on p.pro_usr_id = u.usr_id
        join curso_profesor cup on cup.pro_usr_id = p.pro_usr_id
        join asignatura a on a.asi_id = cup.asi_id
        where u.usr_id = DNI group by a.asi_id;
	ELSE
		SELECT 'Este usuario no tiene horario.' as 'ERROR'; 
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
    
	select curso_profesor.asi_id as 'ID', asi_desc as 'ASIGNATURA'
	from curso_profesor
	inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
	where curpro_id = Aula_Profesor;
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

-- Lista de evaluaciones
DELIMITER $$
CREATE PROCEDURE SP_evaluaciones(in Aula_Profesor int)
BEGIN
	select eva_id as 'ID EVALUACIÓN', eva_titulo as 'TÍTULO', eva_desc as 'DESCRIPCIÓN', eva_fecha_inicio as 'FECHA INICIO', eva_fecha_fin as 'FECHA FIN', eva_tipo as 'TIPO'
	from evaluacion
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where unidad.curpro_id = Aula_Profesor and eva_tipo = 1 order by eva_id;

	select eva_id as 'ID EVALUACIÓN', eva_titulo as 'TÍTULO', eva_desc as 'DESCRIPCIÓN', eva_fecha_inicio as 'FECHA INICIO', eva_fecha_fin as 'FECHA FIN', eva_tipo as 'TIPO'
	from evaluacion
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where unidad.curpro_id = Aula_Profesor and eva_tipo = 2 order by eva_id;

	select curso_profesor.asi_id as 'ID', asi_desc as 'ASIGNATURA'
	from curso_profesor
	inner join asignatura on asignatura.asi_id = curso_profesor.asi_id
	where curpro_id = Aula_Profesor;
END $$
DELIMITER ;
-- CALL SP_evaluaciones(1);

-- Notas de Estudiante
DELIMITER $$
CREATE PROCEDURE SP_notas_estudiante(in idEstudiante int, Aula_Profesor int)
BEGIN

	select eva_titulo as 'TÍTULO', not_calificacion as 'NOTA'
	from nota_alumno
	inner join evaluacion on evaluacion.eva_id = nota_alumno.eva_id
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where est_usr_id = idEstudiante and curso_profesor.curpro_id = Aula_Profesor order by evaluacion.eva_id;
    
        select SUM(not_calificacion) as 'SUMA NOTAS', COUNT(not_calificacion) as 'CANT. DE NOTAS', ROUND(AVG(not_calificacion),2) as 'PROMEDIO GENERAL'
	from nota_alumno
	inner join evaluacion on evaluacion.eva_id = nota_alumno.eva_id
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where est_usr_id = idEstudiante and curso_profesor.curpro_id = Aula_Profesor order by evaluacion.eva_id;
END$$
DELIMITER ;
-- CALL SP_notas_estudiante('45678912',1);

-- aulas de un profesor
DELIMITER $$
CREATE PROCEDURE SP_aulas(in idProfesor int)
BEGIN
	select curso_profesor.curpro_id as 'ID', crs_grado as 'GRADO', crs_seccion as 'SECCIÓN'
	from curso_profesor
	inner join curso on curso.crs_id = curso_profesor.crs_id
	where curso_profesor.pro_usr_id = idProfesor;
END$$
DELIMITER ;
-- CALL SP_aulas('45679212');

-- Lista de estudiantes de un Aula y una Asignatura
DELIMITER $$
CREATE PROCEDURE SP_lista_estudiantes_aula(in Aula_Profesor int)
BEGIN
	select ROW_NUMBER() OVER (ORDER BY usr_apellidos) AS 'N°', usr_id as 'ID', concat(usr_apellidos, ' ', usr_nombres) as 'ESTUDIANTE'
	from curso_profesor
	inner join curso on curso.crs_id = curso_profesor.crs_id
	inner join estudiante on estudiante.crs_id = curso.crs_id
	inner join usuario on usuario.usr_id = estudiante.est_usr_id
	where curso_profesor.curpro_id = Aula_Profesor order by usr_apellidos;
END$$
DELIMITER ;
-- CALL SP_lista_estudiantes_aula(1);

-- Información de fecha con respecto a una sesión
DELIMITER $$
CREATE PROCEDURE SP_informacion_fecha(fecha date)
BEGIN
    select fecses_id as 'ID', fecses_fecha as 'FECHA', ses_titulo as 'SESIÓN', uni_titulo as 'UNIDAD'
	from fecha_sesion
	inner join sesion on sesion.ses_id = fecha_sesion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	inner join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
	where fecses_fecha = fecha and curso_profesor.curpro_id = 1;
END$$
DELIMITER ;
-- CALL SP_informacion_fecha('2023-04-03');

-- Lista de Unidades de un Aula
DELIMITER $$
CREATE PROCEDURE SP_lista_unidades_aula( in Aula_Profesor int)
BEGIN
	SELECT uni_id as 'ID',uni_titulo as 'TITULO' FROM unidad WHERE curpro_id = Aula_Profesor;
END$$
DELIMITER ;
-- CALL SP_lista_unidades_aula(1);

-- Lista de Sesiones de una Unidad
DELIMITER $$
CREATE PROCEDURE SP_lista_sesiones_unidad( in idUnidad int)
BEGIN
	SELECT ses_id as 'ID',ses_titulo as 'TITULO' FROM sesion WHERE uni_id = idUnidad;
END$$
DELIMITER ;
-- CALL SP_lista_sesiones_unidad(1);

-- Lista de Fechas de una Sesión
DELIMITER $$
CREATE PROCEDURE SP_lista_fechas_sesion( in idSesion int)
BEGIN
	SELECT fecses_id as 'ID',fecses_fecha as 'FECHA' FROM fecha_sesion WHERE ses_id = idSesion;
END$$
DELIMITER ;
-- CALL SP_lista_fechas_sesion(1);

-- Agregar Nueva Fecha
DELIMITER $$
CREATE PROCEDURE SP_agregar_fecha(in idSesion int, fecha date)
BEGIN
	DECLARE registro tinyint;
    SET registro = (SELECT COUNT(*) FROM fecha_sesion where ses_id = idSesion and fecses_fecha = fecha);
    
    IF registro = 0 THEN
		INSERT INTO fecha_sesion(
		fecses_fecha,
		ses_id)
        VALUES
        (fecha, idSesion);
	ELSE
		select 'Ya existe esa fecha' as 'ERROR';
	END IF;
END$$
DELIMITER ;
-- CALL SP_agregar_fecha(1, '2023-05-16');
    
-- Agregar falta de estudiantes
DELIMITER $$
CREATE PROCEDURE SP_agregar_falta(IN idSesion int, fecha date, listaIdEstudiantes VARCHAR(255))
BEGIN
	DECLARE i INT DEFAULT 1;
	DECLARE idEstudiante VARCHAR(8);
	DECLARE longitud INT;
    DECLARE idFecha INT;
    
    -- Verificando si la fecha existe
	DECLARE registro int;
	SET registro = (SELECT COUNT(*) FROM fecha_sesion where ses_id = idSesion and fecses_fecha = fecha);

	IF registro = 0 THEN
		INSERT INTO fecha_sesion (fecses_fecha,ses_id) VALUES (fecha, idSesion);
		SET idFecha = LAST_INSERT_ID();
	ELSE
		SET idFecha = (SELECT fecses_id FROM fecha_sesion where ses_id = idSesion and fecses_fecha = fecha);
	END IF;
    
    -- Descomponiendo ID's de estudiantes
	SET longitud = LENGTH(listaIdEstudiantes) - LENGTH(REPLACE(listaIdEstudiantes, ',', '')) + 1;

	WHILE i <= longitud DO
		SET idEstudiante = CAST(substring_index(SUBSTRING_INDEX(listaIdEstudiantes, ',', i),',',-1) as signed);
		insert IGNORE into asistencia (est_usr_id, fecses_id) values (idEstudiante,idFecha);
		SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;
-- CALL SP_agregar_falta(1,'2023-05-16', '45678912,45678913,45678917');

-- Editar Sesion
DELIMITER $$
CREATE PROCEDURE SP_editar_sesion(in idSesion int, titulo varchar(50))
BEGIN
	update sesion set ses_titulo = titulo where ses_id = idSesion;
END$$
DELIMITER ;
-- CALL SP_editar_sesion(1, 'Sesión 1');

-- Editar Evaluación
DELIMITER $$
CREATE PROCEDURE SP_editar_evaluacion(in idEvaluacion int, titulo varchar(80), descripcion text, fechaInicio datetime, fechaFin datetime, link text, tipo tinyint)
BEGIN
	update evaluacion
    set
    eva_titulo = titulo,
    eva_desc = descripcion,
    eva_fecha_inicio = fechaInicio,
    eva_fecha_fin = fechaFin,
    eva_link = link,
    eva_tipo = tipo
    where eva_id = idEvaluacion;
END$$
DELIMITER ;
CALL SP_editar_evaluacion(1, 'Problemas de Matemáticas', 'Resolver problemas Matemáticos que involucren conceptos como álgebra, geometría, trigonometría, etc.' , '2023-04-03 08:10:00', '2023-04-10 10:10:00', 'www.colegio/tareas/JJJ',1);

-- Información Evaluación
DELIMITER $$
CREATE PROCEDURE SP_informacion_evaluacion(in idEvaluacion int)
BEGIN
	select eva_id as 'ID', eva_titulo as 'TÍTULO', eva_desc as 'DESCRIPCIÓN', eva_fecha_inicio as 'FECHA INICIO', eva_fecha_fin as 'FECHA FIN', eva_link as 'LINK', eva_tipo as 'TIPO',
	ses_titulo as 'SESIÓN', uni_titulo as 'UNIDAD'
	from evaluacion
	inner join sesion on sesion.ses_id = evaluacion.ses_id
	inner join unidad on unidad.uni_id = sesion.uni_id
	where eva_id = idEvaluacion;
END$$
DELIMITER ;
-- CALL SP_informacion_evaluacion(1);

-- Guardar calificacion
DELIMITER $$
CREATE PROCEDURE SP_guardar_calificacion(calificacion tinyint, in idEstudiante int, idEvaluacion int)
BEGIN
	DECLARE registro tinyint;
    SET registro = (select COUNT(*) from nota_alumno where eva_id = idEvaluacion and est_usr_id = idEstudiante);
    
    IF registro = 0 THEN
		insert into nota_alumno(
		not_calificacion,
		eva_id,
		est_usr_id)
		values
		(calificacion,idEvaluacion,idEstudiante);
	ELSE
		update nota_alumno set not_calificacion = calificacion where eva_id = idEvaluacion and est_usr_id = idEstudiante; 
	END IF;
END$$
DELIMITER ;
-- CALL SP_guardar_calificacion(19,'45678912',1); -- EXISTE
-- CALL SP_guardar_calificacion(20,'123',1); -- NO EXISTE

-- Lista de Unidades
DELIMITER $$

-- Agregar Nueva Sesión
DELIMITER $$
CREATE PROCEDURE SP_agregar_sesion(in idUnidad int, titulo varchar(50))
BEGIN
	INSERT INTO sesion(
    ses_titulo,
    uni_id)
    VALUES
    (titulo, idUnidad);
END$$
DELIMITER ;
-- CALL SP_agregar_sesion(221,'Sesión 4');

-- Agregar Nueva Clase
DELIMITER $$
CREATE PROCEDURE SP_agregar_clase(in titulo text, link text, idSesion int)
BEGIN
	INSERT INTO archivos(
    arc_titulo,
    arc_link,
    ses_id)
    VALUES
    (titulo, link, idSesion);
END$$
DELIMITER ;
-- CALL SP_agregar_clase('Diapositivas','www.colegio/archivos/ASD', 1);

-- Agregar Nueva Evaluación con Sesión existente
DELIMITER $$
CREATE PROCEDURE SP_agregar_evaluacion_sesionExiste(in titulo varchar(80), descripcion text, fechaInicio datetime, fechaFin datetime, link text, tipo tinyint, idSesion int)
BEGIN
	INSERT INTO evaluacion(
    eva_titulo,
	eva_desc,
	eva_fecha_inicio,
	eva_fecha_fin,
	eva_link,
	eva_tipo,
	ses_id
    )
    VALUES
    (titulo, descripcion, fechaInicio, fechaFin, link, tipo, idSesion);
END$$
DELIMITER ;
-- CALL SP_agregar_evaluacion_sesionExiste('Problemas de Integrales', 'Resolver 5 problemas de integrales', '2023-04-03 08:20:00', '2023-04-10 10:20:00', 'www.colegio/tareas/HHH', 1,1);

-- Agregar Nueva Evaluación con Sesión existente
DELIMITER $$
CREATE PROCEDURE SP_agregar_evaluacion_sesionNoExiste(in idUnidad int, sesionTitulo varchar(50), titulo varchar(80), descripcion text, fechaInicio datetime, fechaFin datetime, link text, tipo tinyint, idSesion int)
BEGIN
    DECLARE idSesion INT;
    DECLARE exito INT DEFAULT 0;
    
    START TRANSACTION;
		-- Insertar nueva sesión
		INSERT INTO sesion (ses_titulo,uni_id) VALUES (sesionTitulo, idUnidad);
		SET idSesion = LAST_INSERT_ID();
        
        -- Insertar evaluación
        IF idSesion IS NOT NULL THEN
			INSERT INTO evaluacion(
			eva_titulo,
			eva_desc,
			eva_fecha_inicio,
			eva_fecha_fin,
			eva_link,
			eva_tipo,
			ses_id
			)
			VALUES
			(titulo, descripcion, fechaInicio, fechaFin, link, tipo, idSesion);
            SET exito = 1;
		END IF;
        
		IF exito = 1 THEN
			COMMIT;
			SELECT 'Evaluación agregada exitosamente' AS mensaje;
		ELSE
			ROLLBACK;
			SELECT 'Error al agregar la nueva sesión' AS mensaje;
    END IF;
END$$
DELIMITER ;
-- CALL SP_agregar_evaluacion_sesionNoExiste( 1,'Sesión 5', 'Problemas de Integrales 2', 'Resolver 5 problemas de integrales', '2023-04-03 08:20:00', '2023-04-10 10:20:00', 'www.colegio/tareas/HHH', 1,1);

-- Notas de estudiantes de un Aula
DELIMITER $$
CREATE PROCEDURE SP_lista_notas_aula(in Aula_Profesor int)
BEGIN
	select ROW_NUMBER() OVER (ORDER BY e.eva_id, usr_apellidos) AS 'N°', es.est_usr_id AS 'ID',CONCAT(usr_apellidos, ' ' ,usr_nombres) as 'ESTUDIANTE', not_calificacion as 'NOTA', n.eva_id as 'ID EVALUACIÓN'
	from nota_alumno n
	join estudiante es on es.est_usr_id = n.est_usr_id
	join usuario u on u.usr_id = es.est_usr_id
	join evaluacion e on e.eva_id = n.eva_id
	where es.est_usr_id 
	IN (
		select estudiante.est_usr_id
		from estudiante
		join curso on curso.crs_id = estudiante.crs_id
		join curso_profesor on curso_profesor.crs_id = curso.crs_id
		where curso_profesor.curpro_id = Aula_Profesor
	)
	AND n.eva_id
	IN (
		select evaluacion.eva_id
		from evaluacion
		join sesion on sesion.ses_id = evaluacion.ses_id
		join unidad on unidad.uni_id = sesion.uni_id
		join curso_profesor on curso_profesor.curpro_id = unidad.curpro_id
		where curso_profesor.curpro_id = Aula_Profesor
	) order by e.eva_id and usr_apellidos ;
    
		select e.eva_id as 'ID EVALUACIÓN', e.eva_titulo as 'TÍTULO'
		from evaluacion e
		join sesion s on s.ses_id = e.ses_id
		join unidad u on u.uni_id = s.uni_id
		join curso_profesor c on c.curpro_id = u.curpro_id
		where c.curpro_id = Aula_Profesor;
END$$
DELIMITER ;
-- CALL SP_lista_notas_aula(1);

-- Eliminar Clase (Archivo)
DELIMITER $$
CREATE PROCEDURE SP_eliminar_clase(in idClase int)
BEGIN
	delete from archivos where arc_id = idClase;
END$$
DELIMITER ;
-- CALL SP_eliminar_clase(661);

-- Eliminar Evaluación
DELIMITER $$
CREATE PROCEDURE SP_eliminar_evaluacion(in idEvaluacion int)
BEGIN
	delete from evaluacion where eva_id = idEvaluacion;
END$$
DELIMITER ;
-- CALL SP_eliminar_evaluacion(881);

DELIMITER $$
CREATE PROCEDURE SP_obtener_datos(IN curpro_id INT)
BEGIN
    SELECT unidad.curpro_id AS 'CURPRO', unidad.uni_id AS 'IDUNIDAD', unidad.uni_titulo AS 'TITULOUNI', sesion.ses_id AS 'IDSESION', sesion.ses_titulo AS 'TITULOSES', archivos.arc_id AS 'IDARC', archivos.arc_titulo AS 'TITULOARC', archivos.arc_link AS 'LINKARC'
    FROM unidad
    INNER JOIN sesion ON unidad.uni_id = sesion.uni_id
    INNER JOIN archivos ON sesion.ses_id = archivos.ses_id
    WHERE unidad.curpro_id = curpro_id;

    SELECT unidad.curpro_id AS 'CURPRO', unidad.uni_id AS 'IDUNIDAD', unidad.uni_titulo AS 'TITULOUNI', sesion.ses_id AS 'IDSESION', sesion.ses_titulo AS 'TITULOSES', evaluacion.eva_id AS 'IDEVA', evaluacion.eva_titulo AS 'TITULOEVA', evaluacion.eva_desc AS 'DESCEVA', evaluacion.eva_fecha_inicio AS 'EVAINICIO', evaluacion.eva_fecha_fin AS 'EVAFIN', evaluacion.eva_link AS 'LINKEVA', evaluacion.eva_tipo AS 'TIPOEVA'
    FROM unidad
    INNER JOIN sesion ON unidad.uni_id = sesion.uni_id
    INNER JOIN evaluacion ON sesion.ses_id = evaluacion.ses_id
    WHERE unidad.curpro_id = curpro_id;
END$$
DELIMITER ;
-- CALL SP_obtener_datos(1);

-- Lista de grados
DELIMITER $$
CREATE PROCEDURE SP_lista_grados()
BEGIN
	select crs_grado as 'GRADO' from curso group by crs_grado;
END$$
DELIMITER ;
-- CALL SP_lista_grados();

-- Promedio de Notas de Grados (comparativa de Grados)
DELIMITER $$
CREATE PROCEDURE SP_promedio_grados()
BEGIN
	select c.crs_grado as 'GRADO', WEEK(e.eva_fecha_inicio) as 'SEMANA', ROUND(AVG(n.not_calificacion),2) as 'PROMEDIO'
	from nota_alumno n
    join evaluacion e on e.eva_id = n.eva_id
    join sesion s on s.ses_id = e.ses_id
    join unidad u on u.uni_id = s.uni_id
    join curso_profesor cup on cup.curpro_id = u.curpro_id
    join curso c on c.crs_id = cup.crs_id
    group by c.crs_grado, WEEK(e.eva_fecha_inicio);
END$$
DELIMITER ;
-- CALL SP_promedio_grados()

-- Lista de Secciones
DELIMITER $$
CREATE PROCEDURE SP_lista_secciones()
BEGIN
	select crs_seccion as 'SECCIÓN' from curso group by crs_seccion;
END$$
DELIMITER ;
-- CALL SP_lista_secciones();

-- Lista de Secciones de un Grado
DELIMITER $$
CREATE PROCEDURE SP_lista_secciones_xgrado(in Grado int)
BEGIN
	select crs_seccion as 'SECCIÓN' from curso where crs_grado = Grado group by crs_seccion;
END$$
DELIMITER ;
-- CALL SP_lista_secciones_xgrado(1);

-- Promedio de Notas de Secciones de un Grado Seleccionado
DELIMITER $$
CREATE PROCEDURE SP_promedio_secciones(in Grado int)
BEGIN
	select c.crs_seccion as 'SECCIÓN', WEEK(e.eva_fecha_inicio) as 'SEMANA', ROUND(AVG(n.not_calificacion),2) as 'PROMEDIO'
	from nota_alumno n
    join evaluacion e on e.eva_id = n.eva_id
    join sesion s on s.ses_id = e.ses_id
    join unidad u on u.uni_id = s.uni_id
    join curso_profesor cup on cup.curpro_id = u.curpro_id
    join curso c on c.crs_id = cup.crs_id
    where c.crs_grado = Grado
    group by c.crs_seccion, WEEK(e.eva_fecha_inicio);
END$$
DELIMITER ;
-- CALL SP_promedio_secciones(1);

-- Lista de Cursos
DELIMITER $$
CREATE PROCEDURE SP_lista_asignaturas()
BEGIN
	select asi_id as 'ID', asi_desc AS 'ASIGNATURA' from asignatura;
END$$
DELIMITER ;
-- CALL SP_lista_asignaturas();

-- Lista de Cursos de un Aula
DELIMITER $$
CREATE PROCEDURE SP_lista_asignaturas_xseccion(in Grado int, Seccion CHAR)
BEGIN
	select a.asi_id as 'ID', asi_desc AS 'ASIGNATURA'
    from asignatura a
	join curso_profesor cup on cup.asi_id = a.asi_id
	join curso c on c.crs_id = cup.crs_id
	where crs_grado = Grado and crs_seccion = Seccion;
END$$
DELIMITER ;
-- CALL SP_lista_asignaturas_xseccion(1, 'A');

-- Promedio de Notas de Curso de un Grado y Sección Seleccionados
DELIMITER $$
CREATE PROCEDURE SP_promedio_asignaturas(in Grado int, Seccion char)
BEGIN
	select a.asi_id as 'ID ASIGNATURA', a.asi_desc as 'ASIGNATURA', WEEK(e.eva_fecha_inicio) as 'SEMANA', ROUND(AVG(n.not_calificacion),2) as 'PROMEDIO'
	from nota_alumno n
    join evaluacion e on e.eva_id = n.eva_id
    join sesion s on s.ses_id = e.ses_id
    join unidad u on u.uni_id = s.uni_id
    join curso_profesor cup on cup.curpro_id = u.curpro_id
    join curso c on c.crs_id = cup.crs_id
    join asignatura a on a.asi_id = cup.asi_id
    where c.crs_grado = Grado and c.crs_seccion = Seccion
    group by a.asi_id, WEEK(e.eva_fecha_inicio);
END$$
DELIMITER ;
-- CALL SP_promedio_asignaturas(1, 'A');

-- Pocentaje de notas de un aula
DELIMITER $$
CREATE PROCEDURE SP_porcentaje_notas_aula(in idAula int, idEvaluacion int)
BEGIN
	DECLARE totalAlumnos int;
    
    SET totalAlumnos = (select count(es.est_usr_id) as cant
	from nota_alumno n
    join estudiante es on es.est_usr_id = n.est_usr_id
    join curso c on c.crs_id = es.crs_id
    where c.crs_id = idAula and n.eva_id = idEvaluacion);
    
    select n.not_calificacion AS 'NOTA', count(es.est_usr_id) as 'CANTIDAD', concat(round((count(es.est_usr_id)/totalAlumnos)*100,2),'%') as 'PORCENTAJE'
    from nota_alumno n	
    join estudiante es on es.est_usr_id = n.est_usr_id
    join curso c on c.crs_id = es.crs_id
    where c.crs_id = idAula and n.eva_id = idEvaluacion
    group by n.not_calificacion order by n.not_calificacion desc;
END$$
DELIMITER ;
-- CALL SP_porcentaje_notas_aula(2, 12);

-- Lista de profesores de un curso seleccionado
DELIMITER $$
CREATE PROCEDURE SP_lista_profesores_xasignatura(in idAsignatura int)
BEGIN
	select u.usr_id as 'ID', concat(usr_apellidos, ' ', usr_nombres) as 'PROFESOR'
	from usuario u
	join profesor p on p.pro_usr_id = u.usr_id
	join curso_profesor cup on cup.pro_usr_id = p.pro_usr_id
	join asignatura a on a.asi_id = cup.asi_id
	where cup.asi_id = idAsignatura group by cup.pro_usr_id;
END$$
DELIMITER ;
-- CALL SP_lista_profesores_xasignatura(1);

-- Promedio de Notas de profesores de una Asignatura Seleccionada
DELIMITER $$
CREATE PROCEDURE SP_promedio_profesores_xasignatura(in idAsignatura int)
BEGIN
	select cup.pro_usr_id as 'ID', concat(usr_apellidos, ' ', usr_nombres) as 'PROFESOR', WEEK(e.eva_fecha_inicio) as 'SEMANA', ROUND(AVG(n.not_calificacion),2) as 'PROMEDIO'
	from nota_alumno n
    join evaluacion e on e.eva_id = n.eva_id
    join sesion s on s.ses_id = e.ses_id
    join unidad un on un.uni_id = s.uni_id
    join curso_profesor cup on cup.curpro_id = un.curpro_id
	join profesor p on p.pro_usr_id = cup.pro_usr_id
    join usuario u on u.usr_id = p.pro_usr_id
    join asignatura a on a.asi_id = cup.asi_id
    where cup.asi_id = idAsignatura
    group by cup.pro_usr_id, WEEK(e.eva_fecha_inicio);
END$$
DELIMITER ;
-- CALL SP_promedio_profesores_xasignatura(1);

-- Promedio de Notas de un Profesor y una Asignatura Seleccionados
DELIMITER $$
CREATE PROCEDURE SP_promedio_secciones_xprofesor_xasignatura(in idProfesor int, idAsignatura int)
BEGIN
	select c.crs_seccion as 'SECCIÓN', WEEK(e.eva_fecha_inicio) as 'SEMANA', ROUND(AVG(n.not_calificacion),2) as 'PROMEDIO'
	from nota_alumno n
    join evaluacion e on e.eva_id = n.eva_id
    join sesion s on s.ses_id = e.ses_id
    join unidad u on u.uni_id = s.uni_id
    join curso_profesor cup on cup.curpro_id = u.curpro_id
    join curso c on c.crs_id = cup.crs_id
	join profesor p on p.pro_usr_id = cup.pro_usr_id
    join asignatura a on a.asi_id = cup.asi_id
    where cup.pro_usr_id = idProfesor and cup.asi_id = idAsignatura
    group by c.crs_seccion, WEEK(e.eva_fecha_inicio);
END$$
DELIMITER ;
-- CALL SP_promedio_secciones_xprofesor_xasignatura('45679212', 1);


DELIMITER $$
CREATE PROCEDURE SP_datos_aula(IN p_pro_usr_id VARCHAR(10), IN p_crs_seccion VARCHAR(10), IN p_crs_grado INT)
BEGIN
    SELECT curso.crs_id AS 'IDCURSO', curso.crs_grado AS 'GRADOAULA', curso.crs_seccion AS 'SECCAULA', curso_profesor.curpro_id AS 'IDCURPROF', curso_profesor.pro_usr_id AS 'IDPROF', 
    curso_profesor.asi_id AS 'IDASIG', asignatura.asi_desc AS 'NOMASIG', curso_horario.curhor_dia AS 'DIACUR', MIN(horario.hor_hora_inicio) AS 'HORAINICIO', MAX(horario.hor_hora_fin) AS 'HORAFIN'
    FROM curso
    INNER JOIN curso_profesor ON curso_profesor.crs_id = curso.crs_id
    INNER JOIN asignatura ON asignatura.asi_id = curso_profesor.asi_id
    INNER JOIN curso_horario ON curso_horario.curpro_id = curso_profesor.curpro_id
    INNER JOIN horario ON horario.hor_id = curso_horario.hor_id
    WHERE curso.crs_seccion = p_crs_seccion AND curso.crs_grado = p_crs_grado AND curso_profesor.pro_usr_id = p_pro_usr_id
    GROUP BY
        curso.crs_id, curso.crs_grado, curso.crs_seccion, curso_profesor.curpro_id, curso_profesor.pro_usr_id, curso_profesor.asi_id, asignatura.asi_desc, curso_horario.curhor_dia;
END$$
DELIMITER ;
-- CALL SP_datos_aula('45679212', 'A', 1);

-- Editar Clase
DELIMITER $$
CREATE PROCEDURE SP_editar_ses(IN arctitulo VARCHAR(255), IN arclink VARCHAR(255), IN sesid INT)
BEGIN
    UPDATE sesion
    JOIN archivos ON sesion.ses_id = archivos.ses_id
    SET archivos.arc_titulo = arctitulo, archivos.arc_link = arclink
    WHERE sesion.ses_id = sesid;
END$$
DELIMITER ;
-- CALL SP_editar_ses('Clase N° 1', 'www.colegio/archivos/1254', 1);

-- Nuevo Informacion del curso seleccionado
DELIMITER $$
CREATE PROCEDURE SP_obtener_informacion_curso(IN curpro_id INT)
BEGIN
    SELECT asignatura.asi_id AS 'ID_ASIGNATURA', asignatura.asi_desc AS 'DESCRIPCION_ASIGNATURA', profesor.pro_usr_id AS 'ID_PROFESOR', CONCAT(usuario.usr_nombres, ' ',usuario.usr_apellidos) AS 'PROFESOR', curso.crs_id AS 'ID_AULA', curso.crs_grado AS 'GRADO_AULA', curso.crs_seccion AS 'SECCION_AULA', curso_horario.curhor_dia AS 'DIA_CURSO', MIN(horario.hor_hora_inicio) AS 'HORA_INICIO', MAX(horario.hor_hora_fin) AS 'HORA_FIN'
    FROM asignatura
    INNER JOIN curso_profesor ON asignatura.asi_id = curso_profesor.asi_id
    INNER JOIN curso ON curso_profesor.crs_id = curso.crs_id
    INNER JOIN curso_horario ON curso_profesor.curpro_id = curso_horario.curpro_id
    INNER JOIN horario ON curso_horario.hor_id = horario.hor_id
    INNER JOIN profesor ON curso_profesor.pro_usr_id = profesor.pro_usr_id
    INNER JOIN usuario ON profesor.pro_usr_id = usuario.usr_id
    WHERE curso_profesor.curpro_id = curpro_id
    GROUP BY asignatura.asi_id, asignatura.asi_desc, profesor.pro_usr_id, usuario.usr_nombres, usuario.usr_apellidos, curso.crs_id, curso.crs_grado, curso.crs_seccion, curso_horario.curhor_dia;
END$$
DELIMITER ;
-- CALL SP_obtener_informacion_curso(1);
    
DELIMITER $$
CREATE PROCEDURE SP_obtener_sesiones(IN p_curpro_id INT)
BEGIN
    SELECT sesion.ses_id AS 'ID_SESION', sesion.ses_titulo AS 'SES_TITULO', unidad.uni_id AS 'ID_UNIDAD', curso_profesor.curpro_id AS 'ID_CURSO_PROFESOR', archivos.arc_id AS 'ID_ARCHIVO'
    FROM sesion
    INNER JOIN unidad ON sesion.uni_id = unidad.uni_id
    INNER JOIN curso_profesor ON unidad.curpro_id = curso_profesor.curpro_id
    LEFT JOIN archivos ON sesion.ses_id = archivos.ses_id
    WHERE curso_profesor.curpro_id = p_curpro_id OR archivos.arc_id IS NULL;
END$$
DELIMITER ;
-- CALL SP_obtener_sesiones(4);