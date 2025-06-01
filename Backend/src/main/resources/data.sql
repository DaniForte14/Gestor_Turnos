-- Datos de prueba para la base de datos del gestor de horarios

-- Usuario administrador
-- Usuario: admin
-- Contraseña: admin123

-- Eliminar usuarios existentes (opcional, descomentar si es necesario)
-- DELETE FROM horarios;
-- DELETE FROM vehiculos;
-- DELETE FROM users;

-- Insertar o actualizar usuario administrador
INSERT INTO users (username, password, nombre, apellidos, email, centro_trabajo, localidad, telefono, role, is_admin, fecha_creacion, fecha_actualizacion) 
VALUES ('admin', 'admin123', 'Admin', 'Administrador', 'admin@sistema.com', 'Administración Central', 'Sede Central', '123456789', 'ROLE_ADMIN', TRUE, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    password = 'admin123',
    nombre = 'Admin',
    apellidos = 'Administrador',
    email = 'admin@sistema.com',
    centro_trabajo = 'Administración Central',
    localidad = 'Sede Central',
    telefono = '123456789',
    role = 'ROLE_ADMIN',
    is_admin = TRUE,
    fecha_actualizacion = NOW();

-- Insertar o actualizar usuario médico de ejemplo
INSERT INTO users (username, password, nombre, apellidos, email, centro_trabajo, localidad, telefono, role, is_admin, fecha_creacion, fecha_actualizacion) 
VALUES ('medico1', 'medico123', 'Carlos', 'González', 'medico1@ejemplo.com', 'Centro Médico Norte', 'Madrid', '612345678', 'ROLE_MEDICO', FALSE, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    password = 'medico123',
    nombre = 'Carlos',
    apellidos = 'González',
    email = 'medico1@ejemplo.com',
    centro_trabajo = 'Centro Médico Norte',
    localidad = 'Madrid',
    telefono = '612345678',
    role = 'ROLE_MEDICO',
    is_admin = FALSE,
    fecha_actualizacion = NOW();

-- Insertar o actualizar usuario enfermero de ejemplo
INSERT INTO users (username, password, nombre, apellidos, email, centro_trabajo, localidad, telefono, role, is_admin, fecha_creacion, fecha_actualizacion) 
VALUES ('enfermero1', 'enfermero123', 'Laura', 'Martínez', 'enfermero1@ejemplo.com', 'Centro Médico Sur', 'Barcelona', '623456789', 'ROLE_ENFERMERO', FALSE, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    password = 'enfermero123',
    nombre = 'Laura',
    apellidos = 'Martínez',
    email = 'enfermero1@ejemplo.com',
    centro_trabajo = 'Centro Médico Sur',
    localidad = 'Barcelona',
    telefono = '623456789',
    role = 'ROLE_ENFERMERO',
    is_admin = FALSE,
    fecha_actualizacion = NOW();

-- Insertar vehículos de ejemplo
INSERT INTO vehiculos (brand, model, license_plate, total_seats, available_seats, user_id, active, observations)
VALUES 
    ('Toyota', 'Corolla', '1234ABC', 4, 4, 2, TRUE, 'Aire acondicionado, maletero grande'),
    ('Seat', 'León', '5678DEF', 3, 3, 3, TRUE, 'Solo ida y vuelta al hospital'),
    ('Volkswagen', 'Golf', '9012GHI', 2, 2, 2, TRUE, 'Disponible por las mañanas')
ON DUPLICATE KEY UPDATE 
    brand = VALUES(brand),
    model = VALUES(model),
    license_plate = VALUES(license_plate),
    total_seats = VALUES(total_seats),
    available_seats = VALUES(available_seats),
    user_id = VALUES(user_id),
    active = VALUES(active),
    observations = VALUES(observations);
