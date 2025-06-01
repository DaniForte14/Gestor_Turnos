-- Script SQL para inicializar la base de datos Gestor de Horarios
-- Ejecuta este script en tu cliente MySQL (como MySQL Workbench o línea de comandos)

-- Eliminar la base de datos si existe
DROP DATABASE IF EXISTS gestor_horarios;

-- Crear la base de datos con la configuración correcta de caracteres
CREATE DATABASE gestor_horarios 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE gestor_horarios;

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
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_schedules_user (user_id),
    INDEX idx_schedules_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    FOREIGN KEY (target_schedule_id) REFERENCES schedules(id),
    INDEX idx_shift_requests_requester (requester_id),
    INDEX idx_shift_requests_receiver (receiver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla para almacenar los roles permitidos para cada horario
CREATE TABLE IF NOT EXISTS schedule_roles (
    schedule_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (schedule_id, role),
    FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mostrar las tablas creadas
SHOW TABLES;

-- Mostrar la estructura de las tablas
SHOW CREATE TABLE users;
SHOW CREATE TABLE vehicles;
SHOW CREATE TABLE user_vehicle_passengers;
SHOW CREATE TABLE schedules;
SHOW CREATE TABLE shift_change_requests;
SHOW CREATE TABLE schedule_roles;
