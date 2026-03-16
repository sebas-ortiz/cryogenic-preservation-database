IF OBJECT_ID('dbo.Tbl_Roles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Roles (
        id_rol INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_rol VARCHAR(50) NOT NULL,
        descripcion_rol VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_TipoAuditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_TipoAuditoria (
        id_tipoAud INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_tipoAud VARCHAR(50) NOT NULL,
        descripcion_tipoAud VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_TipoIncidente', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_TipoIncidente (
        id_tipoInc INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_tipoInc VARCHAR(50) NOT NULL,
        descripcion_tipoInc VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_Persona', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Persona (
        cedula INT NOT NULL PRIMARY KEY,
        nombre VARCHAR(150) NOT NULL,
        apellido1 VARCHAR(150) NOT NULL,
        apellido2 VARCHAR(150) NOT NULL,
        id_rol INT NOT NULL,
        certificacion_empleado VARCHAR(MAX) NULL,
        estado_empleado VARCHAR(20) NULL,
        fecha_nacimiento_cliente DATE NULL,
        contacto_emergencia_cliente VARCHAR(150) NULL,
        estado_contrato_cliente VARCHAR(20) NULL,
        fecha_ingreso_cliente DATE NULL,
        tipo_preservacion_cliente VARCHAR(50) NULL,
        CONSTRAINT FK_Tbl_Persona_Tbl_Roles
            FOREIGN KEY (id_rol) REFERENCES dbo.Tbl_Roles(id_rol)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_ConsentimientoLegal', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_ConsentimientoLegal (
        id_consentimiento INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_persona INT NOT NULL,
        tipo_documento VARCHAR(100) NULL,
        fecha_firma DATE NULL,
        estado_validacion VARCHAR(20) NULL,
        observaciones VARCHAR(MAX) NULL,
        CONSTRAINT FK_Tbl_ConsentimientoLegal_Tbl_Persona
            FOREIGN KEY (id_persona) REFERENCES dbo.Tbl_Persona(cedula)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_TanquesCriogenicos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_TanquesCriogenicos (
        id_tanque INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ubicacion_fisica VARCHAR(100) NULL,
        capacidad_maxima INT NULL,
        tipo_refrigerante VARCHAR(50) NULL,
        estado_operativo VARCHAR(20) NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_MonitoreoTanques', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_MonitoreoTanques (
        id_monitoreo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_tanque INT NOT NULL,
        fecha_hora DATETIME NULL,
        temperatura DECIMAL(5,2) NULL,
        presion DECIMAL(5,2) NULL,
        nivel_refrigerante DECIMAL(5,2) NULL,
        alertas VARCHAR(MAX) NULL,
        CONSTRAINT FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos
            FOREIGN KEY (id_tanque) REFERENCES dbo.Tbl_TanquesCriogenicos(id_tanque)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_ProtocoloProcedimiento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_ProtocoloProcedimiento (
        id_protocolo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_protocolo VARCHAR(100) NULL,
        version VARCHAR(20) NULL,
        fecha_implementacion DATE NULL,
        estado VARCHAR(20) NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_Auditorias', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Auditorias (
        id_auditoria INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_tipoAud INT NOT NULL,
        id_protocolo INT NOT NULL,
        cumplimiento BIT NULL,
        observaciones VARCHAR(MAX) NULL,
        fecha_aud DATE NULL,
        entidad_auditora VARCHAR(100) NULL,
        resultado_aud VARCHAR(MAX) NULL,
        recomendaciones VARCHAR(MAX) NULL,
        id_responsable INT NOT NULL,
        CONSTRAINT FK_Tbl_Auditorias_Tbl_TipoAuditoria
            FOREIGN KEY (id_tipoAud) REFERENCES dbo.Tbl_TipoAuditoria(id_tipoAud),
        CONSTRAINT FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento
            FOREIGN KEY (id_protocolo) REFERENCES dbo.Tbl_ProtocoloProcedimiento(id_protocolo),
        CONSTRAINT FK_Tbl_Auditorias_Tbl_Persona
            FOREIGN KEY (id_responsable) REFERENCES dbo.Tbl_Persona(cedula)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_IncidentesCriticos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_IncidentesCriticos (
        id_evento INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        fecha_hora DATETIME NULL,
        id_tanque INT NOT NULL,
        id_tipoInc INT NOT NULL,
        impacto VARCHAR(MAX) NULL,
        acciones_correctivas VARCHAR(MAX) NULL,
        id_persona INT NOT NULL,
        id_protocolo INT NOT NULL,
        CONSTRAINT FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos
            FOREIGN KEY (id_tanque) REFERENCES dbo.Tbl_TanquesCriogenicos(id_tanque),
        CONSTRAINT FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente
            FOREIGN KEY (id_tipoInc) REFERENCES dbo.Tbl_TipoIncidente(id_tipoInc),
        CONSTRAINT FK_Tbl_IncidentesCriticos_Tbl_Persona
            FOREIGN KEY (id_persona) REFERENCES dbo.Tbl_Persona(cedula),
        CONSTRAINT FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento
            FOREIGN KEY (id_protocolo) REFERENCES dbo.Tbl_ProtocoloProcedimiento(id_protocolo)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_Preservaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_Preservaciones (
        id_preservacion INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        id_cliente INT NOT NULL,
        fecha_preservacion DATE NULL,
        tipo_preservacion VARCHAR(50) NULL,
        estado_actual VARCHAR(30) NULL,
        id_tanque INT NOT NULL,
        id_protocolo INT NOT NULL,
        CONSTRAINT FK_Tbl_Preservaciones_Tbl_Persona
            FOREIGN KEY (id_cliente) REFERENCES dbo.Tbl_Persona(cedula),
        CONSTRAINT FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos
            FOREIGN KEY (id_tanque) REFERENCES dbo.Tbl_TanquesCriogenicos(id_tanque),
        CONSTRAINT FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento
            FOREIGN KEY (id_protocolo) REFERENCES dbo.Tbl_ProtocoloProcedimiento(id_protocolo)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_TanquesAuditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_TanquesAuditoria (
        id_tanque INT NOT NULL,
        id_auditoria INT NOT NULL,
        CONSTRAINT PK_Tbl_TanquesAuditoria PRIMARY KEY (id_tanque, id_auditoria),
        CONSTRAINT FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos
            FOREIGN KEY (id_tanque) REFERENCES dbo.Tbl_TanquesCriogenicos(id_tanque),
        CONSTRAINT FK_Tbl_TanquesAuditoria_Tbl_Auditorias
            FOREIGN KEY (id_auditoria) REFERENCES dbo.Tbl_Auditorias(id_auditoria)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_IncidentesPreservaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_IncidentesPreservaciones (
        id_evento INT NOT NULL,
        id_preservacion INT NOT NULL,
        CONSTRAINT PK_Tbl_IncidentesPreservaciones PRIMARY KEY (id_evento, id_preservacion),
        CONSTRAINT FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos
            FOREIGN KEY (id_evento) REFERENCES dbo.Tbl_IncidentesCriticos(id_evento),
        CONSTRAINT FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones
            FOREIGN KEY (id_preservacion) REFERENCES dbo.Tbl_Preservaciones(id_preservacion)
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_MonitoreoPersona', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_MonitoreoPersona (
        id_monitoreo INT NOT NULL,
        cedula INT NOT NULL,
        CONSTRAINT PK_Tbl_MonitoreoPersona PRIMARY KEY (id_monitoreo, cedula),
        CONSTRAINT FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques
            FOREIGN KEY (id_monitoreo) REFERENCES dbo.Tbl_MonitoreoTanques(id_monitoreo),
        CONSTRAINT FK_Tbl_MonitoreoPersona_Tbl_Persona
            FOREIGN KEY (cedula) REFERENCES dbo.Tbl_Persona(cedula)
    );
END;
GO
