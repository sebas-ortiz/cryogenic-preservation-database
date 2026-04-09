-- NOTE:
-- The scripts in this repository assume that the tables "Padron_Completo"
-- and "Distelec" from the TSE Electoral Registry, along with the four
-- phone tables (each imported from a separate CSV file), are already
-- loaded in the database. If these datasets are not preloaded, some
-- scripts may fail during execution.

--Procedimiento para la tabla Telefonos General
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_Telefonos_General]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Configuraciones necesarias para la tabla
        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

        -- Proceso para crear la tabla solo si no existe
        IF NOT EXISTS (
            SELECT 1 
            FROM sys.tables 
            WHERE name = 'Telefonos_General' 
              AND schema_id = SCHEMA_ID('dbo')
        )
        BEGIN
            EXEC sp_executesql N'
                CREATE TABLE [dbo].[Telefonos_General](
	            [Telefono] [varchar](50) NULL,
	            [Cedula] [varchar](50) NULL,
	            [Nombre_Cliente] [varchar](50) NULL
                ) ON [PRIMARY]
            ';
        END

        SET ANSI_PADDING OFF;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END

GO

--Procedimiento para insertar la información de las 4 tablas de teléfonos en Telefonos General
CREATE PROCEDURE dbo.sp_Insertar_Telefonos_General
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[Telefonos_General] ([Telefono], [Cedula], [Nombre_Cliente])
        SELECT [Column 0], [Column 1], [Column 2] FROM [dbo].[phones1]
        UNION ALL
        SELECT [Column 0], [Column 1], [Column 2] FROM [dbo].[phones2]
        UNION ALL
        SELECT [Column 0], [Column 1], [Column 2] FROM [dbo].[phones3]
        UNION ALL
        SELECT [Column 0], [Column 1], [Column 2] FROM [dbo].[phones4];

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END
GO

--Procedimiento para el cursor de Telefonos General V2
CREATE PROCEDURE dbo.sp_Cursor_Telefonos_General_V2
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CedulaActual      VARCHAR(20);
        DECLARE @NombreActual      NVARCHAR(200);
        DECLARE @TelefonoActual    VARCHAR(20);

        DECLARE @CedulaGrupo       VARCHAR(20);
        DECLARE @NombreGrupo       NVARCHAR(200);
        DECLARE @ListaTelefonos    NVARCHAR(MAX);
        DECLARE @CantidadTelefonos INT;

        -- Crear tabla destino si no existe
        IF OBJECT_ID('dbo.Telefonos_General_V2') IS NULL
        BEGIN
            CREATE TABLE dbo.Telefonos_General_V2 (
                Cedula VARCHAR(50),
                Nombre VARCHAR(50),
                Cantidad_Telefonos INT,
                Telefonos NVARCHAR(MAX)
            );
        END

        -- Cursor
        DECLARE cur_Telefonos CURSOR FOR
            SELECT DISTINCT
                   Cedula,
                   Nombre_Cliente,
                   Telefono
            FROM dbo.Telefonos_General
            WHERE Cedula IS NOT NULL
              AND LTRIM(RTRIM(Cedula)) <> ''
              AND Telefono IS NOT NULL
              AND LTRIM(RTRIM(Telefono)) <> ''
            ORDER BY Cedula, Nombre_Cliente, Telefono;

        OPEN cur_Telefonos;

        -- Inicialización
        SET @CedulaGrupo       = NULL;
        SET @NombreGrupo       = NULL;
        SET @ListaTelefonos    = N'';
        SET @CantidadTelefonos = 0;

        FETCH NEXT FROM cur_Telefonos
        INTO @CedulaActual, @NombreActual, @TelefonoActual;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Cambio de persona -> guardar la anterior
            IF @CedulaGrupo IS NULL OR @CedulaActual <> @CedulaGrupo
            BEGIN
                IF @CedulaGrupo IS NOT NULL
                BEGIN
                    INSERT INTO dbo.Telefonos_General_V2
                        (Cedula, Nombre, Cantidad_Telefonos, Telefonos)
                    VALUES
                        (@CedulaGrupo, @NombreGrupo, @CantidadTelefonos, @ListaTelefonos);
                END;

                -- Nuevo grupo
                SET @CedulaGrupo       = @CedulaActual;
                SET @NombreGrupo       = @NombreActual;
                SET @ListaTelefonos    = @TelefonoActual;
                SET @CantidadTelefonos = 1;
            END
            ELSE
            BEGIN
                -- Misma persona -> agregar teléfono
                SET @ListaTelefonos = @ListaTelefonos + ', ' + @TelefonoActual;
                SET @CantidadTelefonos = @CantidadTelefonos + 1;
            END;

            FETCH NEXT FROM cur_Telefonos
            INTO @CedulaActual, @NombreActual, @TelefonoActual;
        END;

        -- Insertar último grupo pendiente
        IF @CedulaGrupo IS NOT NULL
        BEGIN
            INSERT INTO dbo.Telefonos_General_V2
                (Cedula, Nombre, Cantidad_Telefonos, Telefonos)
            VALUES
                (@CedulaGrupo, @NombreGrupo, @CantidadTelefonos, @ListaTelefonos);
        END;

        CLOSE cur_Telefonos;
        DEALLOCATE cur_Telefonos;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END
GO

--Procedimiento para la tabla PersonaTSE
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_PersonaTSE]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Configuraciones necesarias para la tabla
        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

        -- Proceso para crear la tabla solo si no existe
        IF NOT EXISTS (
            SELECT 1 
            FROM sys.tables 
            WHERE name = 'Tbl_PersonaTSE' 
              AND schema_id = SCHEMA_ID('dbo')
        )
        BEGIN
            EXEC sp_executesql N'
                CREATE TABLE [dbo].[Tbl_PersonaTSE](
					[cedula] [int] NOT NULL,
					[nombre] [varchar](50) NULL,
					[apellido1] [varchar](50) NULL,
					[apellido2] [varchar](50) NULL,
					[vencimiento_cedula] [varchar](50) NULL,
				CONSTRAINT [PK_Tbl_PersonaTSE] PRIMARY KEY CLUSTERED 
				(
					[cedula] ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
				) ON [PRIMARY]
            ';
        END

        SET ANSI_PADDING OFF;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END

GO

--Procedimiento para la tabla DistritoElectoral
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_DistritoElectoral]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Configuraciones necesarias para la tabla
        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

        -- Proceso para crear la tabla solo si no existe
        IF NOT EXISTS (
            SELECT 1 
            FROM sys.tables 
            WHERE name = 'Tbl_DistritoElectoral' 
              AND schema_id = SCHEMA_ID('dbo')
        )
        BEGIN
            EXEC sp_executesql N'
                CREATE TABLE [dbo].[Tbl_DistritoElectoral](
					[codigo_electoral] [int] NOT NULL,
					[provincia] [varchar](50) NULL,
					[canton] [varchar](50) NULL,
					[distrito] [varchar](50) NULL,
				 CONSTRAINT [PK_Tbl_DistritoElectoral] PRIMARY KEY CLUSTERED 
				(
					[codigo_electoral] ASC
				)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
				) ON [PRIMARY]
            ';
        END

        SET ANSI_PADDING OFF;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END

