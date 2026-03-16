IF OBJECT_ID('dbo.Telefonos_General', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Telefonos_General (
        Telefono VARCHAR(50) NOT NULL,
        Cedula VARCHAR(50) NOT NULL,
        Nombre_Cliente VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Telefonos_General_V2', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Telefonos_General_V2 (
        Cedula VARCHAR(50) NOT NULL,
        Nombre VARCHAR(100) NOT NULL,
        Cantidad_Telefonos INT NOT NULL,
        Telefonos VARCHAR(MAX) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_PersonaTSE', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_PersonaTSE (
        cedula INT NOT NULL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        apellido1 VARCHAR(50) NOT NULL,
        apellido2 VARCHAR(50) NOT NULL,
        vencimiento_cedula VARCHAR(50) NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_DistritoElectoral', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_DistritoElectoral (
        codigo_electoral INT NOT NULL PRIMARY KEY,
        provincia VARCHAR(50) NOT NULL,
        canton VARCHAR(50) NOT NULL,
        distrito VARCHAR(50) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Tbl_LugarVotacion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tbl_LugarVotacion (
        junta_votos VARCHAR(50) NOT NULL PRIMARY KEY,
        cedula INT NOT NULL,
        codigo_electoral INT NOT NULL,
        CONSTRAINT FK_Tbl_LugarVotacion_Tbl_PersonaTSE
            FOREIGN KEY (cedula) REFERENCES dbo.Tbl_PersonaTSE(cedula),
        CONSTRAINT FK_Tbl_LugarVotacion_Tbl_DistritoElectoral
            FOREIGN KEY (codigo_electoral) REFERENCES dbo.Tbl_DistritoElectoral(codigo_electoral)
    );
END;
GO
