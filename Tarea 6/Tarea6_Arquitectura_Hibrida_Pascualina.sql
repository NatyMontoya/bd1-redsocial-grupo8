/*
===============================================================================
RED SOCIAL PASCUALINA - TAREA 6
ARQUITECTURA HIBRIDA: MODELO RELACIONAL, JSONB E IoT
Integrantes: Natalia Montoya y Darwin Esteban Palacio
Motor: PostgreSQL
Herramienta de administración: pgAdmin 4
Base de datos: red_social_pascualina
Fecha: noviembre de 2026

IMPORTANTE:
Este archivo es una recopilación documentada de las instrucciones utilizadas
y consultas de verificación de la actividad. NO ejecutar todo el archivo de
forma consecutiva sobre una base de datos que ya contiene información.

Las instrucciones INSERT originales de estudiante, perfil, publicacion y
comentario.

Las instrucciones DDL usan IF NOT EXISTS / ADD COLUMN IF NOT EXISTS cuando
corresponde. Las instrucciones UPDATE y el INSERT de eventos IoT también
representan operaciones ya realizadas; se conservan como evidencia documental.
===============================================================================
*/


/* ============================================================================
1. DDL - ADAPTACION DEL MODELO RELACIONAL PARA DATOS SEMIESTRUCTURADOS E IoT
============================================================================ */

/*
Se agregan columnas JSONB para almacenar atributos flexibles:
- perfil.preferencias: intereses y configuraciones del estudiante.
- publicacion.metadatos: características y etiquetas de los contenidos.
*/

ALTER TABLE perfil
ADD COLUMN IF NOT EXISTS preferencias JSONB
NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE publicacion
ADD COLUMN IF NOT EXISTS metadatos JSONB
NOT NULL DEFAULT '{}'::jsonb;


/*
Tabla de eventos IoT particionada por rango de fecha.
La clave primaria incluye la fecha de captura, requerida por PostgreSQL
para una tabla particionada por RANGE(fecha_captura).
*/

CREATE TABLE IF NOT EXISTS evento_iot (
    id_evento BIGINT GENERATED ALWAYS AS IDENTITY,
    fecha_captura TIMESTAMPTZ NOT NULL,
    dispositivo_id VARCHAR(50) NOT NULL,
    tipo_sensor VARCHAR(40) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    valor NUMERIC(12,3) NOT NULL,
    unidad VARCHAR(20) NOT NULL,
    datos_adicionales JSONB NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT pk_evento_iot PRIMARY KEY (id_evento, fecha_captura),
    CONSTRAINT chk_valor_iot CHECK (valor >= 0)
)
PARTITION BY RANGE (fecha_captura);


/* Partición para noviembre de 2026. */
CREATE TABLE IF NOT EXISTS evento_iot_2026_11
PARTITION OF evento_iot
FOR VALUES FROM ('2026-11-01 00:00:00+00')
TO ('2026-12-01 00:00:00+00');


/* Partición para diciembre de 2026. */
CREATE TABLE IF NOT EXISTS evento_iot_2026_12
PARTITION OF evento_iot
FOR VALUES FROM ('2026-12-01 00:00:00+00')
TO ('2027-01-01 00:00:00+00');


/* Partición por defecto para fechas fuera de los rangos anteriores. */
CREATE TABLE IF NOT EXISTS evento_iot_otros
PARTITION OF evento_iot DEFAULT;


/* Índices para apoyar filtros por fecha, tipo de sensor y contenido JSONB. */
CREATE INDEX IF NOT EXISTS idx_evento_iot_fecha
ON evento_iot (fecha_captura);

CREATE INDEX IF NOT EXISTS idx_evento_iot_tipo_fecha
ON evento_iot (tipo_sensor, fecha_captura DESC);

