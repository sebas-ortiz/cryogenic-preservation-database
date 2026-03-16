-- NOTE:
-- The scripts in this repository assume that the tables "Padron_Completo"
-- and "Distelec" from the TSE Electoral Registry, along with the four
-- phone tables (each imported from a separate CSV file), are already
-- loaded in the database. If these datasets are not preloaded, some
-- scripts may fail during execution.

INSERT INTO dbo.Telefonos_General (Telefono, Cedula, Nombre_Cliente)
VALUES
('8888-0001', '101000001', 'Carlos Ramirez'),
('8888-0002', '101000002', 'Lucia Porras'),
('8888-0003', '101000003', 'Ana Perez'),
('8888-0004', '101000004', 'German Carvajal');
GO

INSERT INTO dbo.Telefonos_General_V2 (Cedula, Nombre, Cantidad_Telefonos, Telefonos)
VALUES
('101000001', 'Carlos Ramirez', 1, '8888-0001'),
('101000002', 'Lucia Porras', 1, '8888-0002'),
('101000003', 'Ana Perez', 1, '8888-0003'),
('101000004', 'German Carvajal', 1, '8888-0004');
GO

INSERT INTO dbo.Tbl_PersonaTSE (cedula, nombre, apellido1, apellido2, vencimiento_cedula)
VALUES
(101000001, 'Carlos', 'Ramirez', 'Gonzalez', '2029-12-31'),
(101000002, 'Lucia', 'Porras', 'Agüero', '2028-11-30'),
(101000003, 'Ana', 'Perez', 'Perez', '2030-06-30'),
(101000004, 'German', 'Carvajal', 'Bermudez', '2027-10-15');
GO

INSERT INTO dbo.Tbl_DistritoElectoral (codigo_electoral, provincia, canton, distrito)
VALUES
(30101, 'Cartago', 'Cartago', 'Oriental'),
(30102, 'Cartago', 'Cartago', 'Occidental'),
(40101, 'Heredia', 'Heredia', 'Heredia'),
(10201, 'San Jose', 'Escazu', 'Escazu');
GO

INSERT INTO dbo.Tbl_LugarVotacion (junta_votos, cedula, codigo_electoral)
VALUES
('JRV-001', 101000001, 30101),
('JRV-002', 101000002, 30102),
('JRV-003', 101000003, 40101),
('JRV-004', 101000004, 10201);
GO

INSERT INTO dbo.Tbl_Roles (nombre_rol, descripcion_rol)
VALUES
('Director General', 'Leads the organization and strategic decisions'),
('Maintenance Supervisor', 'Supervises maintenance operations'),
('Cryogenic Operator', 'Operates cryogenic equipment and processes'),
('Internal Auditor', 'Performs internal audits'),
('IT Technician', 'Supports systems and infrastructure');
GO

INSERT INTO dbo.Tbl_TipoAuditoria (nombre_tipoAud, descripcion_tipoAud)
VALUES
('Internal Audit', 'Review of internal controls and procedures'),
('Safety Audit', 'Review of occupational and industrial safety'),
('Legal Compliance Audit', 'Verification of legal and regulatory compliance'),
('Systems Audit', 'Review of data integrity and system operations');
GO

INSERT INTO dbo.Tbl_TipoIncidente (nombre_tipoInc, descripcion_tipoInc)
VALUES
('Pressure Failure', 'Unexpected pressure condition in equipment'),
('Refrigerant Leak', 'Leak or loss of refrigerant'),
('Monitoring Failure', 'Monitoring system stopped collecting data'),
('Occupational Safety Incident', 'Event affecting worker safety'),
('Electrical Failure', 'Electrical interruption affecting operations');
GO

INSERT INTO dbo.Tbl_Persona (
    cedula,
    nombre,
    apellido1,
    apellido2,
    id_rol,
    certificacion_empleado,
    estado_empleado,
    fecha_nacimiento_cliente,
    contacto_emergencia_cliente,
    estado_contrato_cliente,
    fecha_ingreso_cliente,
    tipo_preservacion_cliente
)
VALUES
(101000001, 'Carlos', 'Ramirez', 'Gonzalez', 4, 'ISO 9001 Internal Auditor', 'Activo', '1985-06-15', 'Ana Ramirez', 'Vigente', '2020-01-10', 'Cryogenic Preservation'),
(101000002, 'Lucia', 'Porras', 'Agüero', 2, 'Advanced Maintenance Certification', 'Activo', '1990-02-07', 'Carlos Porras', 'Vigente', '2021-05-10', 'Cryogenic Preservation'),
(101000003, 'Ana', 'Perez', 'Perez', 1, 'Bioethics Certification', 'Activo', '1992-02-04', 'Daniel Perez', 'Vigente', '2019-09-22', 'Cryogenic Preservation'),
(101000004, 'German', 'Carvajal', 'Bermudez', 3, 'Cryogenics Operations Certification', 'Activo', '1986-10-19', 'Andrea Bermudez', 'Vigente', '2020-02-15', 'Cryogenic Preservation'),
(101000005, 'Jose', 'Acuna', 'Acuna', 5, 'Systems Administration Certification', 'Activo', '1991-02-04', 'Laura Acuna', 'Vigente', '2020-03-01', 'Cryogenic Preservation');
GO