GO

--Procedimiento para la tabla LugarVotacion
CREATE PROCEDURE dbo.sp_Crear_Tabla_LugarVotacion
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Se crea la tabla principal si no existe
        IF OBJECT_ID('dbo.Tbl_LugarVotacion') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_LugarVotacion] (
                [junta_votos] INT IDENTITY(1,1) NOT NULL,
                [cedula] INT NULL,
                [codigo_electoral] INT NULL,
                CONSTRAINT [PK_Tbl_LugarVotación]
                    PRIMARY KEY CLUSTERED ([junta_votos] ASC)
                    WITH (
                        PAD_INDEX = OFF,
                        STATISTICS_NORECOMPUTE = OFF,
                        IGNORE_DUP_KEY = OFF,
                        ALLOW_ROW_LOCKS = ON,
                        ALLOW_PAGE_LOCKS = ON
                    ) ON [PRIMARY]
            ) ON [PRIMARY];
        END

        -- Llave foránea a Tbl_DistritoElectoral
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_LugarVotacion_Tbl_DistritoElectoral'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_LugarVotacion] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_LugarVotacion_Tbl_DistritoElectoral]
            FOREIGN KEY ([codigo_electoral])
            REFERENCES [dbo].[Tbl_DistritoElectoral] ([codigo_electoral]);

            ALTER TABLE [dbo].[Tbl_LugarVotacion]
            CHECK CONSTRAINT [FK_Tbl_LugarVotacion_Tbl_DistritoElectoral];
        END

        -- Llave foránea a Tbl_PersonaTSE
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_LugarVotacion_Tbl_PersonaTSE'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_LugarVotacion] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_LugarVotacion_Tbl_PersonaTSE]
            FOREIGN KEY ([cedula])
            REFERENCES [dbo].[Tbl_PersonaTSE] ([cedula]);

            ALTER TABLE [dbo].[Tbl_LugarVotacion]
            CHECK CONSTRAINT [FK_Tbl_LugarVotacion_Tbl_PersonaTSE];
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END
GO

--Procedimiento para insertar la información del TSE sin normalizar a todas las tablas normalizadas del TSE
CREATE PROCEDURE [dbo].[sp_Insertar_TSE_Normalizado]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[Tbl_PersonaTSE] ([cedula], [nombre], [apellido1], [apellido2], [vencimiento_cedula])
		SELECT [cedula], [nombre], [apellido1], [apellido2], [vencimiento_cedula] FROM [dbo].[PADRON_COMPLETO];

		INSERT INTO [dbo].[Tbl_DistritoElectoral] ([codigo_electoral], [provincia], [canton], [distrito])
		SELECT [codigo_electoral], [provincia], [canton], [distrito] FROM [dbo].[distelec];

		INSERT INTO [dbo].[Tbl_LugarVotacion] ([cedula], [codigo_electoral])
		SELECT P.[cedula], D.codigo_electoral 
		FROM [dbo].[PADRON_COMPLETO] P
		JOIN [dbo].[distelec] D ON D.[codigo_electoral] = P.codigo_electoral;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END


GO

--Procedimiento para las tablas del Proyecto Final
CREATE PROCEDURE [dbo].[sp_Crear_Tablas_ProyectoFinal]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Se crean las tablas si no existen
        IF OBJECT_ID('dbo.Tbl_Roles') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Roles](
	[id_rol] [int] IDENTITY(1,1) NOT NULL,
	[nombre_rol] [varchar](50) NOT NULL,
	[descripcion_rol] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Tbl_Roles] PRIMARY KEY CLUSTERED 
(
	[id_rol] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        IF OBJECT_ID('dbo.Tbl_TipoAuditoria') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TipoAuditoria](
	[id_tipoAud] [int] IDENTITY(1,1) NOT NULL,
	[nombre_tipoAud] [varchar](50) NOT NULL,
	[descripcion_tipoAud] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Tbl_TipoAuditoria] PRIMARY KEY CLUSTERED 
(
	[id_tipoAud] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        IF OBJECT_ID('dbo.Tbl_TipoIncidente') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TipoIncidente](
	[id_tipoInc] [int] IDENTITY(1,1) NOT NULL,
	[nombre_tipoInc] [varchar](50) NOT NULL,
	[descripcion_tipoInc] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Tbl_TipoIncidente] PRIMARY KEY CLUSTERED 