CREATE INDEX IF NOT EXISTS idx_evento_iot_jsonb
ON evento_iot USING GIN (datos_adicionales jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_publicacion_metadatos
ON publicacion USING GIN (metadatos jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_perfil_preferencias
ON perfil USING GIN (preferencias jsonb_path_ops);


/* Actualización de estadísticas del optimizador. */
ANALYZE perfil;
ANALYZE publicacion;
ANALYZE evento_iot;


/* ============================================================================
2. DML - INSERCION Y ACTUALIZACION DE DATOS
============================================================================ */

/*
2.1 a 2.4. Inserciones relacionales ejecutadas previamente en pgAdmin 4:
- estudiante: 10 registros.
- perfil: 10 registros.
- publicacion: registros de publicaciones de los estudiantes.
- comentario: 15 registros.

Los bloques INSERT originales se mantienen en el historial de ejecución de
pgAdmin 4 y no se reconstruyen en este archivo para evitar alterar los datos
con valores inventados o diferentes a los que fueron ejecutados.
*/


/*
2.5. Inserción de cuatro eventos IoT simulados en el aula B203.
Esta operación ya fue ejecutada en la base de datos.
NO volver a ejecutarla sobre una base que ya contiene estos eventos.
*/

INSERT INTO evento_iot (
    fecha_captura,
    dispositivo_id,
    tipo_sensor,
    ubicacion,
    valor,
    unidad,
    datos_adicionales
)
VALUES
(
    '2026-11-19 08:00:00-05',
    'SENSOR_OC_001',
    'ocupacion',
    'Aula B203',
    18,
    'personas',
    '{"aula":"B203","bateria":87,"estado":"activo"}'::jsonb
),
(
    '2026-11-19 10:00:00-05',
    'SENSOR_OC_001',
    'ocupacion',
    'Aula B203',
    22,
    'personas',
    '{"aula":"B203","bateria":85,"estado":"activo"}'::jsonb
),
(
    '2026-11-19 08:00:00-05',
    'SENSOR_TEM_001',
    'temperatura',
    'Aula B203',
    24.5,
    'grados_celsius',
    '{"aula":"B203","bateria":92,"estado":"activo"}'::jsonb
),
(
    '2026-11-19 08:00:00-05',
    'SENSOR_HUM_001',
    'humedad',
    'Aula B203',
    58.2,
    'porcentaje',
    '{"aula":"B203","bateria":90,"estado":"activo"}'::jsonb
);


/*
2.6. Actualización de metadatos JSONB de una publicación.
Operación ya ejecutada: asigna información del archivo y etiquetas
a la publicación con id_publicacion = 1.
*/

UPDATE publicacion
SET metadatos = '{
    "tipo": "imagen",
    "formato": "jpg",
    "resolucion": "1920x1080",
    "etiquetas": ["tecnologia", "estudiantes", "programacion"]
}'::jsonb
WHERE id_publicacion = 1;


/*
2.7. Actualización de preferencias JSONB del primer perfil.
Operación ya ejecutada: registra intereses, notificaciones y tema visual.
*/

UPDATE perfil
SET preferencias = '{
    "intereses": [
        "programacion",
        "bases de datos"
    ],
    "notificaciones": {
        "publicaciones": true,
        "eventos": true
    },
    "tema": "oscuro"
}'::jsonb
WHERE id_estudiante = (
    SELECT MIN(id_estudiante)
    FROM perfil
);


/* 2.8. Verificación de cantidades actuales de registros. */
SELECT 'estudiante' AS tabla, COUNT(*) AS total_registros
FROM estudiante
UNION ALL
SELECT 'perfil', COUNT(*)
FROM perfil
UNION ALL
SELECT 'publicacion', COUNT(*)
FROM publicacion
UNION ALL
SELECT 'comentario', COUNT(*)
FROM comentario
UNION ALL
SELECT 'evento_iot', COUNT(*)
FROM evento_iot;


/* ============================================================================
3. CONSULTAS SOBRE CAMPOS JSONB
============================================================================ */

/* 3.1. Consultar publicaciones cuyo metadato indica que son imágenes. */
SELECT id_publicacion, metadatos
FROM publicacion
WHERE metadatos @> '{"tipo": "imagen"}'::jsonb;


/* 3.2. Consultar perfiles cuyo tema preferido es oscuro. */
SELECT id_estudiante, preferencias
FROM perfil
WHERE preferencias @> '{"tema": "oscuro"}'::jsonb;