INSERT INTO dbo.Tbl_ConsentimientoLegal (
    id_persona,
    tipo_documento,
    fecha_firma,
    estado_validacion,
    observaciones
)
VALUES
(101000001, 'Informed Consent for Cryogenic Preservation', '2020-01-10', 'Validado', 'Signed in person'),
(101000003, 'Medical Procedure Authorization', '2019-09-22', 'Pendiente', 'Awaiting legal review'),
(101000004, 'Data Processing Authorization', '2020-02-15', 'Validado', 'Digitally archived');
GO

INSERT INTO dbo.Tbl_TanquesCriogenicos (
    ubicacion_fisica,
    capacidad_maxima,
    tipo_refrigerante,
    estado_operativo
)
VALUES
('Central Plant - Zone A', 5000, 'Liquid Nitrogen', 'Operativo'),
('Cryogenic Lab - Room 3', 2500, 'Liquid Helium', 'Operativo'),
('Storage Area - Sector B', 4000, 'Liquid Nitrogen', 'Mantenimiento');
GO

INSERT INTO dbo.Tbl_MonitoreoTanques (
    id_tanque,
    fecha_hora,
    temperatura,
    presion,
    nivel_refrigerante,
    alertas
)
VALUES
(1, '2025-11-01 08:00:00', -196.00, 1.20, 85.50, NULL),
(2, '2025-11-01 08:05:00', -269.00, 0.95, 78.20, 'Low pressure detected'),
(3, '2025-11-01 08:10:00', -185.50, 1.10, 62.00, 'Maintenance review required');
GO

INSERT INTO dbo.Tbl_ProtocoloProcedimiento (
    nombre_protocolo,
    version,
    fecha_implementacion,
    estado
)
VALUES
('Cryogenic Safety Protocol', 'v2.0', '2023-06-25', 'Activo'),
('Preventive Maintenance Protocol', 'v2.2', '2024-03-10', 'Activo'),
('Internal Audit Protocol', 'v3.0', '2024-01-08', 'Activo');
GO

INSERT INTO dbo.Tbl_Auditorias (
    id_tipoAud,
    id_protocolo,
    cumplimiento,
    observaciones,
    fecha_aud,
    entidad_auditora,
    resultado_aud,
    recomendaciones,
    id_responsable
)
VALUES
(1, 3, 1, 'No critical findings detected', '2025-10-01', 'Internal Audit Unit', 'Satisfactory compliance', 'Maintain current controls', 101000001),
(2, 1, 0, 'Deficiencies found in safety drills', '2025-09-15', 'Safety Consultants CR', 'Partial non-compliance', 'Improve evacuation drills', 101000002),
(4, 2, 1, 'Systems operating normally', '2025-08-20', 'Digital Audit Team', 'Acceptable', 'Review user access quarterly', 101000005);
GO

INSERT INTO dbo.Tbl_IncidentesCriticos (
    fecha_hora,
    id_tanque,
    id_tipoInc,
    impacto,
    acciones_correctivas,
    id_persona,
    id_protocolo
)
VALUES
('2025-10-01 07:45:00', 1, 1, 'Pressure instability in storage tank', 'Pressure valve inspected and adjusted', 101000002, 1),
('2025-09-15 08:10:00', 2, 2, 'Minor refrigerant leak in lab room', 'Area isolated and refrigerant line replaced', 101000004, 1),
('2025-08-20 09:00:00', 3, 3, 'Monitoring interruption for 30 minutes', 'System restarted and logs verified', 101000005, 2);
GO

INSERT INTO dbo.Tbl_Preservaciones (
    id_cliente,
    fecha_preservacion,
    tipo_preservacion,
    estado_actual,
    id_tanque,
    id_protocolo
)
VALUES
(101000001, '2020-01-10', 'Cryogenic Preservation', 'Activo', 1, 1),
(101000003, '2019-09-22', 'Cryogenic Preservation', 'Activo', 2, 1),
(101000004, '2020-02-15', 'Cryogenic Preservation', 'Activo', 3, 2);
GO

INSERT INTO dbo.Tbl_TanquesAuditoria (id_tanque, id_auditoria)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

INSERT INTO dbo.Tbl_IncidentesPreservaciones (id_evento, id_preservacion)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

INSERT INTO dbo.Tbl_MonitoreoPersona (id_monitoreo, cedula)
VALUES
(1, 101000002),
(2, 101000004),
(3, 101000005);
GO