(
	[id_tipoInc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        IF OBJECT_ID('dbo.Tbl_Persona') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Persona](
	[cedula] [int] NOT NULL,
	[nombre] [varchar](150) NOT NULL,
	[apellido1] [varchar](150) NOT NULL,
	[apellido2] [varchar](150) NOT NULL,
	[id_rol] [int] NOT NULL,
	[certificacion_empleado] [text] NULL,
	[estado_empleado] [varchar](20) NULL,
	[fecha_nacimiento_cliente] [date] NULL,
	[contacto_emergencia_cliente] [varchar](150) NULL,
	[estado_contrato_cliente] [varchar](20) NULL,
	[fecha_ingreso_cliente] [date] NULL,
	[tipo_preservacion_cliente] [varchar](50) NULL,
 CONSTRAINT [PK_Tbl_Persona] PRIMARY KEY CLUSTERED 
(
	[cedula] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Roles
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Persona_Tbl_Roles'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Persona]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Persona_Tbl_Roles] FOREIGN KEY([id_rol])
REFERENCES [dbo].[Tbl_Roles] ([id_rol]);

            ALTER TABLE [dbo].[Tbl_Persona] CHECK CONSTRAINT [FK_Tbl_Persona_Tbl_Roles];
        END
        
        IF OBJECT_ID('dbo.Tbl_ConsentimientoLegal') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_ConsentimientoLegal](
	[id_consentimiento] [int] IDENTITY(1,1) NOT NULL,
	[id_persona] [int] NOT NULL,
	[tipo_documento] [varchar](100) NULL,
	[fecha_firma] [date] NULL,
	[estado_validacion] [varchar](20) NULL,
	[observaciones] [text] NULL,
 CONSTRAINT [PK_Tbl_ConsentimientoLegal] PRIMARY KEY CLUSTERED 
(
	[id_consentimiento] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Persona
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_ConsentimientoLegal_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_ConsentimientoLegal]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_ConsentimientoLegal_Tbl_Persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_ConsentimientoLegal] CHECK CONSTRAINT [FK_Tbl_ConsentimientoLegal_Tbl_Persona];
        END
        
        IF OBJECT_ID('dbo.Tbl_TanquesCriogenicos') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TanquesCriogenicos](
	[id_tanque] [int] IDENTITY(1,1) NOT NULL,
	[ubicacion_fisica] [varchar](100) NULL,
	[capacidad_maxima] [int] NULL,
	[tipo_refrigerante] [varchar](50) NULL,
	[estado_operativo] [varchar](20) NULL,
 CONSTRAINT [PK_Tbl_TanquesCriogenicos] PRIMARY KEY CLUSTERED 
(
	[id_tanque] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        IF OBJECT_ID('dbo.Tbl_MonitoreoTanques') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_MonitoreoTanques](
	[id_monitoreo] [int] IDENTITY(1,1) NOT NULL,
	[id_tanque] [int] NOT NULL,
	[fecha_hora] [datetime] NULL,
	[temperatura] [decimal](5, 2) NULL,
	[presion] [decimal](5, 2) NULL,
	[nivel_refrigerante] [decimal](5, 2) NULL,
	[alertas] [text] NULL,
 CONSTRAINT [PK_Tbl_MonitoreoTanques] PRIMARY KEY CLUSTERED 
(
	[id_monitoreo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_TanquesCriogenicos
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos'
        )
        BEGIN
           ALTER TABLE [dbo].[Tbl_MonitoreoTanques]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_MonitoreoTanques] CHECK CONSTRAINT [FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos];
        END
        
        IF OBJECT_ID('dbo.Tbl_ProtocoloProcedimiento') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_ProtocoloProcedimiento](
	[id_protocolo] [int] IDENTITY(1,1) NOT NULL,
	[nombre_protocolo] [varchar](100) NULL,
	[version] [varchar](20) NULL,
	[fecha_implementacion] [date] NULL,
	[estado] [varchar](20) NULL,
 CONSTRAINT [PK_Tbl_ProtocoloProcedimiento] PRIMARY KEY CLUSTERED 
(
	[id_protocolo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        IF OBJECT_ID('dbo.Tbl_Auditorias') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Auditorias](
	[id_auditoria] [int] IDENTITY(1,1) NOT NULL,
	[id_tipoAud] [int] NOT NULL,
	[id_protocolo] [int] NOT NULL,
	[cumplimiento] [bit] NULL,
	[observaciones] [text] NULL,
	[fecha_aud] [date] NULL,
	[entidad_auditora] [varchar](100) NULL,
	[resultado_aud] [text] NULL,
	[recomendaciones] [text] NULL,
	[id_responsable] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_Auditorias] PRIMARY KEY CLUSTERED 
(
	[id_auditoria] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Persona
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Auditorias_Tbl_Persona] FOREIGN KEY([id_responsable])
REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_Auditorias] CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_Persona];
        END
        
         -- Llave foránea a Tbl_ProtocoloProcedimiento
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_Auditorias] CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento];
        END
        
         -- Llave foránea a Tbl_TipoAuditoria
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_TipoAuditoria'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Auditorias_Tbl_TipoAuditoria] FOREIGN KEY([id_tipoAud])
REFERENCES [dbo].[Tbl_TipoAuditoria] ([id_tipoAud]);

            ALTER TABLE [dbo].[Tbl_Auditorias] CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_TipoAuditoria];
        END
        
        IF OBJECT_ID('dbo.Tbl_IncidentesCriticos') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_IncidentesCriticos](
	[id_evento] [int] IDENTITY(1,1) NOT NULL,
	[fecha_hora] [datetime] NULL,
	[id_tanque] [int] NOT NULL,
	[id_tipoInc] [int] NOT NULL,
	[impacto] [text] NULL,
	[acciones_correctivas] [text] NULL,
	[id_persona] [int] NOT NULL,
	[id_protocolo] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_IncidentesCriticos] PRIMARY KEY CLUSTERED 
(
	[id_evento] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Persona
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_Persona] FOREIGN KEY([id_persona])
REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_Persona];
        END
        
        -- Llave foránea a Tbl_ProtocoloProcedimiento
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento];
        END
        
        -- Llave foránea a Tbl_TanquesCriogenicos
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos];
        END
        
        -- Llave foránea a Tbl_TipoIncidente
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente] FOREIGN KEY([id_tipoInc])
REFERENCES [dbo].[Tbl_TipoIncidente] ([id_tipoInc]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente];
        END
        
        IF OBJECT_ID('dbo.Tbl_Preservaciones') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Preservaciones](
	[id_preservacion] [int] IDENTITY(1,1) NOT NULL,
	[id_cliente] [int] NOT NULL,
	[fecha_preservacion] [date] NULL,
	[tipo_preservacion] [varchar](50) NULL,
	[estado_actual] [varchar](30) NULL,
	[id_tanque] [int] NOT NULL,
	[id_protocolo] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_Preservaciones] PRIMARY KEY CLUSTERED 
(
	[id_preservacion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Persona
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Preservaciones_Tbl_Persona] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_Preservaciones] CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_Persona];
        END
        
        -- Llave foránea a Tbl_ProtocoloProcedimiento
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_Preservaciones] CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento];
        END
        
        -- Llave foránea a Tbl_TanquesCriogenicos
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_Preservaciones] CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos];
        END
        
        IF OBJECT_ID('dbo.Tbl_TanquesAuditoria') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TanquesAuditoria](
	[id_tanque] [int] NOT NULL,
	[id_auditoria] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_TanquesAuditoria] PRIMARY KEY NONCLUSTERED 
(
	[id_tanque] ASC,
	[id_auditoria] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_Auditorias
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_TanquesAuditoria_Tbl_Auditorias'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_TanquesAuditoria]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_Auditorias] FOREIGN KEY([id_auditoria])
REFERENCES [dbo].[Tbl_Auditorias] ([id_auditoria]);

            ALTER TABLE [dbo].[Tbl_TanquesAuditoria] CHECK CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_Auditorias];
        END
        
        -- Llave foránea a Tbl_TanquesCriogenicos
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_TanquesAuditoria]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_TanquesAuditoria] CHECK CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos];
        END
        
        IF OBJECT_ID('dbo.Tbl_IncidentesPreservaciones') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_IncidentesPreservaciones](
	[id_evento] [int] NOT NULL,
	[id_preservacion] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_IncidentesPreservaciones] PRIMARY KEY NONCLUSTERED 