/*
3.3. Consultar eventos IoT activos con batería inferior al 90%.
->> extrae el valor JSON como texto; posteriormente se convierte a INTEGER.
*/

SELECT
    id_evento,
    dispositivo_id,
    tipo_sensor,
    ubicacion,
    datos_adicionales ->> 'aula' AS aula,
    datos_adicionales ->> 'estado' AS estado,
    (datos_adicionales ->> 'bateria')::integer AS bateria
FROM evento_iot
WHERE datos_adicionales @> '{"estado": "activo"}'::jsonb
  AND (datos_adicionales ->> 'bateria')::integer < 90
ORDER BY bateria ASC;


/* ============================================================================
4. CONSULTAS CON JOIN Y FUNCIONES DE AGREGACION
============================================================================ */

/*
4.1. Resumen de publicaciones y comentarios por estudiante.
COUNT(DISTINCT ...) evita contar una publicación varias veces cuando tiene
más de un comentario. LEFT JOIN permite incluir estudiantes sin publicaciones.
*/

SELECT
    e.id_estudiante,
    e.nombres,
    e.apellidos,
    e.programa_academico,
    COUNT(DISTINCT p.id_publicacion) AS total_publicaciones,
    COUNT(c.id_comentario) AS total_comentarios
FROM estudiante e
LEFT JOIN publicacion p
    ON e.id_estudiante = p.id_estudiante
LEFT JOIN comentario c
    ON p.id_publicacion = c.id_publicacion
GROUP BY
    e.id_estudiante,
    e.nombres,
    e.apellidos,
    e.programa_academico
ORDER BY total_publicaciones DESC;


/* 4.2. Relacionar estudiantes con sus intereses almacenados en JSONB. */
SELECT
    e.id_estudiante,
    e.nombres,
    e.apellidos,
    e.programa_academico,
    p.preferencias -> 'intereses' AS intereses,
    p.preferencias ->> 'tema' AS tema_preferido
FROM estudiante e
INNER JOIN perfil p
    ON e.id_estudiante = p.id_estudiante
WHERE p.preferencias @> '{"intereses": ["programacion"]}'::jsonb
ORDER BY e.nombres;


/* 4.3. Consultar publicaciones y sus metadatos junto con el estudiante autor. */
SELECT
    p.id_publicacion,
    e.nombres,
    e.apellidos,
    p.tipo_publicacion,
    p.metadatos ->> 'tipo' AS tipo_archivo,
    p.metadatos ->> 'formato' AS formato,
    p.metadatos -> 'etiquetas' AS etiquetas
FROM publicacion p
INNER JOIN estudiante e
    ON p.id_estudiante = e.id_estudiante
WHERE p.metadatos @> '{"etiquetas": ["tecnologia"]}'::jsonb
ORDER BY p.id_publicacion;


/*
4.4. Estadísticas de mediciones IoT por tipo de sensor y ubicación.
Se utilizan COUNT, AVG, MIN, MAX y SUM para resumir los valores registrados.
*/

SELECT
    tipo_sensor,
    ubicacion,
    unidad,
    COUNT(*) AS total_mediciones,
    ROUND(AVG(valor), 2) AS promedio,
    MIN(valor) AS valor_minimo,
    MAX(valor) AS valor_maximo,
    ROUND(SUM(valor), 2) AS suma_valores
FROM evento_iot
GROUP BY tipo_sensor, ubicacion, unidad
ORDER BY tipo_sensor, ubicacion;


/* 4.5. Agrupar eventos IoT utilizando atributos almacenados en JSONB. */
SELECT
    tipo_sensor,
    datos_adicionales ->> 'aula' AS aula,
    datos_adicionales ->> 'estado' AS estado,
    COUNT(*) AS total_eventos,
    ROUND(
        AVG((datos_adicionales ->> 'bateria')::numeric),
        2
    ) AS promedio_bateria
FROM evento_iot
GROUP BY
    tipo_sensor,
    datos_adicionales ->> 'aula',
    datos_adicionales ->> 'estado'
ORDER BY tipo_sensor;


/* ============================================================================
5. PRUEBAS DE RENDIMIENTO Y USO DE INDICES JSONB
============================================================================ */

