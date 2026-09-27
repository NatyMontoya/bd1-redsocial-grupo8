# Red Social Pascualina

## Tarea 2 – Modelo lógico, normalización y diccionario de datos

### Integrantes

- Integrante 1: Natalia Montoya Echavarría
- Integrante 2: Darwin Esteban Palacio Durán


---

## Descripción del proyecto

La **Red Social Pascualina** es una propuesta de base de datos para una plataforma de interacción entre estudiantes.

El sistema busca facilitar la comunicación y colaboración entre los integrantes de la comunidad educativa, permitiendo compartir conocimientos, encontrar compañeros con intereses similares, crear grupos de estudio, participar en eventos y establecer procesos de mentoría.

La base de datos está diseñada para almacenar y relacionar la información necesaria para soportar estas funcionalidades.

---

## Objetivo

Diseñar un modelo lógico de base de datos para la Red Social Pascualina, aplicando el proceso de normalización mediante las formas normales **1FN, 2FN y 3FN**, y documentando los elementos del modelo mediante un diccionario de datos.

---

## Funcionalidades principales

La base de datos soporta las siguientes funcionalidades:

- Crear y administrar perfiles de estudiantes.
- Registrar intereses y habilidades.
- Conectar estudiantes entre sí.
- Publicar contenido.
- Realizar comentarios y reacciones.
- Crear y participar en grupos.
- Crear y asistir a eventos.
- Establecer procesos de mentoría entre estudiantes.

---

## Modelo lógico

El modelo lógico está compuesto por las siguientes tablas:

1. `ESTUDIANTE`
2. `PERFIL`
3. `INTERES`
4. `ESTUDIANTE_INTERES`
5. `HABILIDAD`
6. `ESTUDIANTE_HABILIDAD`
7. `CONEXION`
8. `PUBLICACION`
9. `COMENTARIO`
10. `REACCION`
11. `GRUPO`
12. `MIEMBRO_GRUPO`
13. `EVENTO`
14. `ASISTENCIA_EVENTO`
15. `MENTORIA`

---

## Normalización

El diseño de la base de datos aplica las tres primeras formas normales:

### Primera Forma Normal – 1FN

Se garantiza que los atributos contengan valores atómicos y que no existan grupos repetitivos.

Por ejemplo, los intereses de un estudiante no se almacenan como una lista dentro de un solo campo. Se utilizan las tablas `INTERES` y `ESTUDIANTE_INTERES`.

### Segunda Forma Normal – 2FN

Se eliminan las dependencias parciales en las relaciones que utilizan claves primarias compuestas.

Esto se aplica principalmente en:

- `ESTUDIANTE_INTERES`
- `ESTUDIANTE_HABILIDAD`
- `MIEMBRO_GRUPO`
- `ASISTENCIA_EVENTO`

Los atributos propios de estas relaciones dependen de la totalidad de la clave primaria.

### Tercera Forma Normal – 3FN

Se eliminan las dependencias transitivas, manteniendo cada dato en la tabla correspondiente a la entidad que representa.

De esta manera se reduce la redundancia y se facilita el mantenimiento de la información.

---

## Diccionario de datos

El diccionario de datos documenta los atributos de cada tabla, incluyendo:

- Nombre del campo.
- Tipo de dato.
- Clave primaria (PK).
- Clave foránea (FK).
- Restricciones de unicidad.
- Posibilidad de valores nulos.
- Descripción del atributo.

El diccionario completo se encuentra en el informe de la Tarea 2.

---