(
	[id_evento] ASC,
	[id_preservacion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_IncidentesCriticos
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos] FOREIGN KEY([id_evento])
REFERENCES [dbo].[Tbl_IncidentesCriticos] ([id_evento]);

            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones] CHECK CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos];
        END
        
        -- Llave foránea a Tbl_Preservaciones
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones] FOREIGN KEY([id_preservacion])
REFERENCES [dbo].[Tbl_Preservaciones] ([id_preservacion]);

            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones] CHECK CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones];
        END
        
        IF OBJECT_ID('dbo.Tbl_MonitoreoPersona') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_MonitoreoPersona](
	[id_monitoreo] [int] NOT NULL,
	[cedula] [int] NOT NULL,
 CONSTRAINT [PK_Tbl_MonitoreoPersona] PRIMARY KEY NONCLUSTERED 
(
	[id_monitoreo] ASC,
	[cedula] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
        END
        
        -- Llave foránea a Tbl_MonitoreoTanques
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_MonitoreoPersona]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques] FOREIGN KEY([id_monitoreo])
REFERENCES [dbo].[Tbl_MonitoreoTanques] ([id_monitoreo]);

            ALTER TABLE [dbo].[Tbl_MonitoreoPersona] CHECK CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques];
        END
        
        -- Llave foránea a Tbl_Persona
        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoPersona_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_MonitoreoPersona]  WITH CHECK ADD  CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_Persona] FOREIGN KEY([cedula])
REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_MonitoreoPersona] CHECK CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_Persona];
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END

GO

--Procedimiento almacenado para insertar la información a las tablas de Proyecto Final
CREATE PROCEDURE [dbo].[sp_Insertar_Tablas_Proyecto_Final]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Tbl_Roles (nombre_rol, descripcion_rol) VALUES
('Director general', 'Responsable máximo de la organización'),
('Asistente de dirección', 'Apoya al director general en tareas administrativas'),
('Jefe de mantenimiento', 'Encargado de supervisar el mantenimiento general'),
('Técnicos de mantenimiento', 'Realizan tareas técnicas de mantenimiento'),
('Ingeniero de procesos criogenico', 'Diseña y optimiza procesos criogénicos'),
('Coordinador de operaciones', 'Coordina las actividades operativas diarias'),
('Operadores criogenicos', 'Operan equipos relacionados con procesos criogénicos'),
('Auxiliar administrativo', 'Apoya en tareas administrativas generales'),
('Auditor interno', 'Evalúa procesos internos y cumplimiento de normas'),
('Coordinador de calidad y normas', 'Gestiona la calidad y cumplimiento normativo'),
('Jefe de RRHH', 'Dirige el departamento de recursos humanos'),
('Ejecutivos de cuenta', 'Gestionan relaciones con clientes y cuentas'),
('Encargado de marketing', 'Diseña y ejecuta estrategias de marketing'),
('Tecnico de sistemas', 'Administra y da soporte a sistemas informáticos');

INSERT INTO Tbl_TipoAuditoria (nombre_tipoAud, descripcion_tipoAud) VALUES
('Auditoría interna', 'Evaluación realizada por personal interno para verificar procesos y controles'),
('Auditoría de seguridad Industrial y ocupacional', 'Revisión de condiciones de seguridad en el entorno laboral e industrial'),
('Auditoría de cumplimiento legal y normativo', 'Verificación del cumplimiento de leyes, reglamentos y normativas aplicables'),
('Auditoría de mantenimiento y equipos', 'Inspección del estado, uso y mantenimiento de equipos e instalaciones'),
('Auditoría de seguridad de procesos', 'Evaluación de riesgos y controles en procesos operativos críticos'),
('Auditoría de información y sistemas', 'Revisión de la seguridad, integridad y funcionamiento de sistemas informáticos'),
('Auditoría de buenas prácticas de laboratorio', 'Verificación del cumplimiento de estándares y procedimientos en laboratorios');

INSERT INTO Tbl_TipoIncidente (nombre_tipoInc, descripcion_tipoInc) VALUES
('Incidente de seguridad', 'Situación que compromete la integridad física de personas o instalaciones'),
('Incidente ambiental', 'Evento que genera impacto negativo en el medio ambiente'),
('Incidente de calidad', 'Falla relacionada con el cumplimiento de estándares de calidad'),
('Incidente de mantenimiento', 'Problema derivado de fallas o negligencia en el mantenimiento de equipos'),
('Incidente informático', 'Interrupción o vulnerabilidad en sistemas o equipos tecnológicos'),
('Incidente químico', 'Derrame, fuga o mal manejo de sustancias químicas'),
('Incidente eléctrico', 'Falla o riesgo relacionado con instalaciones o equipos eléctricos'),
('Incidente de comunicación', 'Problemas derivados de fallas en la transmisión de información'),
('Incidente de salud ocupacional', 'Situación que afecta la salud física o mental de los trabajadores'),
('Incidente de procesos', 'Desviación o falla en la ejecución de procesos operativos');

INSERT INTO Tbl_Persona (
    nombre, apellido1, apellido2, id_rol,
    certificacion_empleado, estado_empleado, cedula,
    fecha_nacimiento_cliente, contacto_emergencia_cliente,
    estado_contrato_cliente, fecha_ingreso_cliente, tipo_preservacion_cliente
) values
('Carlos', 'Ramírez', 'González', 9, 'Certificación ISO 9001', 'Activo', 102345678,
 '1985-06-15', 'Ana Ramírez', 'Vigente', '2020-01-10', 'Criopreservación biomédica'),
('Lucila', 'Porras', 'Agüero', 4, 'Certificación ISO 13485', 'Activo', 101053316,
 '1990-02-07', 'Carlos Porras', 'Vigente', '2021-05-10', 'Criopreservación biomédica'),
('Dinora', 'Obando', 'García', 12, 'Certificación Seguridad Industrial', 'Activo', 101086526,
 '1989-03-15', 'Mario Obando', 'Vigente', '2021-06-02', 'Criopreservación biomédica'),
('Trinidad', 'Vindas', 'Pérez', 8, 'Certificación en Auditoría Interna', 'Activo', 101141655,
 '1988-07-21', 'Sofía Vindas', 'Vigente', '2020-11-03', 'Criopreservación biomédica'),
('Ana María', 'Pérez', 'Pérez', 1, 'Certificación Bioética', 'Activo', 101240037,
 '1992-02-04', 'Daniel Pérez', 'Vigente', '2019-09-22', 'Criopreservación biomédica'),
