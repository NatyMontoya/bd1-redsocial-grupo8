# Red Social Pascualina – Arquitectura Híbrida de Base de Datos

## 1. Descripción del proyecto

Este proyecto presenta la implementación de una arquitectura híbrida de base de datos para la Red Social Pascualina, desarrollada como parte de la asignatura Análisis y Desarrollo de Software.

La solución utiliza PostgreSQL para integrar el modelo relacional con características no relacionales mediante campos JSONB. También incorpora el almacenamiento de eventos provenientes de dispositivos IoT, utilizando particionamiento e índices para facilitar la administración y consulta de la información.

## 2. Objetivo

Implementar una arquitectura de base de datos que permita gestionar información estructurada y semiestructurada, optimizando el almacenamiento y la consulta de datos relacionados con estudiantes, perfiles, publicaciones, comentarios y eventos IoT.

## 3. Tecnologías utilizadas

- **PostgreSQL:** sistema gestor de bases de datos.
- **pgAdmin 4:** herramienta para administrar y ejecutar consultas SQL.
- **SQL:** lenguaje utilizado para la definición, manipulación y consulta de datos.
- **JSONB:** tipo de dato para almacenar información semiestructurada.
- **Índices GIN:** utilizados para facilitar las búsquedas sobre campos JSONB.
- **Particionamiento RANGE:** utilizado para organizar los eventos IoT por fecha de captura.
- **GitHub:** plataforma para alojar y compartir el proyecto.

## 4. Estructura de la base de datos

La base de datos contiene las siguientes tablas principales:

| Tabla | Descripción |
|---|---|
| estudiante | Información de los estudiantes registrados. |
| perfil | Datos personales y preferencias de los estudiantes. |
| publicacion | Publicaciones realizadas en la red social. |
| comentario | Comentarios asociados a las publicaciones. |
| evento_iot | Registros generados por dispositivos y sensores IoT. |

### Campos JSONB implementados

Se incorporaron campos JSONB para almacenar información flexible:

- `perfil.preferencias`: intereses, notificaciones y configuración del usuario.
- `publicacion.metadatos`: tipo de contenido, formato, resolución y etiquetas.
- `evento_iot.datos_adicionales`: información complementaria de los eventos y dispositivos.

## 5. Implementación de eventos IoT

La tabla `evento_iot` utiliza particionamiento por rangos de fechas para organizar los registros.

Se crearon las siguientes particiones:

- `evento_iot_2026_11`
- `evento_iot_2026_12`
- `evento_iot_otros`

Esta estrategia permite distribuir los registros y facilitar su administración de acuerdo con la fecha de captura.

## 6. Funcionalidades implementadas

- Creación y modificación de estructuras de tablas.
- Incorporación de campos JSONB.
- Inserción y actualización de información semiestructurada.
- Creación de índices GIN.
- Particionamiento de eventos IoT.
- Consultas sobre documentos JSONB.
- Consultas con JOIN entre diferentes tablas.
- Consultas de agregación mediante COUNT, SUM, AVG y GROUP BY.
- Evaluación de consultas mediante EXPLAIN ANALYZE.
- Verificación de registros, particiones e índices.

## 7. Organización del repositorio

```text
Red-Social-Pascualina/
│
├── README.md
│
├── Tarea6_Arquitectura_Hibrida_Pascualina_CORREGIDO.sql
│
├── Informe_Tecnico_Tarea6.docx
│
└── Evidencias/
    ├── 01_estructura_evento_iot.png
    ├── 02_particiones.png
    ├── 03_campos_jsonb.png
    ├── 04_indices_gin.png
    ├── 05_insercion_eventos.png
    ├── 06_consultas_jsonb.png
    ├── 07_consultas_join_agregaciones.png
    ├── 08_explain_analyze.png
    └── 09_verificaciones_finales.png
```

## 8. Requisitos para ejecutar el proyecto

1. Tener PostgreSQL instalado.
2. Contar con pgAdmin 4 o una herramienta compatible para ejecutar consultas SQL.
3. Crear o utilizar una base de datos llamada `red_social_pascualina`.
4. Revisar el script SQL antes de ejecutarlo y verificar qué operaciones ya fueron realizadas.

**Importante:** el archivo SQL entregado documenta la implementación y las consultas realizadas. Los bloques originales de inserción de estudiantes, perfiles, publicaciones y comentarios no están incluidos íntegramente porque no se recuperó su contenido exacto. No se debe ejecutar el archivo completo sobre una base de datos que ya contiene esos registros, para evitar duplicaciones o modificaciones no deseadas.

## 9. Integrantes

- Natalia Montoya
- Darwin Esteban Palacio

**Asignatura:** Bases de Datos I  
**Docente:** Oralia Cortes Grajales

## 10. Conclusión

El desarrollo de este proyecto permitió aplicar conceptos de bases de datos relacionales y no relacionales mediante PostgreSQL. La integración de JSONB, índices GIN y particionamiento permitió explorar alternativas para administrar información flexible y eventos IoT dentro de una misma arquitectura.

La implementación fortalece la capacidad de la Red Social Pascualina para gestionar diferentes tipos de información y constituye una base para futuras mejoras y ampliaciones del sistema.
