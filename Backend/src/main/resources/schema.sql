-- Esquema para la base de datos del gestor de horarios

-- Configuración de charset y collation por defecto
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    work_center VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER',
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_role CHECK (role IN ('ROLE_ADMIN', 'ROLE_MEDICO', 'ROLE_ENFERMERO', 'ROLE_AUXILIAR', 'ROLE_USER')),
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Migrar datos existentes desde user_roles a users (ejecutar solo una vez después de la migración)
-- UPDATE users u
-- JOIN user_roles ur ON u.id = ur.user_id
-- SET u.role = ur.role,
--     u.is_admin = (ur.role = 'ROLE_ADMIN');

-- Eliminar la tabla user_roles después de migrar los datos
-- DROP TABLE IF EXISTS user_roles;

-- Tabla de vehículos
CREATE TABLE IF NOT EXISTS vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    total_seats INTEGER NOT NULL,
    available_seats INTEGER NOT NULL,
    owner_id BIGINT,
    active BOOLEAN DEFAULT TRUE,
    observations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_license_plate (license_plate),
    INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de relación muchos a muchos entre vehículos y pasajeros
CREATE TABLE IF NOT EXISTS user_vehicle_passengers (
    vehicle_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, vehicle_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_vehicle_passenger (vehicle_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de horarios
CREATE TABLE IF NOT EXISTS schedules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    shift_type VARCHAR(20),
    available BOOLEAN DEFAULT FALSE,
    exchanged BOOLEAN DEFAULT FALSE,
    notes VARCHAR(500), 
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tabla de solicitudes de cambio
CREATE TABLE IF NOT EXISTS shift_change_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    requester_id BIGINT NOT NULL,
    receiver_id BIGINT,
    source_schedule_id BIGINT NOT NULL,
    target_schedule_id BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    FOREIGN KEY (requester_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    FOREIGN KEY (source_schedule_id) REFERENCES schedules(id),
    FOREIGN KEY (target_schedule_id) REFERENCES schedules(id)
);

-- Índices para optimizar consultas
-- En MySQL, simplemente creamos los índices directamente
-- Si el índice ya existe, MySQL ignorará el error con esta sintaxis

-- Índices para tabla schedules
CREATE INDEX idx_schedules_user ON schedules(user_id);
CREATE INDEX idx_schedules_date ON schedules(date);

-- Índices para tabla shift_change_requests
CREATE INDEX idx_shift_requests_requester ON shift_change_requests(requester_id);
CREATE INDEX idx_shift_requests_receiver ON shift_change_requests(receiver_id);

-- Índice para tabla vehicles
CREATE INDEX idx_vehicles_owner ON vehicles(owner_id);

-- Tabla para almacenar los roles permitidos para cada horario
CREATE TABLE IF NOT EXISTS schedule_roles (
    schedule_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (schedule_id, role),
    FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
);