('Germán', 'Carvajal', 'Bermúdez', 6, 'Certificación en Criogenia', 'Activo', 101280947,
 '1986-10-19', 'Andrea Bermúdez', 'Vigente', '2020-02-15', 'Criopreservación biomédica'),
('José Vicente', 'Acuña', 'Acuña', 14, 'Certificación ISO 14001', 'Activo', 101290149,
 '1991-02-04', 'Laura Acuña', 'Vigente', '2020-03-01', 'Criopreservación biomédica'),
('Benitivo', 'Arias', 'Campos', 3, 'Certificación en Gestión de Calidad', 'Activo', 101290354,
 '1985-03-31', 'Rosa Arias', 'Vigente', '2021-01-12', 'Criopreservación biomédica'),
('Ramón', 'Ríos', 'Montes', 10, 'Certificación Laboratorio Biomédico', 'Activo', 101330673,
 '1994-04-06', 'Camila Ríos', 'Vigente', '2021-04-20', 'Criopreservación biomédica'),
('José', 'Cisneros', 'Chacón', 7, 'Certificación en Control Ambiental', 'Activo', 101330473,
 '1987-02-20', 'Elena Cisneros', 'Vigente', '2019-12-15', 'Criopreservación biomédica'),
('Nelly', 'Coto', 'Solano', 2, 'Certificación Bioética', 'Activo', 101330470,
 '1984-10-24', 'María Solano', 'Vigente', '2020-07-10', 'Criopreservación biomédica'),
('Antonio Mario', 'Rodríguez', 'Araya', 5, 'Certificación Laboratorio Clínico', 'Activo', 101330899,
 '1993-02-04', 'Julio Rodríguez', 'Vigente', '2021-02-18', 'Criopreservación biomédica'),
('Adán', 'Céspedes', 'Arias', 13, 'Certificación Mantenimiento Preventivo', 'Activo', 101350119,
 '1988-02-06', 'Patricia Céspedes', 'Vigente', '2020-08-12', 'Criopreservación biomédica'),
('Julieta', 'Castro', 'Alvarado', 11, 'Certificación Sistemas de Refrigeración', 'Activo', 101350825,
 '1997-08-17', 'Sergio Castro', 'Vigente', '2021-03-09', 'Criopreservación biomédica'),
('Gabriela', 'Quesada', 'Talavera', 9, 'Certificación en Criogenia Avanzada', 'Activo', 101350654,
 '1995-02-04', 'Carolina Quesada', 'Vigente', '2020-10-11', 'Criopreservación biomédica'),
('Julieta', 'Zeledón', 'Matamoros', 8, 'Certificación Biomédica', 'Activo', 101370377,
 '1999-09-10', 'Raúl Zeledón', 'Vigente', '2022-01-04', 'Criopreservación biomédica'),
('Emelina', 'Hidalgo', 'Flores', 14, 'Certificación Biomédica', 'Activo', 101370531,
 '1998-02-04', 'Luis Hidalgo', 'Vigente', '2021-06-14', 'Criopreservación biomédica'),
('Guadalupe', 'Alpízar', 'Brenes', 1, 'Certificación en Refrigeración', 'Activo', 101370879,
 '1987-02-04', 'Marta Alpízar', 'Vigente', '2019-11-09', 'Criopreservación biomédica'),
('Luz', 'Jiménez', 'Moreno', 3, 'Certificación ISO 9001', 'Activo', 101380562,
 '1986-07-10', 'César Jiménez', 'Vigente', '2020-03-05', 'Criopreservación biomédica'),
('María Josefa', 'Rodríguez', 'Madrigal', 5, 'Certificación Supervisión General', 'Activo', 101390652,
 '1983-02-06', 'Pablo Rodríguez', 'Vigente', '2018-12-17', 'Criopreservación biomédica'),
('Cidely María', 'Rodríguez', 'Madrigal', 7, 'Certificación Supervisión General', 'Activo', 101390996,
 '1990-02-02', 'Daniela Rodríguez', 'Vigente', '2019-08-22', 'Criopreservación biomédica'),
('Sofía', 'Solano', 'Vargas', 11, 'Certificación ISO 9001', 'Activo', 104567893,
 '1992-04-09', 'Mario Solano', 'Vigente', '2020-10-11', 'Criopreservación biomédica'),
('Daniel', 'Jiménez', 'Rojas', 10, 'Certificación en Seguridad', 'Activo', 103894521,
 '1989-09-05', 'Patricia Jiménez', 'Vigente', '2021-02-12', 'Criopreservación biomédica'),
('Fabiola', 'Gómez', 'Sáenz', 13, 'Certificación ISO 13485', 'Activo', 101231457,
 '1993-12-19', 'Juan Gómez', 'Vigente', '2019-06-20', 'Criopreservación biomédica'),
('Ricardo', 'Mora', 'Cordero', 6, 'Certificación Auditoría Interna', 'Activo', 102984512,
 '1987-05-30', 'Lucía Mora', 'Vigente', '2020-08-22', 'Criopreservación biomédica'),
('Andrea', 'Chacón', 'Vega', 2, 'Certificación Bioética', 'Activo', 104125986,
 '1995-08-13', 'Pablo Chacón', 'Vigente', '2022-03-04', 'Criopreservación biomédica'),
('Luis', 'Pérez', 'Solís', 4, 'Certificación Mantenimiento Avanzado', 'Activo', 104789652,
 '1986-03-21', 'Esteban Pérez', 'Vigente', '2019-05-16', 'Criopreservación biomédica'),
('Rosa', 'Valverde', 'Soto', 8, 'Certificación Sistemas de Control', 'Activo', 104896312,
 '1997-10-10', 'Laura Valverde', 'Vigente', '2020-09-20', 'Criopreservación biomédica');
 
INSERT INTO Tbl_ProtocoloProcedimiento (
    nombre_protocolo, version, fecha_implementacion, estado
) VALUES
('Protocolo de seguridad criogénica', 'v1.0', '2022-03-15', 'Inactivo'),
('Protocolo de mantenimiento preventivo', 'v2.2', '2024-03-10', 'Activo'),
('Protocolo de auditoría interna', 'v3.0', '2024-01-08', 'Activo'),
('Protocolo de preservación biológica', 'v1.2', '2023-01-20', 'Inactivo'),
('Protocolo de gestión de calidad', 'v4.0', '2019-09-30', 'Inactivo'),
('Protocolo de manejo de sustancias químicas', 'v2.3', '2022-06-01', 'Inactivo'),
('Protocolo de respuesta ante emergencias', 'v1.5', '2020-02-28', 'Inactivo'),
('Protocolo de seguridad criogénica', 'v2.0', '2023-06-25', 'Activo'),
('Protocolo de mantenimiento preventivo', 'v2.1', '2021-07-10', 'Inactivo'),
('Protocolo de auditoría interna', 'v3.0', '2020-11-05', 'Inactivo'),
('Protocolo de preservación biológica', 'v1.3', '2023-03-19', 'Activo'),
('Protocolo de gestión de calidad', 'v4.5', '2021-05-07', 'Activo'),
('Protocolo de manejo de sustancias químicas', 'v2.6', '2023-03-08', 'Activo'),
('Protocolo de respuesta ante emergencias', 'v1.6', '2021-04-23', 'Activo');


