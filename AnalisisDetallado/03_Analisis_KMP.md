# Análisis de la Estrategia de Kotlin Multiplatform (KMP)

[Volver al Índice](./README.md)

## 1. Pregunta Original y Aclaraciones

La pregunta original era sobre la elección de KMP. Se ha aclarado la estrategia a seguir:
*   **Objetivo:** Maximizar el código compartido y, al mismo tiempo, ofrecer una experiencia de usuario (UI) adaptada a cada plataforma.
*   **Plataformas y Tecnologías:**
    *   **Mobile (Android & iOS):** Compose Multiplatform para una UI compartida.
    *   **Desktop (Windows, macOS, Linux):** Compose Multiplatform.
    *   **Web:** Compose for Web, utilizando WebAssembly (WASM).

## 2. Estructura del Proyecto KMP

Para lograr el objetivo, el proyecto se estructurará en módulos de la siguiente manera:

```
EduGoApp/
├── composeApp/                # Módulo principal de la aplicación
│   ├── src/
│   │   ├── commonMain/        # Lógica de negocio y UI 100% compartida
│   │   │   ├── kotlin/
│   │   │   │   ├── di/          # Inyección de dependencias (Koin, etc.)
│   │   │   │   ├── data/        # Repositorios, DTOs, API Client (Ktor)
│   │   │   │   ├── domain/      # Casos de uso, modelos de dominio
│   │   │   │   └── presentation/  # ViewModels/Presenters, UI compartida
│   │   │
│   │   ├── androidMain/       # Código específico de Android (ej. permisos, notificaciones)
│   │   ├── desktopMain/       # Código específico de Desktop (ej. integración con sistema de archivos)
│   │   ├── iosMain/           # Código específico de iOS (ej. integración con HealthKit, etc.)
│   │   └── wasmJsMain/        # Código específico para Web (WASM), (ej. manipulación del DOM, local storage)
│
├── iosApp/                    # Contenedor de la app de iOS (Xcode)
└── ...
```

## 3. Análisis por Plataforma

### Sesión 1: Mobile (Android & iOS)

*   **Tecnología:** Compose Multiplatform.
*   **Aprovechamiento de Código:**
    *   **UI:** Se puede compartir el 100% de la UI declarada con `composable`s. Los componentes visuales, la navegación y el estado se escribirán una sola vez.
    *   **Lógica de Negocio:** Toda la capa de datos (llamadas a API con Ktor), dominio y ViewModels será compartida.
*   **Toque Especial (Diferenciación):**
    *   Se pueden usar `expect/actual` para implementar patrones de UI específicos de cada plataforma si es necesario (ej. usar un `DatePicker` nativo).
    *   La adaptación a diferentes tamaños de pantalla (teléfonos vs. tabletas) se gestionará con los modificadores y layouts adaptativos de Compose.
    *   Se puede consultar la plataforma actual en tiempo de ejecución para renderizar componentes ligeramente diferentes.

### Sesión 2: Desktop (Windows, macOS, Linux)

*   **Tecnología:** Compose Multiplatform.
*   **Aprovechamiento de Código:**
    *   Reutilizará toda la lógica de negocio del módulo `commonMain`.
    *   Gran parte de la UI `composable` del móvil se puede reutilizar.
*   **Toque Especial (Diferenciación):**
    *   La UI debe adaptarse a un entorno de escritorio: uso de ratón y teclado, ventanas redimensionables, menús.
    *   Se crearán `composable`s específicos para el escritorio (ej. `DesktopMaterialTheme`, menús de ventana, diálogos de sistema de archivos).
    *   La navegación puede cambiar de un modelo de "pantallas" a uno de paneles o ventanas múltiples.
    *   Se creará un `main` separado en `desktopMain` para lanzar la aplicación de escritorio.

### Sesión 3: Web (Compose for Web con WASM)

*   **Tecnología:** Compose for Web (WASM). Es una tecnología **experimental/alfa**, lo que introduce un riesgo.
*   **Aprovechamiento de Código:**
    *   Reutilizará toda la lógica de negocio de `commonMain`.
    *   Se pueden reutilizar `composable`s básicos, pero la estructura general de la página y la navegación probablemente necesitarán ser específicas para la web.
*   **Toque Especial (Diferenciación):**
    *   **Evitar la "app estirada":** En lugar de reutilizar la UI móvil tal cual, se crearán `composable`s específicos en `wasmJsMain` que se adapten a un layout web (ej. barras laterales, cabeceras, pies de página).
    *   **Navegación:** La navegación debe integrarse con las URLs del navegador.
    *   **Interacción con el DOM:** Se usarán las APIs de `wasmJsMain` para interactuar con APIs de JavaScript y el DOM cuando sea necesario (ej. `localStorage`).
    *   **SEO:** El renderizado del lado del cliente con WASM puede tener implicaciones para el SEO. Esto debe ser evaluado.

## 4. Conclusión y Riesgos

*   **Máximo Aprovechamiento:** La lógica de negocio (`data`, `domain`, `presentation`) será compartida casi al 100% entre todas las plataformas.
*   **UI Adaptable:** La UI se compartirá en su mayoría, pero se crearán componentes y layouts específicos por plataforma (`androidMain`, `desktopMain`, `wasmJsMain`) para garantizar una experiencia nativa y evitar el síndrome de "app estirada".
*   **Riesgo Principal:** **Compose for Web (WASM) es alfa.** Su rendimiento, estabilidad, tamaño de descarga y compatibilidad con navegadores deben ser probados exhaustivamente en un prototipo técnico (PoC) antes de comprometerse completamente con esta tecnología para la web. Una alternativa más madura, aunque con menos código de UI compartido, sería usar una librería JS tradicional (React, Vue) para el frontend web, compartiendo solo la lógica de negocio de KMP a través de su compilación a JS.
