# Análisis de la Estrategia de Base de Datos

[Volver al Índice](./README.md)

## 1. Pregunta Original

Se propone usar una base de datos SQL y a la vez MongoDB/S3 para los materiales. ¿Cuál es el razonamiento para usar este enfoque híbrido? ¿Qué datos específicos irán en cada sistema?

## 2. Análisis del Enfoque Híbrido

El uso de una base de datos relacional (SQL) junto con una solución NoSQL (como MongoDB) y un almacenamiento de objetos (como S3) es un patrón común en arquitecturas modernas, conocido como **persistencia políglota**. Cada sistema se utiliza para lo que mejor sabe hacer.

### A. Base de Datos Relacional (SQL)

Ejemplos: PostgreSQL, MySQL.

*   **Datos a Almacenar:**
    *   **Usuarios:** Perfiles, credenciales (hasheadas), roles (docente, alumno, admin).
    *   **Metadatos de Materiales:** Título, materia, descripción, fecha de uso, ID del docente propietario.
    *   **Estructura de Clases/Grupos:** Relaciones entre docentes, alumnos y grupos.
    *   **Resultados de Actividades:** Puntuaciones de cuestionarios, registros de lectura (quién leyó qué y cuándo).
    *   **Relaciones y Lógica de Negocio:** Cualquier dato que sea altamente estructurado y relacional.

*   **Razonamiento:**
    *   **Consistencia (ACID):** Las transacciones SQL garantizan la integridad de los datos, crucial para registros de usuarios, notas y relaciones.
    *   **Consultas Complejas:** SQL es ideal para realizar consultas que involucren `JOIN`s entre múltiples tablas (ej. "mostrar el promedio de notas de todos los alumnos del grupo X en la materia Y").
    *   **Madurez y Fiabilidad:** Es una tecnología probada, robusta y bien entendida.

### B. Almacenamiento de Objetos (S3 o similar)

Ejemplos: AWS S3, Google Cloud Storage, MinIO (auto-alojado).

*   **Datos a Almacenar:**
    *   **Archivos PDF originales:** Los archivos subidos por los docentes.
    *   **Otros Binarios:** A futuro, vídeos, audios, o cualquier otro tipo de archivo estático.

*   **Razonamiento:**
    *   **Costo-Eficiencia:** Es la forma más barata y eficiente de almacenar grandes volúmenes de archivos binarios.
    *   **Escalabilidad:** Prácticamente ilimitado y diseñado para alta durabilidad y disponibilidad.
    *   **Rendimiento:** Sirve los archivos directamente a través de URLs (o CDN), liberando al servidor de aplicaciones de esta carga. **Nunca se deben almacenar archivos binarios en una base de datos SQL.**

### C. Base de Datos NoSQL (MongoDB)

*   **Datos a Almacenar:**
    *   **Documentos Flexibles:** Resúmenes generados, contenido de los cuestionarios (preguntas y opciones), logs de eventos, etc.
    *   **Datos sin Esquema Fijo:** Si en el futuro se permite contenido de terceros con estructuras variables, una base de datos de documentos es ideal.

*   **Razonamiento:**
    *   **Flexibilidad de Esquema:** MongoDB permite almacenar documentos JSON con estructuras que pueden variar, ideal para contenido como cuestionarios o logs que pueden evolucionar.
    *   **Escalabilidad Horizontal:** Las bases de datos NoSQL como MongoDB están diseñadas para escalar horizontalmente de manera más sencilla que las bases de datos SQL tradicionales.
    *   **Rendimiento en Casos de Uso Específicos:** Para lecturas/escrituras de documentos autocontenidos (como un perfil de usuario con todos sus atributos), puede ser más rápido que un `JOIN` complejo.

## 3. Flujo de Datos Propuesto

1.  **Subir Material:**
    *   El **docente** sube un archivo PDF.
    *   La **API (Go)** recibe la petición.
    *   Guarda el **archivo PDF en S3**.
    *   Guarda los **metadatos** (título, materia, referencia a la URL de S3) en la **base de datos SQL**.
    *   (Opcional) Si se genera un cuestionario, las preguntas/respuestas se guardan como un documento en **MongoDB**.

2.  **Consultar Material:**
    *   El **alumno** solicita un material.
    *   La **API** consulta la **base de datos SQL** para obtener los metadatos y la URL del archivo en S3.
    *   La aplicación cliente (KMP) descarga el archivo directamente desde **S3**.
    *   Si solicita el resumen, la API lo busca en **MongoDB**. Si no existe, lo genera, lo guarda en MongoDB y lo devuelve.

## 4. Conclusión

El enfoque híbrido es **altamente recomendado**. Separa las responsabilidades de almacenamiento de una manera lógica y escalable:

*   **SQL:** Para los datos transaccionales y relacionales (el "cerebro").
*   **S3:** Para los archivos binarios pesados (el "almacén").
*   **MongoDB:** Para datos semi-estructurados o documentos que necesitan flexibilidad (el "archivo de documentos").

Este modelo proporciona una base sólida y escalable para la plataforma EduGo.
