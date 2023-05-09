create database db_colegio;
use db_colegio;

create table usuario_tipo (
	tip_id int auto_increment primary key,
    tip_desc varchar(20)
);

create table horario(
	hor_id int auto_increment primary key,
    hor_hora_inicio time,
    hor_hora_fin time
);

create table asignatura(
	asi_id int auto_increment primary key,
    asi_desc varchar(50)
);

create table curso(
	crs_id int auto_increment primary key,
    crs_grado tinyint,
    crs_seccion char
);

create table anuncio(
	anu_id int auto_increment primary key,
    anu_titulo varchar(50),
    anu_desc text,
    anu_fecha_inicio datetime,
    anu_fecha_fin datetime,
    anu_link text
);

create table usuario(
	usr_id varchar(8) primary key,
	usr_pass varchar(16),
	usr_nombres varchar(55),
    usr_apellidos varchar(55),
    usr_correo varchar(50),
    usr_fechaNacimiento date,
    usr_telefono varchar(9),
    usr_ubicacion varchar(50),
    usr_direccion varchar(120),
    usr_sexo enum("hombre","mujer") not null,
	tip_id int not null,
    foreign key (tip_id) references usuario_tipo(tip_id)
);

create table estudiante(
	est_usr_id varchar(8) primary key,
    crs_id int not null,
    foreign key (est_usr_id) references usuario(usr_id),
    foreign key (crs_id) references curso(crs_id)
    );
    
create table profesor(
	pro_usr_id varchar(8) primary key,
	foreign key (pro_usr_id) references usuario(usr_id)
    );

create table director(
	direc_usr_id varchar(8) primary key,
	foreign key (direc_usr_id) references usuario(usr_id)
    );

create table curso_profesor(
	curpro_id int auto_increment primary key,
    crs_id int not null,
    pro_usr_id varchar(8) not null,
    asi_id int not null,
	foreign key (crs_id) references curso(crs_id),
	foreign key (pro_usr_id) references profesor(pro_usr_id),
	foreign key (asi_id) references asignatura(asi_id)
    );
    
create table curso_horario(
	curhor_id int auto_increment primary key,
    curhor_dia enum('lunes','martes','miércoles','jueves','viernes'),
    hor_id int not null,
    curpro_id int not null,
    foreign key (hor_id) references horario(hor_id),
    foreign key (curpro_id) references curso_profesor(curpro_id)
    );

create table unidad(
	uni_id int auto_increment primary key,
    uni_titulo varchar(50),
    curpro_id int not null,
    foreign key (curpro_id) references curso_profesor(curpro_id)
    );
    
create table sesion(
	ses_id int auto_increment primary key,
	ses_titulo varchar(50),
    uni_id int not null,
    foreign key (uni_id) references unidad(uni_id)
    );
    
/*create table sesion_horario(
	seshor_id int not null,
    curhor_id int not null,
    primary key(seshor_id,curhor_id),
    foreign key(seshor_id) references sesion(ses_id) on delete cascade,
    foreign key(curhor_id) references curso_horario(curhor_id)
    );*/
    
create table fecha_sesion(
	fecses_id int auto_increment primary key,
    fecses_fecha date,
    ses_id int not null,
    foreign key(ses_id) references sesion(ses_id)
    );

create table evaluacion(
	eva_id int auto_increment primary key,
    eva_titulo varchar(80),
    eva_desc text,
    eva_fecha_inicio datetime,
    eva_fecha_fin datetime,
    eva_link text,
    eva_tipo tinyint,
    ses_id int not null,
    foreign key (ses_id) references sesion(ses_id) on delete cascade
    );
    
create table nota_alumno(
	not_id int auto_increment primary key,
    not_calificacion tinyint,
    eva_id int not null,
    est_usr_id varchar(8) not null,
    foreign key (eva_id) references evaluacion(eva_id) ON DELETE CASCADE,
    foreign key (est_usr_id) references estudiante(est_usr_id)
    );

create table asistencia(
	est_usr_id varchar(8) not null,
    fecses_id int not null,
    primary key(est_usr_id,fecses_id),
    foreign key (est_usr_id) references estudiante(est_usr_id) on delete cascade,
    foreign key (fecses_id) references fecha_sesion(fecses_id) on delete cascade
    );