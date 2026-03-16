IF OBJECT_ID('dbo.Tbl_LogAcciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_LogAcciones (
        usuario VARCHAR(200) NOT NULL,
        accion VARCHAR(10) NOT NULL,
        fecha DATETIME2 NOT NULL
    );
END;
GO

DROP TRIGGER IF EXISTS dbo.trg_NoInsert_TipoAuditoria;
GO

CREATE TRIGGER dbo.trg_NoInsert_TipoAuditoria
ON dbo.Tbl_TipoAuditoria
INSTEAD OF INSERT
AS
BEGIN
    RAISERROR('No se permiten inserciones en esta tabla.', 16, 1);
END;
GO

DROP TRIGGER IF EXISTS dbo.trg_LogCambios_Persona;
GO

CREATE TRIGGER dbo.trg_LogCambios_Persona
ON dbo.Tbl_Persona
AFTER UPDATE, DELETE
AS
BEGIN
    DECLARE @usuario VARCHAR(128);

    SELECT @usuario = SUSER_SNAME();

    INSERT INTO dbo.Tbl_LogAcciones (usuario, accion, fecha)
    SELECT
        ISNULL(@usuario, 'UNKNOWN'),
        CASE
            WHEN EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted) THEN 'UPDATE'
            WHEN EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted) THEN 'DELETE'
        END,
        SYSDATETIME();
END;
GO
