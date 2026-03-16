-- Procedimiento almacenado para insertar la información a las tablas de Proyecto Final
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
        ) VALUES
        ('Carlos', 'Ramírez', 'González', 9, 'Certificación ISO 9001', 'Activo', 102345678, '1985-06-15', 'Ana Ramírez', 'Vigente', '2020-01-10', 'Criopreservación biomédica'),
        ('Lucila', 'Porras', 'Agüero', 4, 'Certificación ISO 13485', 'Activo', 101053316, '1990-02-07', 'Carlos Porras', 'Vigente', '2021-05-10', 'Criopreservación biomédica'),
        ('Dinora', 'Obando', 'García', 12, 'Certificación Seguridad Industrial', 'Activo', 101086526, '1989-03-15', 'Mario Obando', 'Vigente', '2021-06-02', 'Criopreservación biomédica'),
        ('Trinidad', 'Vindas', 'Pérez', 8, 'Certificación en Auditoría Interna', 'Activo', 101141655, '1988-07-21', 'Sofía Vindas', 'Vigente', '2020-11-03', 'Criopreservación biomédica'),
        ('Ana María', 'Pérez', 'Pérez', 1, 'Certificación Bioética', 'Activo', 101240037, '1992-02-04', 'Daniel Pérez', 'Vigente', '2019-09-22', 'Criopreservación biomédica'),
        ('Germán', 'Carvajal', 'Bermúdez', 6, 'Certificación en Criogenia', 'Activo', 101280947, '1986-10-19', 'Andrea Bermúdez', 'Vigente', '2020-02-15', 'Criopreservación biomédica'),
        ('José Vicente', 'Acuña', 'Acuña', 14, 'Certificación ISO 14001', 'Activo', 101290149, '1991-02-04', 'Laura Acuña', 'Vigente', '2020-03-01', 'Criopreservación biomédica'),
        ('Benitivo', 'Arias', 'Campos', 3, 'Certificación en Gestión de Calidad', 'Activo', 101290354, '1985-03-31', 'Rosa Arias', 'Vigente', '2021-01-12', 'Criopreservación biomédica'),
        ('Ramón', 'Ríos', 'Montes', 10, 'Certificación Laboratorio Biomédico', 'Activo', 101330673, '1994-04-06', 'Camila Ríos', 'Vigente', '2021-04-20', 'Criopreservación biomédica'),
        ('José', 'Cisneros', 'Chacón', 7, 'Certificación en Control Ambiental', 'Activo', 101330473, '1987-02-20', 'Elena Cisneros', 'Vigente', '2019-12-15', 'Criopreservación biomédica'),
        ('Nelly', 'Coto', 'Solano', 2, 'Certificación Bioética', 'Activo', 101330470, '1984-10-24', 'María Solano', 'Vigente', '2020-07-10', 'Criopreservación biomédica'),
        ('Antonio Mario', 'Rodríguez', 'Araya', 5, 'Certificación Laboratorio Clínico', 'Activo', 101330899, '1993-02-04', 'Julio Rodríguez', 'Vigente', '2021-02-18', 'Criopreservación biomédica'),
        ('Adán', 'Céspedes', 'Arias', 13, 'Certificación Mantenimiento Preventivo', 'Activo', 101350119, '1988-02-06', 'Patricia Céspedes', 'Vigente', '2020-08-12', 'Criopreservación biomédica'),
        ('Julieta', 'Castro', 'Alvarado', 11, 'Certificación Sistemas de Refrigeración', 'Activo', 101350825, '1997-08-17', 'Sergio Castro', 'Vigente', '2021-03-09', 'Criopreservación biomédica'),
        ('Gabriela', 'Quesada', 'Talavera', 9, 'Certificación en Criogenia Avanzada', 'Activo', 101350654, '1995-02-04', 'Carolina Quesada', 'Vigente', '2020-10-11', 'Criopreservación biomédica'),
        ('Julieta', 'Zeledón', 'Matamoros', 8, 'Certificación Biomédica', 'Activo', 101370377, '1999-09-10', 'Raúl Zeledón', 'Vigente', '2022-01-04', 'Criopreservación biomédica'),
        ('Emelina', 'Hidalgo', 'Flores', 14, 'Certificación Biomédica', 'Activo', 101370531, '1998-02-04', 'Luis Hidalgo', 'Vigente', '2021-06-14', 'Criopreservación biomédica'),
        ('Guadalupe', 'Alpízar', 'Brenes', 1, 'Certificación en Refrigeración', 'Activo', 101370879, '1987-02-04', 'Marta Alpízar', 'Vigente', '2019-11-09', 'Criopreservación biomédica'),
        ('Luz', 'Jiménez', 'Moreno', 3, 'Certificación ISO 9001', 'Activo', 101380562, '1986-07-10', 'César Jiménez', 'Vigente', '2020-03-05', 'Criopreservación biomédica'),
        ('María Josefa', 'Rodríguez', 'Madrigal', 5, 'Certificación Supervisión General', 'Activo', 101390652, '1983-02-06', 'Pablo Rodríguez', 'Vigente', '2018-12-17', 'Criopreservación biomédica'),
        ('Cidely María', 'Rodríguez', 'Madrigal', 7, 'Certificación Supervisión General', 'Activo', 101390996, '1990-02-02', 'Daniela Rodríguez', 'Vigente', '2019-08-22', 'Criopreservación biomédica'),
        ('Sofía', 'Solano', 'Vargas', 11, 'Certificación ISO 9001', 'Activo', 104567893, '1992-04-09', 'Mario Solano', 'Vigente', '2020-10-11', 'Criopreservación biomédica'),
        ('Daniel', 'Jiménez', 'Rojas', 10, 'Certificación en Seguridad', 'Activo', 103894521, '1989-09-05', 'Patricia Jiménez', 'Vigente', '2021-02-12', 'Criopreservación biomédica'),
        ('Fabiola', 'Gómez', 'Sáenz', 13, 'Certificación ISO 13485', 'Activo', 101231457, '1993-12-19', 'Juan Gómez', 'Vigente', '2019-06-20', 'Criopreservación biomédica'),
        ('Ricardo', 'Mora', 'Cordero', 6, 'Certificación Auditoría Interna', 'Activo', 102984512, '1987-05-30', 'Lucía Mora', 'Vigente', '2020-08-22', 'Criopreservación biomédica'),
        ('Andrea', 'Chacón', 'Vega', 2, 'Certificación Bioética', 'Activo', 104125986, '1995-08-13', 'Pablo Chacón', 'Vigente', '2022-03-04', 'Criopreservación biomédica'),
        ('Luis', 'Pérez', 'Solís', 4, 'Certificación Mantenimiento Avanzado', 'Activo', 104789652, '1986-03-21', 'Esteban Pérez', 'Vigente', '2019-05-16', 'Criopreservación biomédica'),
        ('Rosa', 'Valverde', 'Soto', 8, 'Certificación Sistemas de Control', 'Activo', 104896312, '1997-10-10', 'Laura Valverde', 'Vigente', '2020-09-20', 'Criopreservación biomédica');

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

        INSERT INTO Tbl_Auditorias (
            id_tipoAud, id_protocolo, cumplimiento, observaciones,
            fecha_aud, entidad_auditora, resultado_aud, recomendaciones, id_responsable
        ) VALUES
        (1, 1, 1, 'Auditoría interna sin hallazgos críticos.', '2025-10-01', 'Unidad de Auditoría Interna', 'Cumplimiento satisfactorio en todos los puntos.', 'Mantener controles actuales y reforzar capacitación anual.', 101240037),
        (2, 2, 0, 'Se detectaron deficiencias en seguridad ocupacional.', '2025-09-15', 'Consultores Seguridad S.A.', 'Incumplimiento en protocolos de evacuación.', 'Actualizar simulacros y señalización.', 101350119),
        (3, 3, 1, 'Cumplimiento legal verificado.', '2025-08-20', 'Auditoría Legal Externa', 'Todos los documentos están en regla.', 'Revisar cambios normativos cada trimestre.', 101290149),
        (4, 4, 0, 'Equipos con mantenimiento vencido.', '2025-07-10', 'Auditores Técnicos Ltda.', 'Fallas en registros de mantenimiento.', 'Implementar sistema de alertas automáticas.', 101290354),
        (5, 5, 1, 'Seguridad de procesos adecuada.', '2025-06-05', 'Auditoría de Procesos CR', 'Controles operativos cumplen con estándares.', 'Revisar procedimientos cada seis meses.', 101053316),
        (6, 6, 0, 'Sistemas informáticos con vulnerabilidades.', '2025-05-18', 'Auditoría Digital S.A.', 'Se detectaron accesos no autorizados.', 'Actualizar políticas de acceso y realizar pruebas de penetración.', 101231457),
        (7, 7, 1, 'Buenas prácticas de laboratorio observadas.', '2025-04-22', 'Auditoría Biomédica Internacional', 'Cumplimiento general con observaciones menores.', 'Reforzar uso de EPP y limpieza de áreas críticas.', 101350825),
        (1, 2, 1, 'Auditoría interna enfocada en seguridad.', '2025-03-30', 'Unidad de Auditoría Interna', 'Mejoras implementadas desde última revisión.', 'Continuar seguimiento semestral.', 101280947),
        (3, 4, 0, 'Incumplimiento parcial en mantenimiento legal.', '2025-02-14', 'Auditoría Legal Externa', 'Falta documentación de inspecciones recientes.', 'Digitalizar registros y establecer cronograma de inspecciones.', 101330470),
        (5, 6, 1, 'Seguridad de procesos reforzada.', '2025-01-10', 'Auditoría de Procesos CR', 'Se implementaron recomendaciones previas.', 'Monitorear indicadores de desempeño mensualmente.', 101380562);

        INSERT INTO Tbl_IncidentesCriticos (
            fecha_hora, id_tanque, id_tipoInc, impacto,
            acciones_correctivas, id_persona, id_protocolo
        ) VALUES
        ('2025-10-01 07:45:00', 3, 4, 'Falla en válvula de presión que provocó pérdida de refrigerante.', 'Reemplazo inmediato de válvula y revisión de sistema de sellado.', 101290354, 2),
        ('2025-09-15 08:10:00', 7, 2, 'Derrame de helio líquido en sala de almacenamiento.', 'Evacuación del área, limpieza especializada y revisión de protocolos de seguridad.', 101350119, 5),
        ('2025-08-20 09:00:00', 12, 6, 'Sistema informático de monitoreo dejó de registrar datos por 2 horas.', 'Reinicio del sistema, restauración de respaldo y revisión de logs.', 101231457, 6),
        ('2025-07-10 06:30:00', 5, 1, 'Empleado sufrió quemadura leve por contacto con superficie criogénica.', 'Atención médica inmediata y reforzamiento de uso de EPP.', 101053316, 1),
        ('2025-06-05 10:15:00', 9, 3, 'Incumplimiento en protocolo de calidad durante inspección rutinaria.', 'Capacitación adicional al personal y actualización de checklist de inspección.', 101290149, 3),
        ('2025-05-18 11:00:00', 14, 5, 'Presión elevada en tanque generó alarma crítica.', 'Liberación controlada de presión y revisión de sensores.', 101380562, 5),
        ('2025-04-22 08:50:00', 1, 7, 'Contaminación cruzada en laboratorio por mal manejo de muestras.', 'Desinfección total del área y reentrenamiento del personal.', 101350825, 7),
        ('2025-03-30 07:20:00', 6, 8, 'Falla en comunicación entre sensores y sistema central.', 'Reemplazo de cableado y prueba de conectividad.', 101280947, 2),
        ('2025-02-14 09:40:00', 11, 9, 'Empleado presentó síntomas respiratorios por exposición prolongada.', 'Evaluación médica, ajuste de turnos y revisión de ventilación.', 101330470, 4),
        ('2025-01-10 10:30:00', 15, 10, 'Corte eléctrico afectó operación de sistemas de refrigeración.', 'Activación de respaldo energético y revisión de UPS.', 101240037, 6);

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
        (1, 1), (2, 1), (3, 2), (4, 2), (5, 3),
        (6, 3), (7, 4), (8, 4), (9, 5), (10, 5),
        (11, 6), (12, 6), (13, 7), (14, 8), (15, 9);

        INSERT INTO Tbl_IncidentesPreservaciones (id_evento, id_preservacion) VALUES
        (1, 3), (1, 4), (2, 7), (3, 6), (4, 1),
        (5, 5), (6, 9), (7, 12), (8, 2), (9, 10);

        INSERT INTO Tbl_MonitoreoPersona (id_monitoreo, cedula) VALUES
        (1, 101240037),
        (2, 101350119),
        (3, 101290149),
        (4, 101290354),
        (5, 101053316),
        (6, 101231457),
        (7, 101350825),
        (8, 101280947),
        (9, 101330470),
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

-- Comandos para ejecutar cada proceso almacenado
EXEC dbo.sp_Crear_Tabla_Telefonos_General;
EXEC dbo.sp_Insertar_Telefonos_General;
EXEC dbo.sp_Cursor_Telefonos_General_V2;
EXEC dbo.sp_Crear_Tabla_PersonaTSE;
EXEC dbo.sp_Crear_Tabla_DistritoElectoral;
EXEC dbo.sp_Crear_Tabla_LugarVotacion;
EXEC dbo.sp_Insertar_TSE_Normalizado;
EXEC dbo.sp_Crear_Tablas_ProyectoFinal;
EXEC dbo.sp_Insertar_Tablas_Proyecto_Final;
GO
