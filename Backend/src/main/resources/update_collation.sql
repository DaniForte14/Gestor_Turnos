-- Actualizar la intercalación de la base de datos
ALTER DATABASE gestor_horarios CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Actualizar la intercalación de las tablas
ALTER TABLE horario_roles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE horarios CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE solicitudes_cambio CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE user_roles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vehiculos CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Actualizar la intercalación de las columnas de texto
ALTER TABLE users MODIFY username VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY password VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY nombre VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY apellidos VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY centro_trabajo VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY localidad VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY role VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE vehiculos MODIFY marca VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vehiculos MODIFY modelo VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vehiculos MODIFY matricula VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vehiculos MODIFY color VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vehiculos MODIFY observaciones VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
