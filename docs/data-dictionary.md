Data Dictionary
Cryogenics Traceability Database


Tbl_Roles
Stores the available roles within the organization.
| Column          | Type         | Description      |
| --------------- | ------------ | ---------------- |
| id_rol          | int          | Role identifier  |
| nombre_rol      | varchar(50)  | Role name        |
| descripcion_rol | varchar(100) | Role description |

Tbl_TipoAuditoria
Stores the audit categories used in the system.

| Column              | Type         | Description            |
| ------------------- | ------------ | ---------------------- |
| id_tipoAud          | int          | Audit type identifier  |
| nombre_tipoAud      | varchar(50)  | Audit type name        |
| descripcion_tipoAud | varchar(100) | Audit type description |

Tbl_TipoIncidente
Stores the incident categories used in the system.
| Column              | Type         | Description               |
| ------------------- | ------------ | ------------------------- |
| id_tipoInc          | int          | Incident type identifier  |
| nombre_tipoInc      | varchar(50)  | Incident type name        |
| descripcion_tipoInc | varchar(100) | Incident type description |

Tbl_Persona
Stores employee and client information.
| Column                      | Type         | Description                     |
| --------------------------- | ------------ | ------------------------------- |
| cedula                      | int          | Unique identifier of the person |
| nombre                      | varchar(150) | First name                      |
| apellido1                   | varchar(150) | First surname                   |
| apellido2                   | varchar(150) | Second surname                  |
| id_rol                      | int          | Assigned role                   |
| certificacion_empleado      | text         | Employee certifications         |
| estado_empleado             | varchar(20)  | Employment status               |
| fecha_nacimiento_cliente    | date         | Client birth date               |
| contacto_emergencia_cliente | varchar(150) | Emergency contact               |
| estado_contrato_cliente     | varchar(20)  | Client contract status          |
| fecha_ingreso_cliente       | date         | Client entry date               |
| tipo_preservacion_cliente   | varchar(50)  | Type of preservation            |

Tbl_ConsentimientoLegal
Stores legal consent documentation signed by clients.
| Column            | Type         | Description                        |
| ----------------- | ------------ | ---------------------------------- |
| id_consentimiento | int          | Consent document identifier        |
| id_persona        | int          | Person associated with the consent |
| tipo_documento    | varchar(100) | Document type                      |
| fecha_firma       | date         | Signature date                     |
| estado_validacion | varchar(20)  | Validation status                  |
| observaciones     | text         | Additional notes                   |

Tbl_TanquesCriogenicos
Stores cryogenic tank information.
| Column            | Type         | Description               |
| ----------------- | ------------ | ------------------------- |
| id_tanque         | int          | Cryogenic tank identifier |
| ubicacion_fisica  | varchar(100) | Physical tank location    |
| capacidad_maxima  | int          | Maximum tank capacity     |
| tipo_refrigerante | varchar(50)  | Refrigerant type          |
| estado_operativo  | varchar(20)  | Operational status        |

Tbl_MonitoreoTanques
Stores monitoring measurements from cryogenic tanks.
| Column             | Type         | Description           |
| ------------------ | ------------ | --------------------- |
| id_monitoreo       | int          | Monitoring identifier |
| id_tanque          | int          | Tank being monitored  |
| fecha_hora         | datetime     | Monitoring timestamp  |
| temperatura        | decimal(5,2) | Temperature reading   |
| presion            | decimal(5,2) | Pressure reading      |
| nivel_refrigerante | decimal(5,2) | Refrigerant level     |
| alertas            | text         | Generated alerts      |

Tbl_ProtocoloProcedimiento
Stores operational protocols used within the system.
| Column               | Type         | Description         |
| -------------------- | ------------ | ------------------- |
| id_protocolo         | int          | Protocol identifier |
| nombre_protocolo     | varchar(100) | Protocol name       |
| version              | varchar(20)  | Protocol version    |
| fecha_implementacion | date         | Implementation date |
| estado               | varchar(20)  | Protocol status     |

Tbl_Auditorias
Stores audit records related to operational compliance.
| Column           | Type         | Description        |
| ---------------- | ------------ | ------------------ |
| id_auditoria     | int          | Audit identifier   |
| id_tipoAud       | int          | Audit type         |
| id_protocolo     | int          | Related protocol   |
| cumplimiento     | bit          | Compliance result  |
| observaciones    | text         | Observations       |
| fecha_aud        | date         | Audit date         |
| entidad_auditora | varchar(100) | Auditing entity    |
| resultado_aud    | text         | Audit result       |
| recomendaciones  | text         | Recommendations    |
| id_responsable   | int          | Responsible person |

Tbl_IncidentesCriticos
Stores critical incidents that occur in the system.
| Column               | Type     | Description                        |
| -------------------- | -------- | ---------------------------------- |
| id_evento            | int      | Incident identifier                |
| fecha_hora           | datetime | Incident timestamp                 |
| id_tanque            | int      | Tank involved                      |
| id_tipoInc           | int      | Incident type                      |
| impacto              | text     | Description of the incident impact |
| acciones_correctivas | text     | Corrective actions taken           |
| id_persona           | int      | Person involved                    |
| id_protocolo         | int      | Protocol applied                   |

Tbl_Preservaciones
Stores cryogenic preservation records.
| Column             | Type        | Description                 |
| ------------------ | ----------- | --------------------------- |
| id_preservacion    | int         | Preservation identifier     |
| id_cliente         | int         | Client identifier           |
| fecha_preservacion | date        | Preservation date           |
| tipo_preservacion  | varchar(50) | Preservation type           |
| estado_actual      | varchar(30) | Current preservation status |
| id_tanque          | int         | Assigned tank               |
| id_protocolo       | int         | Protocol used               |

Tbl_TanquesAuditoria
Bridge table linking tanks and audits.
| Column       | Type | Description      |
| ------------ | ---- | ---------------- |
| id_tanque    | int  | Tank identifier  |
| id_auditoria | int  | Audit identifier |

Tbl_IncidentesPreservaciones
Bridge table linking incidents and preservations.
| Column          | Type | Description             |
| --------------- | ---- | ----------------------- |
| id_evento       | int  | Incident identifier     |
| id_preservacion | int  | Preservation identifier |

Tbl_MonitoreoPersona
Bridge table linking monitoring records with people.
| Column       | Type | Description           |
| ------------ | ---- | --------------------- |
| id_monitoreo | int  | Monitoring identifier |
| cedula       | int  | Person identifier     |
