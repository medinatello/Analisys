# Índice de Documentos de Análisis - EduGo

Este directorio contiene una serie de documentos que profundizan en las decisiones técnicas y funcionales para el desarrollo de la plataforma educativa EduGo.

Cada documento analiza una pregunta específica derivada de la [Propuesta Inicial](../PropuestaInicial.md).

## Documentos de Análisis

1.  [**Análisis de Opciones para el Servicio de Resúmenes (NLP)**](./01_Analisis_Servicio_NLP.md)
    *   *Evalúa el uso de modelos de lenguaje externos (APIs) vs. modelos locales auto-alojados.*

2.  [**Análisis de la Estrategia de Base de Datos**](./02_Analisis_Base_de_Datos.md)
    *   *Justifica el uso de un enfoque híbrido (SQL + NoSQL + Almacenamiento de Objetos) y define qué datos van en cada sistema.*

3.  [**Análisis de la Estrategia de Kotlin Multiplatform (KMP)**](./03_Analisis_KMP.md)
    *   *Detalla cómo se usará KMP para maximizar el código compartido entre Mobile, Desktop y Web, permitiendo a la vez una UI adaptada a cada plataforma.*

4.  [**Análisis de la Gestión de Grupos y Clases**](./04_Analisis_Gestion_Grupos.md)
    *   *Define el modelo de datos y los flujos de usuario para la creación y administración de grupos, y la inscripción de alumnos.*

5.  [**Análisis del Rol de Administrador**](./05_Analisis_Rol_Administrador.md)
    *   *Especifica las responsabilidades y capacidades del rol de administrador en el MVP, enfocándolo en tareas de soporte técnico sin una UI dedicada.*

6.  [**Análisis de Requisitos de Acceso sin Conexión (Offline)**](./06_Analisis_Acceso_Offline.md)
    *   *Evalúa el impacto de implementar funcionalidades offline en el MVP y recomienda una estrategia por fases.*