INSERT INTO Tbl_TanquesCriogenicos (ubicacion_fisica, capacidad_maxima, tipo_refrigerante, estado_operativo) VALUES
('Planta Central - Zona A', 5000, 'Nitrógeno líquido', 'Operativo'),
('Laboratorio Criogénico - Sala 3', 2500, 'Helio líquido', 'Operativo'),
('Área de almacenamiento - Sector B', 4000, 'Argón líquido', 'Mantenimiento'),
('Unidad móvil - Vehículo 12', 1500, 'Nitrógeno líquido', 'Operativo'),
('Planta Norte - Subnivel 2', 3000, 'Oxígeno líquido', 'Inactivo'),
('Centro de investigación - Módulo 5', 2000, 'Nitrógeno líquido', 'Operativo'),
('Zona de respaldo - Tanque externo', 3500, 'Helio líquido', 'Operativo'),
('Laboratorio de pruebas - Sala 1', 1800, 'Argón líquido', 'Operativo'),
('Planta Sur - Área técnica', 4200, 'Nitrógeno líquido', 'Mantenimiento'),
('Estación remota - Contenedor 7', 2700, 'Oxígeno líquido', 'Operativo'),
('Depósito criogénico - Nivel 1', 3200, 'Helio líquido', 'Operativo'),
('Zona de carga - Plataforma 4', 1600, 'Nitrógeno líquido', 'Inactivo'),
('Tanque portátil - Unidad 9', 1400, 'Argón líquido', 'Operativo'),
('Laboratorio biomédico - Sección B', 2300, 'Oxígeno líquido', 'Operativo'),
('Planta experimental - Zona C', 3800, 'Helio líquido', 'Mantenimiento'),
('Centro logístico - Patio 2', 2900, 'Nitrógeno líquido', 'Operativo'),
('Estación de respaldo - Tanque 3', 3100, 'Argón líquido', 'Operativo'),
('Área técnica - Subnivel 4', 2600, 'Oxígeno líquido', 'Operativo'),
('Laboratorio de criopreservación - Sala 6', 2400, 'Helio líquido', 'Operativo'),
('Tanque externo - Plataforma 8', 3300, 'Nitrógeno líquido', 'Operativo');


-- ============================================================
-- CORRECCIÓN: id_persona en Tbl_ConsentimientoLegal debe ser
-- la cédula real, no un número ordinal de posición.
-- Original usaba: 1,3,5,7,9,12,15,18,21,24
-- Correcto con cédulas reales:
--   pos1=102345678, pos3=101086526, pos5=101240037,
--   pos7=101290149, pos9=101330673, pos12=101330899,
--   pos15=101350654, pos18=101370879, pos21=101390996,
--   pos24=101231457
-- ============================================================
INSERT INTO Tbl_ConsentimientoLegal (
    id_persona, tipo_documento, fecha_firma, estado_validacion, observaciones
) VALUES
(102345678, 'Consentimiento informado de criopreservación', '2020-01-10', 'Validado', 'Firmado presencialmente por Carlos Ramírez.'),
(101086526, 'Autorización de tratamiento de datos personales', '2021-06-02', 'Validado', 'Documento escaneado y archivado.'),
(101240037, 'Consentimiento para procedimientos médicos', '2019-09-22', 'Pendiente', 'Falta firma del médico responsable.'),
(101290149, 'Acuerdo de confidencialidad', '2020-03-01', 'Validado', 'Firmado durante la inducción laboral.'),
(101330673, 'Consentimiento para análisis genético', '2021-04-20', 'Rechazado', 'Cliente solicitó modificación en cláusula 3.'),
(101330899, 'Autorización de uso de imagen', '2021-02-18', 'Validado', 'Aplicable para material promocional.'),
(101350654, 'Consentimiento para almacenamiento de muestras biológicas', '2020-10-11', 'Validado', 'Documento escaneado y archivado.'),
(101370879, 'Autorización de acceso a historial clínico', '2019-11-09', 'Pendiente', 'En revisión por el departamento legal.'),
(101390996, 'Consentimiento para participación en estudio clínico', '2019-08-22', 'Validado', 'Incluye cláusula de retiro voluntario.'),
(101231457, 'Consentimiento para transferencia internacional de datos', '2020-08-22', 'Validado', 'Firmado electrónicamente por el cliente.');


INSERT INTO Tbl_MonitoreoTanques (
    id_tanque, fecha_hora, temperatura, presion, nivel_refrigerante, alertas
) VALUES
(1, '2025-11-01 08:00:00', -196.00, 1.20, 85.50, NULL),
(2, '2025-11-01 08:05:00', -269.00, 0.95, 78.20, 'Presión baja detectada'),
(3, '2025-11-01 08:10:00', -185.50, 1.10, 90.00, NULL),
(4, '2025-11-01 08:15:00', -196.00, 1.25, 60.00, 'Nivel de refrigerante bajo'),
(5, '2025-11-01 08:20:00', -183.00, 1.30, 88.75, NULL),
(6, '2025-11-01 08:25:00', -195.00, 1.15, 92.00, NULL),
(7, '2025-11-01 08:30:00', -268.00, 0.90, 70.00, 'Presión fuera de rango'),
(8, '2025-11-01 08:35:00', -190.00, 1.05, 95.00, NULL),
(9, '2025-11-01 08:40:00', -196.00, 1.10, 82.50, NULL),
(10, '2025-11-01 08:45:00', -200.00, 1.00, 55.00, 'Nivel crítico de refrigerante'),
(11, '2025-11-01 08:50:00', -196.00, 1.18, 89.00, NULL),
(12, '2025-11-01 08:55:00', -194.00, 1.22, 91.50, NULL),
(13, '2025-11-01 09:00:00', -270.00, 0.85, 65.00, 'Temperatura fuera de rango'),
(14, '2025-11-01 09:05:00', -195.50, 1.10, 87.00, NULL),
(15, '2025-11-01 09:10:00', -196.00, 1.00, 93.00, NULL);

