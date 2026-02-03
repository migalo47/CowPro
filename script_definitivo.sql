DROP DATABASE IF EXISTS cowpro;
-- CREAR BD
CREATE DATABASE cowpro;

USE cowpro;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    correo VARCHAR(255) UNIQUE,
    telefono VARCHAR(255),
    tipo_usuario ENUM('CLIENTE', 'EMPLEADO', 'ADMIN'),
    huella_dactilar VARCHAR(255),  -- Almacena el hash de la huella
    contrasena VARCHAR(255),       -- Almacena el hash de la contraseña
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE espacios (
    id_espacio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    tipo_espacio ENUM('COWORKING', 'DESPACHO', 'SALA_REUNIONES', 'PLATO_TELEVISION', 'AULA'),
    precio_por_hora DECIMAL(38, 2),
    precio_por_dia DECIMAL(38, 2),
    precio_por_mes DECIMAL(38, 2),
    disponibilidad BOOLEAN DEFAULT TRUE,
    device_id VARCHAR(255) UNIQUE,
    imagen_url VARCHAR (255),
    capacidad INTEGER
);



CREATE TABLE equipos (
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    tipo_equipo ENUM('PROYECTOR', 'CAMARA', 'MICROFONO', 'COMPUTADORA', 'OTRO'),
    precio_por_dia DECIMAL(38, 2),
    disponibilidad BOOLEAN DEFAULT TRUE,
    imagen_url VARCHAR (255),
    cantidad_disponible INTEGER
);



CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,  -- Relación con usuarios
    id_espacio INT NULL,  -- Relación con espacios
    id_equipo INT NULL,   -- Relación con equipos
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    tipo_reserva ENUM('MENSUAL', 'HORAS', 'DIAS'),
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'COMPLETADA') DEFAULT 'PENDIENTE',
    codigo_temporal VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_espacio) REFERENCES espacios(id_espacio),
    FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);


CREATE TABLE historial_accesos (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,  -- Relación con usuarios
    id_espacio INT,  -- Relación con espacios
    id_equipo INT,   -- Relación con equipos
    fecha_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hora_inicio DATETIME,
    hora_fin DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_espacio) REFERENCES espacios(id_espacio),
    FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);


CREATE TABLE pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT,  -- Relación con reservas
    monto DECIMAL(38, 2),
    estado_pago ENUM('PENDIENTE', 'PAGADO', 'RECHAZADO') DEFAULT 'PENDIENTE',
    metodo_pago ENUM('TARJETA', 'TRANSFERENCIA', 'EFECTIVO', 'OTRO') NOT NULL,
    fecha_pago TIMESTAMP,
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);



CREATE TABLE facturas (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,  -- Relación con usuarios
    id_reserva INT,  -- Relación con reservas
    monto_total DECIMAL(38, 2),
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    estado ENUM('PENDIENTE', 'PAGADA', 'CANCELADA') DEFAULT 'PENDIENTE',
    metodo_pago ENUM('TARJETA', 'TRANSFERENCIA', 'EFECTIVO', 'OTRO') NOT NULL,
    numero_factura VARCHAR(255) UNIQUE,
    concepto VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);



CREATE TABLE notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,  -- Relación con usuarios
    mensaje VARCHAR(255),
    tipo_notificacion ENUM('CONFIRMACION', 'RECORDATORIO', 'ACCESO', 'PROMOCION', 'AVISO'),
    estado ENUM('PENDIENTE', 'ENVIADA') DEFAULT 'PENDIENTE',
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


-- =======================
-- DATOS DE PRUEBA INICIALES
-- =======================

-- Usuarios
INSERT INTO usuarios (nombre, correo, telefono, tipo_usuario, huella_dactilar, contrasena)
VALUES 
('Miguel Alonso', 'miguel@admin.com', '651509256', 'ADMIN', 'hash1', '$2a$10$.dkoBhkdY.a7hj1JT21Ru.Tgt1ZUheCyNaPVDNAgpeIH88xVHvfSK'),
('Jose Antonio Alonso', 'jose@grupoalmo.es', '600333444', 'ADMIN', 'hash2', '$2a$10$.dkoBhkdY.a7hj1JT21Ru.Tgt1ZUheCyNaPVDNAgpeIH88xVHvfSK'),
('Luis García', 'luis23@gmail.com', '600555666', 'CLIENTE', 'hash3', '$2a$10$lNharEnyGgyJbg/l4AsrmunhxqvFZnTT30BKFzOQrRYEIxkOmVuFq');

