# Análisis del Rol de Administrador

[Volver al Índice](./README.md)

## 1. Pregunta Original

Se menciona un rol de "administrador" en la gestión de usuarios. ¿Qué permisos y responsabilidades específicas tendrá este rol en el MVP, más allá de lo que puede hacer un docente?

## 2. Propósito del Rol de Administrador en el MVP

En la Fase 1 (MVP), el rol de administrador no está pensado para ser una interfaz compleja para la gestión de un colegio (eso es Fase 2). Su propósito principal es **técnico y de soporte**, para garantizar el buen funcionamiento de la plataforma en sus primeras etapas.

No se recomienda crear una interfaz de usuario (UI) completa para el administrador en el MVP. Sus tareas se pueden realizar a través de scripts de base de datos o una herramienta de administración interna muy básica.

## 3. Responsabilidades y Permisos en el MVP

A continuación se detallan las capacidades del administrador, contrastadas con las de un docente.

| Capacidad | Docente | Administrador (MVP) | Justificación |
| :--- | :--- | :--- | :--- |
| **Gestión de Usuarios** | | | |
| Crear su propia cuenta | Sí (Registro) | Sí (Puede crear cualquier cuenta) | El admin puede necesitar crear cuentas de prueba o para docentes específicos. |
| Editar su propio perfil | Sí | Sí (Puede editar cualquier perfil) | Para corregir errores en nombres, emails, etc. |
| Cambiar su contraseña | Sí | Sí (Puede forzar reseteo) | Para ayudar a usuarios que han perdido el acceso a su email. |
| Eliminar su cuenta | No (Archivar) | Sí (Eliminación física) | El borrado de datos debe ser una acción controlada. |
| Asignar roles | No | **Sí (Capacidad clave)** | **Diferenciador principal:** El admin es el único que puede promover un usuario a "docente" o "admin". |
| | | | |
| **Gestión de Contenido** | | | |
| Subir/gestionar su material | Sí | No directamente | El admin no debe interferir con el contenido académico. |
| Ver material de otros | No | Sí (Solo para soporte) | Para depurar problemas si un material no se visualiza o procesa correctamente. |
| Eliminar material | De su propiedad | Sí (Cualquier material) | Para eliminar contenido inapropiado o que viole políticas. |
| | | | |
| **Gestión de Grupos** | | | |
| Crear/gestionar sus grupos | Sí | Sí (Ver/gestionar todos) | Para soporte, si un docente tiene problemas con un grupo. |
| Mover alumnos entre grupos | No | Sí | Para resolver casos excepcionales. |

## 4. Implementación en el MVP

1.  **Creación del Primer Administrador:** El primer usuario administrador se creará mediante un script de inicialización en la base de datos durante el despliegue inicial de la plataforma.
2.  **Asignación de Roles:** La capacidad más importante es `asignar roles`. Un usuario se registra normalmente (como "alumno" por defecto). Si es un docente, contacta al equipo. El administrador, a través de una simple consulta SQL (`UPDATE Users SET role = 'docente' WHERE email = '...'`), le concede los permisos.
3.  **Sin UI dedicada:** No se construirá un "Panel de Administrador" en el MVP. Esto ahorra un tiempo de desarrollo considerable que se puede enfocar en las funcionalidades principales para docentes y alumnos. Las tareas de administración se manejarán "detrás de cámaras".

## 5. Evolución a Fase 2

El "Panel de administrador de colegio" de la Fase 2 será la evolución natural de este rol. En esa fase, se construirá una UI completa donde los administradores de cada institución podrán:
*   Gestionar docentes y alumnos de su institución de forma masiva.
*   Ver estadísticas agregadas a nivel de colegio.
*   Configurar políticas para toda la institución.

Para el MVP, sin embargo, un rol de "superusuario" técnico es suficiente y adecuado.
