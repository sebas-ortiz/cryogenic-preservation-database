CREATE OR ALTER VIEW dbo.Visualizar_Consulta
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
        WHERE t.Cedula = CAST(p.cedula AS VARCHAR(20))
    );
GO
