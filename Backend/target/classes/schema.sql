-- Esquema para la base de datos del gestor de horarios

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    centro_trabajo VARCHAR(100) NOT NULL,
    localidad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    is_admin BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de roles de usuario
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, role),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabla de vehículos
CREATE TABLE IF NOT EXISTS vehiculos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    color VARCHAR(30),
    asientos_disponibles INTEGER,
    usuario_id BIGINT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    observaciones VARCHAR(500),
    FOREIGN KEY (usuario_id) REFERENCES users(id)
);

-- Tabla de horarios
CREATE TABLE IF NOT EXISTS horarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME,
    hora_fin TIME,
    tipo_turno VARCHAR(20),
    disponible BOOLEAN DEFAULT FALSE,
    intercambiado BOOLEAN DEFAULT FALSE,
    notas VARCHAR(500),
    FOREIGN KEY (usuario_id) REFERENCES users(id)
);

-- Tabla de solicitudes de cambio
CREATE TABLE IF NOT EXISTS solicitudes_cambio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    solicitante_id BIGINT NOT NULL,
    receptor_id BIGINT,
    horario_origen_id BIGINT NOT NULL,
    horario_destino_id BIGINT,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    mensaje TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta TIMESTAMP,
    FOREIGN KEY (solicitante_id) REFERENCES users(id),
    FOREIGN KEY (receptor_id) REFERENCES users(id),
    FOREIGN KEY (horario_origen_id) REFERENCES horarios(id),
    FOREIGN KEY (horario_destino_id) REFERENCES horarios(id)
);

-- Índices para optimizar consultas
-- En MySQL, simplemente creamos los índices directamente
-- Si el índice ya existe, MySQL ignorará el error con esta sintaxis

-- Índices para tabla horarios
CREATE INDEX idx_horarios_usuario ON horarios(usuario_id);
CREATE INDEX idx_horarios_fecha ON horarios(fecha);

-- Índices para tabla solicitudes_cambio
CREATE INDEX idx_solicitudes_solicitante ON solicitudes_cambio(solicitante_id);
CREATE INDEX idx_solicitudes_receptor ON solicitudes_cambio(receptor_id);

-- Índice para tabla vehiculos
CREATE INDEX idx_vehiculos_usuario ON vehiculos(usuario_id);
