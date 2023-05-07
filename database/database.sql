CREATE SCHEMA `colegio` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE alumnos;
CREATE TABLE `colegio`.`estudiantes` (
  `id` INT UNSIGNED NOT NULL,
  `primerNombre` VARCHAR(20) NOT NULL,
  `segundoNombre` VARCHAR(20) NULL,
  `apellidoPaterno` VARCHAR(25) NOT NULL,
  `apellidoMaterno` VARCHAR(25) NOT NULL,
  `grado` VARCHAR(10) NOT NULL,
  `seccion` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;