-- Datos de prueba para la base de datos del gestor de horarios

-- Usuario administrador
-- Usuario: admin
-- Contraseña: admin123

-- Eliminar usuarios existentes (opcional, descomentar si es necesario)
-- DELETE FROM horarios;
-- DELETE FROM vehiculos;
-- DELETE FROM users;

-- Insertar o actualizar usuario administrador
INSERT INTO users (username, password, nombre, apellidos, email, centro_trabajo, localidad, telefono, fecha_creacion, fecha_actualizacion) 
VALUES ('admin', 'admin123', 'Admin', 'Administrador', 'admin@sistema.com', 'Administración Central', 'Sede Central', '123456789', NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    password = 'admin123',
    nombre = 'Admin',
    apellidos = 'Administrador',
    email = 'admin@sistema.com',
    centro_trabajo = 'Administración Central',
    localidad = 'Sede Central',
    telefono = '123456789',
    fecha_actualizacion = NOW();