-- Espacios
INSERT INTO espacios (nombre, descripcion, tipo_espacio, precio_por_hora, precio_por_dia, precio_por_mes, disponibilidad, device_id, imagen_url, capacidad)
VALUES
('Coworking ', 'Espacio compartido para trabajar en red', 'COWORKING', 5.00, 20.00, 300.00, TRUE, 'device001', 'https://res.cloudinary.com/dsk27jtla/image/upload/coworking_mtexu0', 20),
('Despacho Ejecutivo', 'Oficina privada para ejecutivos', 'DESPACHO', 10.00, 40.00, 600.00, TRUE, 'device002', 'https://res.cloudinary.com/dsk27jtla/image/upload/despacho_uawa7h.jpg', 4),
('Sala Reuniones', 'Espacio para reuniones con proyector', 'SALA_REUNIONES', 8.00, 35.00, 500.00, TRUE, 'bf38467f5767acb843rj6z', 'https://res.cloudinary.com/dsk27jtla/image/upload/reuniones_uiib6j', 1),
('Plató TV Studio', 'Plató para grabaciones profesionales', 'PLATO_TELEVISION', 25.00, 150.00, 2000.00, TRUE, 'device004', 'https://res.cloudinary.com/dsk27jtla/image/upload/plato_lqbyvq', 1);

-- Equipos
INSERT INTO equipos (nombre, descripcion, tipo_equipo, precio_por_dia, disponibilidad, imagen_url, cantidad_disponible)
VALUES
('Micrófono Rode', 'Micrófono profesional de condensador', 'MICROFONO', 10.00, TRUE, 'https://res.cloudinary.com/tu_cloud/image/upload/v1/mic.jpg', 5),
('Cámara Slow Motion', 'Cámara de alta velocidad para grabaciones especiales', 'CAMARA', 30.00, TRUE, 'https://res.cloudinary.com/tu_cloud/image/upload/v1/camara.jpg', 2),
('Proyector Epson', 'Proyector HD para presentaciones', 'PROYECTOR', 15.00, TRUE, 'https://res.cloudinary.com/tu_cloud/image/upload/v1/proyector.jpg', 3);

-- Reservas
INSERT INTO reservas (id_usuario, id_espacio, id_equipo, fecha_inicio, fecha_fin, tipo_reserva, estado)
VALUES
(3, 1, 1, '2025-06-01 09:00:00', '2025-06-01 17:00:00', 'DIAS', 'CONFIRMADA'),
(3, 2, 2, '2025-06-05 10:00:00', '2025-06-05 12:00:00', 'HORAS', 'PENDIENTE'),
(3, 4, NULL, '2025-06-14 08:00:00', '2025-06-20 18:00:00', 'DIAS', 'CONFIRMADA');

-- Historial accesos
INSERT INTO historial_accesos (id_usuario, id_espacio, id_equipo, fecha_acceso, hora_inicio, hora_fin)
VALUES
(3, 1, 1, '2025-06-01 08:50:00', '2025-06-01 09:00:00', '2025-06-01 17:00:00'),
(3, 2, 2, '2025-06-05 09:45:00', '2025-06-05 10:00:00', '2025-06-05 12:00:00');

-- Pagos
INSERT INTO pagos (id_reserva, monto, estado_pago, metodo_pago, fecha_pago)
VALUES
(1, 20.00, 'PAGADO', 'TARJETA', NOW()),
(2, 15.00, 'PENDIENTE', 'TRANSFERENCIA', NULL);

-- Facturas
INSERT INTO facturas (id_usuario, id_reserva, monto_total, fecha_emision, fecha_vencimiento, estado, metodo_pago, numero_factura, concepto)
VALUES
(3, 1, 20.00, NOW(), '2025-06-08', 'PAGADA', 'TARJETA', 'FAC-001', 'Reserva Coworking Creativo 1 día'),
(3, 2, 15.00, NOW(), '2025-06-10', 'PENDIENTE', 'TRANSFERENCIA', 'FAC-002', 'Reserva Despacho Ejecutivo 2 horas');

-- Notificaciones
INSERT INTO notificaciones (id_usuario, mensaje, tipo_notificacion, estado)
VALUES
(3, 'Tu reserva ha sido confirmada para el Coworking Creativo.', 'CONFIRMACION', 'ENVIADA'),
(3, 'Recuerda que tu reserva del despacho es mañana a las 10:00.', 'RECORDATORIO', 'PENDIENTE'),
(3, 'Acceso autorizado al Plató TV Studio.', 'ACCESO', 'ENVIADA');