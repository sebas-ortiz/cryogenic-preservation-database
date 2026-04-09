CREATE TABLE Tbl_LogAcciones (
    usuario VARCHAR(200),
    accion VARCHAR(10),
    fecha DATETIME2
);
GO

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
