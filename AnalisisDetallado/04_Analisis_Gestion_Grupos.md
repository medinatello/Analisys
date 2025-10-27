# Análisis de la Gestión de Grupos y Clases

[Volver al Índice](./README.md)

## 1. Pregunta Original

El documento habla de "alumnos del grupo", pero no se detalla cómo se crean estos grupos. ¿Quién los administra? ¿Un docente puede tener varios grupos? ¿Los alumnos pueden pertenecer a más de uno?

## 2. Modelo de Datos Propuesto

Para dar soporte a la gestión de grupos, se propone el siguiente modelo relacional en la base de datos SQL.

**Tablas Principales:**

*   `Users`: (id, name, email, password_hash, role)
    *   `role` puede ser 'docente', 'alumno', 'admin'.
*   `Groups`: (id, name, description, owner_user_id)
    *   `owner_user_id` es una FK a `Users.id` (el docente que creó el grupo).
*   `GroupMembers`: (id, group_id, user_id, role_in_group)
    *   `group_id` es una FK a `Groups.id`.
    *   `user_id` es una FK a `Users.id`.
    *   `role_in_group` podría ser 'member' o 'co-teacher' (para futuros casos de uso).

**Tabla de Asignación de Material:**

*   `MaterialAssignments`: (id, material_id, group_id, assigned_at)
    *   `material_id` es una FK a la tabla de metadatos de materiales.
    *   `group_id` es una FK a `Groups.id`.

## 3. Análisis de Casos de Uso

### ¿Quién administra los grupos?

*   **Propuesta:** Los **docentes** son los propietarios y administradores de sus propios grupos. Pueden crear, editar y archivar/eliminar sus grupos.
*   El **administrador** de la institución (rol de Fase 2) podría tener la capacidad de ver todos los grupos, asignar docentes y mover alumnos entre grupos.

### ¿Cómo se añaden alumnos a un grupo?

Se proponen dos mecanismos para el MVP, que pueden coexistir:

1.  **Invitación por Código (Recomendado para MVP):**
    *   Al crear un grupo, el sistema genera un código único de invitación (ej. "XJ4-K8P").
    *   El docente comparte este código con sus alumnos.
    *   El alumno, en la app, tiene una opción de "Unirse a un grupo" donde introduce el código.
    *   El sistema lo añade automáticamente a la tabla `GroupMembers`.
    *   **Ventaja:** Simple, auto-gestionado y no requiere que el docente introduzca datos de los alumnos.

2.  **Añadir por Email (Manual):**
    *   El docente tiene una opción para invitar alumnos introduciendo sus direcciones de correo electrónico.
    *   El sistema envía una invitación por email. Si el usuario no existe, se le pide que se registre.
    *   **Ventaja:** Más controlado.
    *   **Desventaja:** Más trabajo para el docente.

### ¿Un docente puede tener varios grupos?

*   **Sí.** El modelo `Groups` tiene una relación de uno a muchos con el `Users` (docente). Un docente puede crear y gestionar tantos grupos como necesite (ej. "Matemáticas 101", "Física 202").

### ¿Los alumnos pueden pertenecer a más de uno?

*   **Sí.** La tabla `GroupMembers` es una tabla de unión (muchos a muchos) entre `Users` y `Groups`. Esto permite que un alumno esté inscrito en el grupo de Matemáticas de un docente y en el de Historia de otro.

## 4. Flujo de Interfaz de Usuario (UI)

*   **Docente:**
    *   Tendrá una pantalla de "Mis Grupos".
    *   Botón para "Crear Nuevo Grupo" (pide nombre y descripción).
    *   Dentro de cada grupo, verá una lista de miembros y el código de invitación.
    *   Al subir material, podrá seleccionar a qué grupo(s) asignarlo.
*   **Alumno:**
    *   Tendrá una pantalla de "Mis Clases".
    *   Botón para "Unirme a una Clase" (pide código).
    *   El feed principal mostrará el material asignado de todos los grupos a los que pertenece, ordenado por fecha.

## 5. Conclusión

El modelo propuesto es flexible y escalable. Para el MVP, se recomienda implementar la **gestión de grupos por parte de los docentes** y el mecanismo de **unión a través de un código de invitación** por su simplicidad y bajo esfuerzo de implementación.
