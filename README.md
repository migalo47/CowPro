# 🏢 CowPro - Sistema de Reservas Profesionales

**CowPro** es una aplicación multiplataforma desarrollada como parte de un TFG y un encargo real para una empresa. Permite la gestión completa de **reservas de espacios, equipos y control de accesos**, tanto para clientes como para administradores.

## 🚀 Tecnologías utilizadas

- **Frontend**: Flutter (multiplataforma Android/iOS/web)
- **Backend**: Spring Boot + JWT + MySQL
- **API adicional**: FastAPI (control de cerraduras inteligentes con Tuya)
- **Base de datos**: MySQL 8
- **Contenedores**: Docker + Docker Compose

## 🔐 Funcionalidades clave

### 👤 Cliente
- Registro e inicio de sesión con JWT
- Visualización y reserva de espacios/equipos disponibles
- Recibir notificaciones y facturas en PDF
- Generación de códigos de acceso temporales
- Modo oscuro y edición de perfil

### 👨‍💼 Administrador
- Panel completo de gestión (usuarios, reservas, espacios, equipos)
- Gestión de pagos, facturación y notificaciones
- Visualización de historial de accesos
- Interfaz visual profesional y filtros avanzados

## 🧱 Estructura del proyecto

```
CowProProject/
├── sharechannel_backend/     # Backend Spring Boot
│   ├── Dockerfile
│   └── ...
├── tuya-lock-api/            # API FastAPI para cerraduras Tuya
│   ├── Dockerfile
│   └── ...
├── flutter_frontend/         # App Flutter multiplataforma
│   └── ...
├── docker-compose.yml        # Orquestación de servicios
└── script_definitivo.sql     # Script para crear e inicializar la BD
```

## 🐳 Dockerización

El proyecto está completamente dockerizado. Basta con ejecutar:

```bash
sudo docker compose up --build -d
```

Esto levantará:
- MySQL (`cowpro`)
- Backend en Spring Boot (puerto `8080`)
- API FastAPI (puerto `8000`)

## 📱 Frontend

El frontend se ejecuta desde Android Studio (Flutter). Se conecta automáticamente a los servicios en Docker y permite probar la app completa con emulador.

## 📧 Contacto

Este proyecto fue desarrollado por **Miguel Alonso** para la empresa **CowPro** como parte del Grado Superior de DAM.

📩 Contacto de la empresa: [info@cowpro.es](mailto:info@cowpro.es)
