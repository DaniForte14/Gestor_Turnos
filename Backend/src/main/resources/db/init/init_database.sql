-- Script para inicializar la base de datos

-- Eliminar la base de datos si existe
DROP DATABASE IF EXISTS gestor_horarios;

-- Crear la base de datos con la configuración correcta de caracteres
CREATE DATABASE gestor_horarios 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE gestor_horarios;

-- Aplicar el esquema
SOURCE src/main/resources/schema.sql;

-- Mostrar las tablas creadas
SHOW TABLES;