-- ============================================================
-- CORRECCIÓN: id_responsable en Tbl_Auditorias debe ser cédula real.
-- Original usaba posiciones: 5,13,7,8,2,24,14,6,11,19
-- Correcto:
--   pos5=101240037, pos13=101350119, pos7=101290149,
--   pos8=101290354, pos2=101053316,  pos24=101231457,
--   pos14=101350825, pos6=101280947, pos11=101330470,
--   pos19=101380562
-- ============================================================
INSERT INTO Tbl_Auditorias (
    id_tipoAud, id_protocolo, cumplimiento, observaciones,
    fecha_aud, entidad_auditora, resultado_aud, recomendaciones, id_responsable
) VALUES
(1, 1, 1, 'Auditoría interna sin hallazgos críticos.',
 '2025-10-01', 'Unidad de Auditoría Interna', 'Cumplimiento satisfactorio en todos los puntos.', 'Mantener controles actuales y reforzar capacitación anual.', 101240037),

(2, 2, 0, 'Se detectaron deficiencias en seguridad ocupacional.',
 '2025-09-15', 'Consultores Seguridad S.A.', 'Incumplimiento en protocolos de evacuación.', 'Actualizar simulacros y señalización.', 101350119),

(3, 3, 1, 'Cumplimiento legal verificado.',
 '2025-08-20', 'Auditoría Legal Externa', 'Todos los documentos están en regla.', 'Revisar cambios normativos cada trimestre.', 101290149),

(4, 4, 0, 'Equipos con mantenimiento vencido.',
 '2025-07-10', 'Auditores Técnicos Ltda.', 'Fallas en registros de mantenimiento.', 'Implementar sistema de alertas automáticas.', 101290354),

(5, 5, 1, 'Seguridad de procesos adecuada.',
 '2025-06-05', 'Auditoría de Procesos CR', 'Controles operativos cumplen con estándares.', 'Revisar procedimientos cada seis meses.', 101053316),

(6, 6, 0, 'Sistemas informáticos con vulnerabilidades.',
 '2025-05-18', 'Auditoría Digital S.A.', 'Se detectaron accesos no autorizados.', 'Actualizar políticas de acceso y realizar pruebas de penetración.', 101231457),

(7, 7, 1, 'Buenas prácticas de laboratorio observadas.',
 '2025-04-22', 'Auditoría Biomédica Internacional', 'Cumplimiento general con observaciones menores.', 'Reforzar uso de EPP y limpieza de áreas críticas.', 101350825),

(1, 2, 1, 'Auditoría interna enfocada en seguridad.',
 '2025-03-30', 'Unidad de Auditoría Interna', 'Mejoras implementadas desde última revisión.', 'Continuar seguimiento semestral.', 101280947),

(3, 4, 0, 'Incumplimiento parcial en mantenimiento legal.',
 '2025-02-14', 'Auditoría Legal Externa', 'Falta documentación de inspecciones recientes.', 'Digitalizar registros y establecer cronograma de inspecciones.', 101330470),

(5, 6, 1, 'Seguridad de procesos reforzada.',
 '2025-01-10', 'Auditoría de Procesos CR', 'Se implementaron recomendaciones previas.', 'Monitorear indicadores de desempeño mensualmente.', 101380562);


-- ============================================================
-- CORRECCIÓN: id_persona en Tbl_IncidentesCriticos debe ser cédula real.
-- Original usaba posiciones: 8,13,24,2,7,19,14,6,11,5
-- Correcto:
--   pos8=101290354,  pos13=101350119, pos24=101231457,
--   pos2=101053316,  pos7=101290149,  pos19=101380562,
--   pos14=101350825, pos6=101280947,  pos11=101330470,
--   pos5=101240037
-- ============================================================
INSERT INTO Tbl_IncidentesCriticos (
    fecha_hora, id_tanque, id_tipoInc, impacto,
    acciones_correctivas, id_persona, id_protocolo
) VALUES
('2025-10-01 07:45:00', 3, 4, 'Falla en válvula de presión que provocó pérdida de refrigerante.',
 'Reemplazo inmediato de válvula y revisión de sistema de sellado.', 101290354, 2),

('2025-09-15 08:10:00', 7, 2, 'Derrame de helio líquido en sala de almacenamiento.',
 'Evacuación del área, limpieza especializada y revisión de protocolos de seguridad.', 101350119, 5),

('2025-08-20 09:00:00', 12, 6, 'Sistema informático de monitoreo dejó de registrar datos por 2 horas.',
 'Reinicio del sistema, restauración de respaldo y revisión de logs.', 101231457, 6),

('2025-07-10 06:30:00', 5, 1, 'Empleado sufrió quemadura leve por contacto con superficie criogénica.',
 'Atención médica inmediata y reforzamiento de uso de EPP.', 101053316, 1),

('2025-06-05 10:15:00', 9, 3, 'Incumplimiento en protocolo de calidad durante inspección rutinaria.',
 'Capacitación adicional al personal y actualización de checklist de inspección.', 101290149, 3),

('2025-05-18 11:00:00', 14, 5, 'Presión elevada en tanque generó alarma crítica.',
 'Liberación controlada de presión y revisión de sensores.', 101380562, 5),

('2025-04-22 08:50:00', 1, 7, 'Contaminación cruzada en laboratorio por mal manejo de muestras.',
 'Desinfección total del área y reentrenamiento del personal.', 101350825, 7),

('2025-03-30 07:20:00', 6, 8, 'Falla en comunicación entre sensores y sistema central.',
 'Reemplazo de cableado y prueba de conectividad.', 101280947, 2),

('2025-02-14 09:40:00', 11, 9, 'Empleado presentó síntomas respiratorios por exposición prolongada.',
 'Evaluación médica, ajuste de turnos y revisión de ventilación.', 101330470, 4),

('2025-01-10 10:30:00', 15, 10, 'Corte eléctrico afectó operación de sistemas de refrigeración.',
 'Activación de respaldo energético y revisión de UPS.', 101240037, 6);