/* Actualizar estadísticas antes de analizar los planes de ejecución. */
ANALYZE publicacion;
ANALYZE perfil;


/* Plan de ejecución de la consulta JSONB sobre publicaciones. */
EXPLAIN ANALYZE
SELECT id_publicacion, metadatos
FROM publicacion
WHERE metadatos @> '{"tipo": "imagen"}'::jsonb;


/* Plan de ejecución de la consulta JSONB sobre perfiles. */
EXPLAIN ANALYZE
SELECT id_estudiante, preferencias
FROM perfil
WHERE preferencias @> '{"tema": "oscuro"}'::jsonb;


/*
Para fines demostrativos se desactiva temporalmente la preferencia por
escaneos secuenciales, con el propósito de observar si PostgreSQL puede
considerar los índices GIN. Esto NO significa que forzar el índice mejore
siempre el rendimiento; en tablas pequeñas un escaneo secuencial puede ser
la alternativa más eficiente.
*/

SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT id_estudiante, preferencias
FROM perfil
WHERE preferencias @> '{"tema": "oscuro"}'::jsonb;

EXPLAIN ANALYZE
SELECT id_publicacion, metadatos
FROM publicacion
WHERE metadatos @> '{"tipo": "imagen"}'::jsonb;


/* Restaurar el comportamiento normal del optimizador. */
SET enable_seqscan = ON;


/* ============================================================================
6. INVENTARIO Y DIAGNOSTICO DE LA BASE DE DATOS
============================================================================ */

/* 6.1. Listado de tablas del esquema public. */
SELECT tablename AS nombre_tabla
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;


/* 6.2. Columnas y tipos de las tablas principales. */
SELECT
    table_name AS tabla,
    column_name AS columna,
    data_type AS tipo_dato,
    is_nullable AS permite_nulos,
    column_default AS valor_por_defecto
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'estudiante',
      'perfil',
      'publicacion',
      'comentario',
      'evento_iot'
  )
ORDER BY table_name, ordinal_position;


/* 6.3. Identificar columnas JSONB del esquema public. */
SELECT
    table_name AS tabla,
    column_name AS campo_jsonb,
    data_type AS tipo_dato
FROM information_schema.columns
WHERE table_schema = 'public'
  AND data_type = 'jsonb'
ORDER BY table_name, column_name;


/* 6.4. Consultar las particiones de evento_iot. */
SELECT
    parent.relname AS tabla_principal,
    child.relname AS particion,
    pg_get_expr(child.relpartbound, child.oid) AS limite_particion
FROM pg_inherits
JOIN pg_class parent
    ON pg_inherits.inhparent = parent.oid
JOIN pg_class child
    ON pg_inherits.inhrelid = child.oid
WHERE parent.relname = 'evento_iot'
ORDER BY child.relname;


/* 6.5. Consultar índices del esquema public. */
SELECT
    tablename AS tabla,
    indexname AS indice,
    indexdef AS definicion
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


/* 6.6. Consultar vistas del esquema public. */
SELECT
    table_name AS nombre_vista
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;


/* 6.7. Consultar cantidad de eventos IoT registrados. */
SELECT COUNT(*) AS total_eventos_iot
FROM evento_iot;


/*
6.8. Consultar restricciones PRIMARY KEY, FOREIGN KEY y UNIQUE
de las cinco tablas principales.
*/

SELECT
    tc.table_name AS tabla,
    tc.constraint_name AS restriccion,
    tc.constraint_type AS tipo,
    kcu.column_name AS campo,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS campo_referenciado
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.constraint_schema = kcu.constraint_schema
LEFT JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.constraint_schema = ccu.constraint_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name IN (
      'estudiante',
      'perfil',
      'publicacion',
      'comentario',
      'evento_iot'
  )
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE')
ORDER BY tc.table_name, tc.constraint_type;


/* 6.9. Inventario completo de columnas del esquema public. */
SELECT
    table_name AS tabla,
    column_name AS campo,
    data_type AS tipo_dato,
    udt_name AS tipo_postgresql,
    is_nullable AS permite_nulos,
    column_default AS valor_por_defecto
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;


/* ============================================================================
FIN DEL SCRIPT
============================================================================ */
