-- NOTE:
-- The scripts in this repository assume that the tables "Padron_Completo"
-- and "Distelec" from the TSE Electoral Registry, along with the four
-- phone tables (each imported from a separate CSV file), are already
-- loaded in the database. If these datasets are not preloaded, some
-- scripts may fail during execution.

-- Procedimiento para la tabla Telefonos General
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_Telefonos_General]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'Telefonos_General'
              AND schema_id = SCHEMA_ID('dbo')
        )
        BEGIN
            EXEC sp_executesql N'
                CREATE TABLE [dbo].[Telefonos_General](
                    :contentReference[oaicite:0]{index=0} NULL,
                    :contentReference[oaicite:1]{index=1} NULL,
                    :contentReference[oaicite:2]{index=2} NULL
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

-- Procedimiento para insertar la información de las 4 tablas de teléfonos en Telefonos General
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

-- Procedimiento para el cursor de Telefonos General V2
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

        IF OBJECT_ID('dbo.Telefonos_General_V2') IS NULL
        BEGIN
            CREATE TABLE dbo.Telefonos_General_V2 (
                Cedula VARCHAR(50),
                Nombre VARCHAR(50),
                Cantidad_Telefonos INT,
                Telefonos NVARCHAR(MAX)
            );
        END

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

        SET @CedulaGrupo       = NULL;
        SET @NombreGrupo       = NULL;
        SET @ListaTelefonos    = N'';
        SET @CantidadTelefonos = 0;

        FETCH NEXT FROM cur_Telefonos
        INTO @CedulaActual, @NombreActual, @TelefonoActual;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @CedulaGrupo IS NULL OR @CedulaActual <> @CedulaGrupo
            BEGIN
                IF @CedulaGrupo IS NOT NULL
                BEGIN
                    INSERT INTO dbo.Telefonos_General_V2
                        (Cedula, Nombre, Cantidad_Telefonos, Telefonos)
                    VALUES
                        (@CedulaGrupo, @NombreGrupo, @CantidadTelefonos, @ListaTelefonos);
                END;

                SET @CedulaGrupo       = @CedulaActual;
                SET @NombreGrupo       = @NombreActual;
                SET @ListaTelefonos    = @TelefonoActual;
                SET @CantidadTelefonos = 1;
            END
            ELSE
            BEGIN
                SET @ListaTelefonos = @ListaTelefonos + ', ' + @TelefonoActual;
                SET @CantidadTelefonos = @CantidadTelefonos + 1;
            END;

            FETCH NEXT FROM cur_Telefonos
            INTO @CedulaActual, @NombreActual, @TelefonoActual;
        END;

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

-- Procedimiento para la tabla PersonaTSE
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_PersonaTSE]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

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
                    :contentReference[oaicite:3]{index=3} NULL,
                    :contentReference[oaicite:4]{index=4} NULL,
                    :contentReference[oaicite:5]{index=5} NULL,
                    :contentReference[oaicite:6]{index=6} NULL,
                CONSTRAINT [PK_Tbl_PersonaTSE] PRIMARY KEY CLUSTERED
                (
                    [cedula] ASC
                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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

-- Procedimiento para la tabla DistritoElectoral
CREATE PROCEDURE [dbo].[sp_Crear_Tabla_DistritoElectoral]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;
        SET ANSI_PADDING ON;

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
                    :contentReference[oaicite:7]{index=7} NULL,
                    :contentReference[oaicite:8]{index=8} NULL,
                    :contentReference[oaicite:9]{index=9} NULL,
                 CONSTRAINT [PK_Tbl_DistritoElectoral] PRIMARY KEY CLUSTERED
                (
                    [codigo_electoral] ASC
                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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

-- Procedimiento para la tabla LugarVotacion
CREATE PROCEDURE dbo.sp_Crear_Tabla_LugarVotacion
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('dbo.Tbl_LugarVotacion') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_LugarVotacion] (
                [junta_votos] INT IDENTITY(1,1) NOT NULL,
                [cedula] INT NULL,
                [codigo_electoral] INT NULL,
                CONSTRAINT [PK_Tbl_LugarVotacion]
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

-- Procedimiento para insertar la información del TSE sin normalizar a todas las tablas normalizadas del TSE
CREATE PROCEDURE [dbo].[sp_Insertar_TSE_Normalizado]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[Tbl_PersonaTSE] ([cedula], [nombre], [apellido1], [apellido2], [vencimiento_cedula])
        SELECT [cedula], [nombre], [apellido1], [apellido2], [vencimiento_cedula]
        FROM [dbo].[PADRON_COMPLETO];

        INSERT INTO [dbo].[Tbl_DistritoElectoral] ([codigo_electoral], [provincia], [canton], [distrito])
        SELECT [codigo_electoral], [provincia], [canton], [distrito]
        FROM [dbo].[distelec];

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

-- Procedimiento para las tablas del Proyecto Final
CREATE PROCEDURE [dbo].[sp_Crear_Tablas_ProyectoFinal]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('dbo.Tbl_Roles') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Roles](
                [id_rol] [int] IDENTITY(1,1) NOT NULL,
                :contentReference[oaicite:10]{index=10} NOT NULL,
                 NOT NULL,
             CONSTRAINT [PK_Tbl_Roles] PRIMARY KEY CLUSTERED
            (
                [id_rol] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF OBJECT_ID('dbo.Tbl_TipoAuditoria') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TipoAuditoria](
                [id_tipoAud] [int] IDENTITY(1,1) NOT NULL,
                :contentReference[oaicite:12]{index=12} NOT NULL,
                 NOT NULL,
             CONSTRAINT [PK_Tbl_TipoAuditoria] PRIMARY KEY CLUSTERED
            (
                [id_tipoAud] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF OBJECT_ID('dbo.Tbl_TipoIncidente') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TipoIncidente](
                [id_tipoInc] [int] IDENTITY(1,1) NOT NULL,
                :contentReference[oaicite:14]{index=14} NOT NULL,
                 NOT NULL,
             CONSTRAINT [PK_Tbl_TipoIncidente] PRIMARY KEY CLUSTERED
            (
                [id_tipoInc] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF OBJECT_ID('dbo.Tbl_Persona') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Persona](
                [cedula] [int] NOT NULL,
                 NOT NULL,
                 NOT NULL,
                 NOT NULL,
                [id_rol] [int] NOT NULL,
                [certificacion_empleado] [text] NULL,
                 NULL,
                [fecha_nacimiento_cliente] [date] NULL,
                 NULL,
                 NULL,
                [fecha_ingreso_cliente] [date] NULL,
                :contentReference[oaicite:22]{index=22} NULL,
             CONSTRAINT [PK_Tbl_Persona] PRIMARY KEY CLUSTERED
            (
                [cedula] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Persona_Tbl_Roles'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Persona] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Persona_Tbl_Roles] FOREIGN KEY([id_rol])
            REFERENCES [dbo].[Tbl_Roles] ([id_rol]);

            ALTER TABLE [dbo].[Tbl_Persona]
            CHECK CONSTRAINT [FK_Tbl_Persona_Tbl_Roles];
        END

        IF OBJECT_ID('dbo.Tbl_ConsentimientoLegal') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_ConsentimientoLegal](
                [id_consentimiento] [int] IDENTITY(1,1) NOT NULL,
                [id_persona] [int] NOT NULL,
                 NULL,
                [fecha_firma] [date] NULL,
                 NULL,
                [observaciones] [text] NULL,
             CONSTRAINT [PK_Tbl_ConsentimientoLegal] PRIMARY KEY CLUSTERED
            (
                [id_consentimiento] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_ConsentimientoLegal_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_ConsentimientoLegal] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_ConsentimientoLegal_Tbl_Persona] FOREIGN KEY([id_persona])
            REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_ConsentimientoLegal]
            CHECK CONSTRAINT [FK_Tbl_ConsentimientoLegal_Tbl_Persona];
        END

        IF OBJECT_ID('dbo.Tbl_TanquesCriogenicos') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_TanquesCriogenicos](
                [id_tanque] [int] IDENTITY(1,1) NOT NULL,
                 NULL,
                [capacidad_maxima] [int] NULL,
                :contentReference[oaicite:26]{index=26} NULL,
                 NULL,
             CONSTRAINT [PK_Tbl_TanquesCriogenicos] PRIMARY KEY CLUSTERED
            (
                [id_tanque] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_MonitoreoTanques] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
            REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_MonitoreoTanques]
            CHECK CONSTRAINT [FK_Tbl_MonitoreoTanques_Tbl_TanquesCriogenicos];
        END

        IF OBJECT_ID('dbo.Tbl_ProtocoloProcedimiento') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_ProtocoloProcedimiento](
                [id_protocolo] [int] IDENTITY(1,1) NOT NULL,
                 NULL,
                 NULL,
                [fecha_implementacion] [date] NULL,
                 NULL,
             CONSTRAINT [PK_Tbl_ProtocoloProcedimiento] PRIMARY KEY CLUSTERED
            (
                [id_protocolo] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
                 NULL,
                [resultado_aud] [text] NULL,
                [recomendaciones] [text] NULL,
                [id_responsable] [int] NOT NULL,
             CONSTRAINT [PK_Tbl_Auditorias] PRIMARY KEY CLUSTERED
            (
                [id_auditoria] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Auditorias_Tbl_Persona] FOREIGN KEY([id_responsable])
            REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_Auditorias]
            CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_Persona];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
            REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_Auditorias]
            CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_ProtocoloProcedimiento];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Auditorias_Tbl_TipoAuditoria'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Auditorias] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Auditorias_Tbl_TipoAuditoria] FOREIGN KEY([id_tipoAud])
            REFERENCES [dbo].[Tbl_TipoAuditoria] ([id_tipoAud]);

            ALTER TABLE [dbo].[Tbl_Auditorias]
            CHECK CONSTRAINT [FK_Tbl_Auditorias_Tbl_TipoAuditoria];
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
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_Persona] FOREIGN KEY([id_persona])
            REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]
            CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_Persona];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
            REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]
            CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_ProtocoloProcedimiento];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
            REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]
            CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TanquesCriogenicos];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesCriticos] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente] FOREIGN KEY([id_tipoInc])
            REFERENCES [dbo].[Tbl_TipoIncidente] ([id_tipoInc]);

            ALTER TABLE [dbo].[Tbl_IncidentesCriticos]
            CHECK CONSTRAINT [FK_Tbl_IncidentesCriticos_Tbl_TipoIncidente];
        END

        IF OBJECT_ID('dbo.Tbl_Preservaciones') IS NULL
        BEGIN
            CREATE TABLE [dbo].[Tbl_Preservaciones](
                [id_preservacion] [int] IDENTITY(1,1) NOT NULL,
                [id_cliente] [int] NOT NULL,
                [fecha_preservacion] [date] NULL,
                :contentReference[oaicite:32]{index=32} NULL,
                 NULL,
                [id_tanque] [int] NOT NULL,
                [id_protocolo] [int] NOT NULL,
             CONSTRAINT [PK_Tbl_Preservaciones] PRIMARY KEY CLUSTERED
            (
                [id_preservacion] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Preservaciones_Tbl_Persona] FOREIGN KEY([id_cliente])
            REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_Preservaciones]
            CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_Persona];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento] FOREIGN KEY([id_protocolo])
            REFERENCES [dbo].[Tbl_ProtocoloProcedimiento] ([id_protocolo]);

            ALTER TABLE [dbo].[Tbl_Preservaciones]
            CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_ProtocoloProcedimiento];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_Preservaciones] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
            REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_Preservaciones]
            CHECK CONSTRAINT [FK_Tbl_Preservaciones_Tbl_TanquesCriogenicos];
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
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_TanquesAuditoria_Tbl_Auditorias'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_TanquesAuditoria] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_Auditorias] FOREIGN KEY([id_auditoria])
            REFERENCES [dbo].[Tbl_Auditorias] ([id_auditoria]);

            ALTER TABLE [dbo].[Tbl_TanquesAuditoria]
            CHECK CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_Auditorias];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_TanquesAuditoria] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos] FOREIGN KEY([id_tanque])
            REFERENCES [dbo].[Tbl_TanquesCriogenicos] ([id_tanque]);

            ALTER TABLE [dbo].[Tbl_TanquesAuditoria]
            CHECK CONSTRAINT [FK_Tbl_TanquesAuditoria_Tbl_TanquesCriogenicos];
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
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos] FOREIGN KEY([id_evento])
            REFERENCES [dbo].[Tbl_IncidentesCriticos] ([id_evento]);

            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones]
            CHECK CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_IncidentesCriticos];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones] FOREIGN KEY([id_preservacion])
            REFERENCES [dbo].[Tbl_Preservaciones] ([id_preservacion]);

            ALTER TABLE [dbo].[Tbl_IncidentesPreservaciones]
            CHECK CONSTRAINT [FK_Tbl_IncidentesPreservaciones_Tbl_Preservaciones];
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
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_MonitoreoPersona] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques] FOREIGN KEY([id_monitoreo])
            REFERENCES [dbo].[Tbl_MonitoreoTanques] ([id_monitoreo]);

            ALTER TABLE [dbo].[Tbl_MonitoreoPersona]
            CHECK CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_MonitoreoTanques];
        END

        IF NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = 'FK_Tbl_MonitoreoPersona_Tbl_Persona'
        )
        BEGIN
            ALTER TABLE [dbo].[Tbl_MonitoreoPersona] WITH CHECK
            ADD CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_Persona] FOREIGN KEY([cedula])
            REFERENCES [dbo].[Tbl_Persona] ([cedula]);

            ALTER TABLE [dbo].[Tbl_MonitoreoPersona]
            CHECK CONSTRAINT [FK_Tbl_MonitoreoPersona_Tbl_Persona];
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