-- ============================================================
-- CORRECCIÓN: id_cliente en Tbl_Preservaciones debe ser cédula real.
-- Original usaba posiciones 1-15.
-- Correcto:
--   pos1=102345678,  pos2=101053316,  pos3=101086526,
--   pos4=101141655,  pos5=101240037,  pos6=101280947,
--   pos7=101290149,  pos8=101290354,  pos9=101330673,
--   pos10=101330473, pos11=101330470, pos12=101330899,
--   pos13=101350119, pos14=101350825, pos15=101350654
-- ============================================================
INSERT INTO Tbl_Preservaciones (
    id_cliente, fecha_preservacion, tipo_preservacion,
    estado_actual, id_tanque, id_protocolo
) VALUES
(102345678, '2020-01-10', 'Criopreservación biomédica', 'Activo', 1, 1),
(101053316, '2021-05-10', 'Criopreservación biomédica', 'Activo', 2, 2),
(101086526, '2021-06-02', 'Criopreservación biomédica', 'Activo', 3, 3),
(101141655, '2020-11-03', 'Criopreservación biomédica', 'Activo', 4, 4),
(101240037, '2019-09-22', 'Criopreservación biomédica', 'Activo', 5, 5),
(101280947, '2020-02-15', 'Criopreservación biomédica', 'Activo', 6, 6),
(101290149, '2020-03-01', 'Criopreservación biomédica', 'Activo', 7, 7),
(101290354, '2021-01-12', 'Criopreservación biomédica', 'Activo', 8, 1),
(101330673, '2021-04-20', 'Criopreservación biomédica', 'Activo', 9, 2),
(101330473, '2019-12-15', 'Criopreservación biomédica', 'Activo', 10, 3),
(101330470, '2020-07-10', 'Criopreservación biomédica', 'Activo', 11, 4),
(101330899, '2021-02-18', 'Criopreservación biomédica', 'Activo', 12, 5),
(101350119, '2020-08-12', 'Criopreservación biomédica', 'Activo', 13, 6),
(101350825, '2021-03-09', 'Criopreservación biomédica', 'Activo', 14, 7),
(101350654, '2020-10-11', 'Criopreservación biomédica', 'Activo', 15, 1);

INSERT INTO Tbl_TanquesAuditoria (id_tanque, id_auditoria) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4),
(9, 5),
(10, 5),
(11, 6),
(12, 6),
(13, 7),
(14, 8),
(15, 9);

INSERT INTO Tbl_IncidentesPreservaciones (id_evento, id_preservacion) VALUES
(1, 3),
(1, 4),
(2, 7),
(3, 6),
(4, 1),
(5, 5),
(6, 9),
(7, 12),
(8, 2),
(9, 10);

-- ============================================================
-- CORRECCIÓN: cedula en Tbl_MonitoreoPersona debe ser cédula real.
-- Original usaba posiciones: 5,13,7,8,2,24,14,6,11,19,1,3,18,9,21
-- Correcto:
--   pos5=101240037,  pos13=101350119, pos7=101290149,
--   pos8=101290354,  pos2=101053316,  pos24=101231457,
--   pos14=101350825, pos6=101280947,  pos11=101330470,
--   pos19=101380562, pos1=102345678,  pos3=101086526,
--   pos18=101370879, pos9=101330673,  pos21=101390996
-- ============================================================
INSERT INTO Tbl_MonitoreoPersona (id_monitoreo, cedula) VALUES
(1,  101240037),
(2,  101350119),
(3,  101290149),
(4,  101290354),
(5,  101053316),
(6,  101231457),
(7,  101350825),
(8,  101280947),
(9,  101330470),
(10, 101380562),
(11, 102345678),
(12, 101086526),
(13, 101370879),
(14, 101330673),
(15, 101390996);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000);
        DECLARE @Severidad INT;
        DECLARE @Estado INT;

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @Severidad = ERROR_SEVERITY(),
            @Estado = ERROR_STATE();

        RAISERROR (@MensajeError, @Severidad, @Estado);
    END CATCH
END

GO

--Comandos para ejecutar cada proceso almacenado
--(Ejecutarlos en este orden para evitar errores por dependencias de otras tablas o recursos)
EXEC dbo.sp_Crear_Tabla_Telefonos_General;
EXEC dbo.sp_Insertar_Telefonos_General;
EXEC dbo.sp_Cursor_Telefonos_General_V2;
EXEC dbo.sp_Crear_Tabla_PersonaTSE;
EXEC dbo.sp_Crear_Tabla_DistritoElectoral;
EXEC dbo.sp_Crear_Tabla_LugarVotacion;
EXEC dbo.sp_Insertar_TSE_Normalizado;
EXEC dbo.sp_Crear_Tablas_ProyectoFinal;
EXEC dbo.sp_Insertar_Tablas_Proyecto_Final;

--Script de la Vista
CREATE VIEW [dbo].[Visualizar_Consulta]
AS
SELECT DISTINCT
    p.cedula,
    p.nombre,
    p.apellido1,
    p.apellido2,
    d.provincia,
    d.canton,
    d.distrito
FROM dbo.Tbl_PersonaTSE AS p
INNER JOIN dbo.Tbl_LugarVotacion AS lv
    ON lv.cedula = p.cedula
INNER JOIN dbo.Tbl_DistritoElectoral AS d
    ON d.codigo_electoral = lv.codigo_electoral
WHERE 
    UPPER(d.provincia) = 'CARTAGO'
    AND EXISTS (
        SELECT 1
        FROM dbo.Telefonos_General AS t
        WHERE t.Cedula = CAST(p.cedula AS varchar(20))
    );

GO

--Script de los Triggers
--Los TRIGGERS siempre deben ir al final del script, después de crear todas las tablas, todas las relaciones (FOREIGN KEY) y todos los INSERTS opcionales

--Hay que crear una tabla LOG para guardar los datos del trigger
--Tabla LOG:

CREATE TABLE Tbl_LogAcciones (

    usuario VARCHAR(200),

    accion VARCHAR(10),

    fecha DATETIME2

);

GO

--Trigger A – Evitar INSERT

IF OBJECT_ID('trg_NoInsert_TipoAuditoria', 'TR') IS NOT NULL

    DROP TRIGGER trg_NoInsert_TipoAuditoria;

GO

CREATE TRIGGER trg_NoInsert_TipoAuditoria

ON Tbl_TipoAuditoria

INSTEAD OF INSERT

AS

BEGIN

    RAISERROR('No se permiten inserciones en esta tabla.', 16, 1);

END;

GO


--Trigger B – Registrar UPDATE y DELETE

IF OBJECT_ID('trg_LogCambios_Persona', 'TR') IS NOT NULL

    DROP TRIGGER trg_LogCambios_Persona;

GO

CREATE TRIGGER trg_LogCambios_Persona

ON Tbl_Persona

AFTER UPDATE, DELETE

AS

BEGIN

    DECLARE @usuario VARCHAR(128);

    SELECT TOP (1) @usuario = login_name

    FROM sys.dm_exec_sessions

    WHERE session_id = @@SPID;

    INSERT INTO Tbl_LogAcciones (usuario, accion, fecha)

    SELECT

        @usuario,

        CASE

            WHEN EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) THEN 'UPDATE'

            WHEN EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted) THEN 'DELETE'

        END,

        SYSDATETIME();

END;

GO
