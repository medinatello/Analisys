# SPEC-OFFLINE: Persistencia Local y Modo Offline - App Apple EduGo

**Versión**: 1.0
**Fecha**: 1 de Diciembre, 2025
**Plataforma**: iOS 18.0+, macOS 15.0+, visionOS 2.0+
**Swift**: 6.0
**Estado**: 📝 ESPECIFICACIÓN - Pendiente de Implementación

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Objetivos](#2-objetivos)
3. [Alcance](#3-alcance)
4. [Arquitectura Técnica](#4-arquitectura-técnica)
5. [Modelos SwiftData](#5-modelos-swiftdata)
6. [Servicios Requeridos](#6-servicios-requeridos)
7. [Flujos de Datos](#7-flujos-de-datos)
8. [UI/UX para Offline](#8-uiux-para-offline)
9. [Manejo de Errores](#9-manejo-de-errores)
10. [Consideraciones de Almacenamiento](#10-consideraciones-de-almacenamiento)
11. [Testing](#11-testing)
12. [Plan de Implementación](#12-plan-de-implementación)

---

## 1. Resumen Ejecutivo

### Contexto Actual

La app Apple de EduGo actualmente tiene:
- ✅ **SwiftData** para cache local básico
- ✅ **NetworkSyncCoordinator** para sincronización automática
- ✅ **OfflineQueue** con persistencia en UserDefaults
- ✅ **ResponseCache** para respuestas HTTP
- ✅ **NetworkState** observable con indicadores UI de conectividad
- ✅ **ConflictResolver** para resolución de conflictos HTTP 409

### Necesidad

Los usuarios (estudiantes) requieren:
1. **Consultar materiales educativos sin conexión** durante viajes o en zonas sin cobertura
2. **Descargar PDFs** para lectura offline persistente
3. **Continuar estudiando** sin interrupciones por problemas de red
4. **Sincronizar progreso** automáticamente cuando vuelva la conexión
5. **Realizar quizzes offline** y enviarlos cuando haya red

### Solución Propuesta

Implementar un sistema de persistencia local completo que permita:
- **Cache inteligente** de lista de materiales con metadatos
- **Descarga bajo demanda** de archivos PDF con gestión de almacenamiento
- **Persistencia de progreso** de lectura con sincronización diferida
- **Queue de operaciones pendientes** para quiz attempts y actualizaciones

---

## 2. Objetivos

### Objetivos Principales

| # | Objetivo | Métrica de Éxito |
|---|----------|------------------|
| 1 | Permitir consulta de materiales sin conexión | 100% de materiales descargados accesibles offline |
| 2 | Descargar PDFs para lectura offline | Download manager con progreso visual y gestión de errores |
| 3 | Persistir progreso de lectura localmente | Progreso guardado cada 5 segundos, sin pérdida de datos |
| 4 | Sincronizar cuando vuelva conexión | Auto-sync al detectar red + opción manual |
| 5 | Realizar quizzes offline | Intentos guardados en queue y enviados al reconectar |

### Objetivos Secundarios

- Optimizar uso de almacenamiento con políticas de limpieza
- Proveer feedback visual claro del estado offline/online
- Permitir gestión manual de contenido descargado
- Implementar resolución de conflictos para cambios concurrentes

---

## 3. Alcance

### ✅ En Scope (Primera Fase - Este Spec)

#### Cache y Persistencia
- [x] Cache de lista de materiales educativos con metadatos
- [x] Persistencia de datos de usuario (perfil, preferencias)
- [x] Almacenamiento de progreso de lectura (páginas, tiempo)
- [x] Queue de intentos de quiz pendientes de envío

#### Descarga de Archivos
- [x] Download manager para archivos PDF
- [x] Almacenamiento en sistema de archivos local (FileManager)
- [x] Control de progreso de descarga con indicadores visuales
- [x] Gestión de errores de descarga (retry, cancelación)

#### Sincronización Básica
- [x] Detección automática de conectividad (ya existe: NetworkMonitor)
- [x] Auto-sync al reconectar (ya existe: NetworkSyncCoordinator)
- [x] Sincronización manual forzada por usuario
- [x] Indicadores UI de estado de sync (ya existe: SyncIndicator)

#### Gestión de Almacenamiento
- [x] Visualización de espacio usado por descargas
- [x] Eliminación manual de PDFs descargados
- [x] Limpieza automática de cache antiguo (política por tiempo)

### ⏳ Fuera de Scope (Segunda Fase - Ver SPEC-SYNC.md)

#### Sincronización Avanzada
- [ ] Sincronización bidireccional completa con merge
- [ ] Resolución de conflictos complejos con UI manual
- [ ] Diff y patch de cambios incrementales
- [ ] Sincronización delta (solo cambios)

#### Contenido Multimedia
- [ ] Descarga de videos para offline
- [ ] Streaming adaptativo con cache
- [ ] Imágenes optimizadas (WebP, AVIF)

#### Colaboración Offline
- [ ] Anotaciones offline en PDFs
- [ ] Comentarios pendientes de sincronización
- [ ] Compartir materiales offline vía AirDrop

---

## 4. Arquitectura Técnica

### 4.1 Capas de la Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  SwiftUI Views + ViewModels (@Observable)               │
│  - MaterialListView, MaterialDetailView                 │
│  - DownloadButton, OfflineBadge, StorageManager         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                         │
│  Use Cases (Clean Architecture)                         │
│  - DownloadMaterialUseCase                              │
│  - SyncProgressUseCase                                  │
│  - SubmitQuizOfflineUseCase                             │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  Repositories + Data Sources                            │
│  - MaterialRepository (Remote + Local)                  │
│  - ProgressRepository (Remote + Local)                  │
│  - QuizRepository (Remote + Local)                      │
└────┬────────────────────────────┬───────────────────────┘
     │                            │
     ↓                            ↓
┌────────────────┐      ┌──────────────────────────┐
│  REMOTE        │      │  LOCAL                   │
│  APIClient     │      │  SwiftData + FileManager │
│  (ya existe)   │      │  (a implementar)         │
└────────────────┘      └──────────────────────────┘
```

### 4.2 Componentes Existentes (Reutilizar)

| Componente | Ubicación | Uso en Offline |
|------------|-----------|----------------|
| **NetworkMonitor** | `/Data/Network/NetworkMonitor.swift` | Detectar pérdida/recuperación de red |
| **NetworkSyncCoordinator** | `/Data/Network/NetworkSyncCoordinator.swift` | Auto-sync al reconectar |
| **OfflineQueue** | `/Data/Network/OfflineQueue.swift` | Queue de requests pendientes |
| **ResponseCache** | `/Data/Network/ResponseCache.swift` | Cache de respuestas HTTP |
| **NetworkState** | `/Presentation/State/NetworkState.swift` | Estado observable de red |
| **SyncIndicator** | `/Presentation/Components/SyncIndicator.swift` | Indicador visual de sync |
| **ConflictResolver** | `/Domain/Models/Sync/ConflictResolution.swift` | Resolver conflictos HTTP 409 |

### 4.3 Componentes Nuevos (A Implementar)

| Componente | Responsabilidad | Prioridad |
|------------|-----------------|-----------|
| **DownloadManager** | Descargar archivos con progreso | 🔴 P0 |
| **LocalMaterialDataSource** | Persistir materiales en SwiftData | 🔴 P0 |
| **LocalProgressDataSource** | Persistir progreso de lectura | 🔴 P0 |
| **LocalQuizDataSource** | Persistir intentos de quiz | 🟡 P1 |
| **FileStorageService** | Gestionar archivos en FileManager | 🔴 P0 |
| **StorageMonitor** | Monitorear espacio disponible | 🟡 P1 |
| **CacheCleaner** | Limpiar cache antiguo | 🟢 P2 |

---

## 5. Modelos SwiftData

### 5.1 Modelo: CachedMaterial

**Propósito**: Persistir metadatos de materiales educativos para acceso offline.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Storage/SwiftData/CachedMaterial.swift`

```swift
import Foundation
import SwiftData

/// Material educativo cacheado localmente
///
/// Almacena metadatos del material (título, descripción, autor, etc.)
/// sin incluir el contenido del PDF (almacenado en FileManager).
@Model
final class CachedMaterial {
    // MARK: - Primary Key
    
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - Metadata del Material
    
    var title: String
    var materialDescription: String? // "description" es palabra reservada
    var subjectName: String
    var authorName: String
    var schoolName: String
    
    // MARK: - Estado del Material
    
    var status: String // "draft", "published", "archived"
    var publishedAt: Date?
    
    // MARK: - Resumen y Quiz
    
    var hasSummary: Bool
    var summaryStatus: String? // "pending", "completed", "failed"
    var hasQuiz: Bool
    var totalQuestions: Int?
    
    // MARK: - Download State
    
    var isDownloadedLocally: Bool
    var localFileURL: String? // Path relativo en FileManager
    var downloadedAt: Date?
    var fileSize: Int64? // Bytes
    var fileHash: String? // SHA-256 para verificar integridad
    
    // MARK: - Sync State
    
    var lastSyncedAt: Date?
    var needsSync: Bool // true si hay cambios locales pendientes
    
    // MARK: - Timestamps
    
    var createdAt: Date
    var updatedAt: Date
    var lastAccessedAt: Date? // Última vez que se abrió offline
    
    // MARK: - Extensibilidad
    
    var metadata: Data? // JSONB serializado para campos adicionales
    
    // MARK: - Initialization
    
    init(
        id: UUID,
        title: String,
        materialDescription: String? = nil,
        subjectName: String,
        authorName: String,
        schoolName: String,
        status: String = "published",
        publishedAt: Date? = nil,
        hasSummary: Bool = false,
        summaryStatus: String? = nil,
        hasQuiz: Bool = false,
        totalQuestions: Int? = nil,
        isDownloadedLocally: Bool = false,
        localFileURL: String? = nil,
        downloadedAt: Date? = nil,
        fileSize: Int64? = nil,
        fileHash: String? = nil,
        lastSyncedAt: Date? = nil,
        needsSync: Bool = false
    ) {
        self.id = id
        self.title = title
        self.materialDescription = materialDescription
        self.subjectName = subjectName
        self.authorName = authorName
        self.schoolName = schoolName
        self.status = status
        self.publishedAt = publishedAt
        self.hasSummary = hasSummary
        self.summaryStatus = summaryStatus
        self.hasQuiz = hasQuiz
        self.totalQuestions = totalQuestions
        self.isDownloadedLocally = isDownloadedLocally
        self.localFileURL = localFileURL
        self.downloadedAt = downloadedAt
        self.fileSize = fileSize
        self.fileHash = fileHash
        self.lastSyncedAt = lastSyncedAt
        self.needsSync = needsSync
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Indica si el material está disponible para lectura offline
    var isAvailableOffline: Bool {
        isDownloadedLocally && localFileURL != nil
    }
    
    /// Tamaño del archivo en formato legible (ej: "2.5 MB")
    var fileSizeFormatted: String? {
        guard let size = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Extensions

extension CachedMaterial {
    /// Marca el material como descargado localmente
    func markAsDownloaded(fileURL: String, fileSize: Int64, fileHash: String) {
        self.isDownloadedLocally = true
        self.localFileURL = fileURL
        self.downloadedAt = Date()
        self.fileSize = fileSize
        self.fileHash = fileHash
        self.updatedAt = Date()
    }
    
    /// Marca el material como eliminado localmente
    func markAsDeleted() {
        self.isDownloadedLocally = false
        self.localFileURL = nil
        self.downloadedAt = nil
        self.updatedAt = Date()
    }
    
    /// Actualiza la fecha de último acceso (para limpieza de cache)
    func recordAccess() {
        self.lastAccessedAt = Date()
    }
}
```

---

### 5.2 Modelo: DownloadTask

**Propósito**: Tracking de descarga de archivos PDF con progreso.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Storage/SwiftData/DownloadTask.swift`

```swift
import Foundation
import SwiftData

/// Tarea de descarga de archivo PDF
///
/// Persistir el estado de descargas en progreso, pausadas o fallidas
/// para permitir resume, retry y cancelación.
@Model
final class DownloadTask {
    // MARK: - Primary Key
    
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - Material Reference
    
    var materialId: UUID // FK a CachedMaterial
    var materialTitle: String // Denormalizado para UI
    
    // MARK: - Download State
    
    var state: String // "pending", "downloading", "paused", "completed", "failed"
    var progress: Double // 0.0 a 1.0
    var bytesDownloaded: Int64
    var totalBytes: Int64
    
    // MARK: - Remote Source
    
    var sourceURL: String // URL del PDF en backend/S3
    var destinationPath: String // Path local donde guardar
    
    // MARK: - Error Handling
    
    var errorMessage: String?
    var retryCount: Int
    var maxRetries: Int
    
    // MARK: - Timestamps
    
    var createdAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var lastUpdatedAt: Date
    
    // MARK: - Initialization
    
    init(
        materialId: UUID,
        materialTitle: String,
        sourceURL: String,
        destinationPath: String,
        totalBytes: Int64 = 0,
        maxRetries: Int = 3
    ) {
        self.id = UUID()
        self.materialId = materialId
        self.materialTitle = materialTitle
        self.sourceURL = sourceURL
        self.destinationPath = destinationPath
        self.state = "pending"
        self.progress = 0.0
        self.bytesDownloaded = 0
        self.totalBytes = totalBytes
        self.retryCount = 0
        self.maxRetries = maxRetries
        self.createdAt = Date()
        self.lastUpdatedAt = Date()
    }
    
    // MARK: - State Management
    
    func start() {
        guard state == "pending" || state == "paused" else { return }
        state = "downloading"
        startedAt = Date()
        lastUpdatedAt = Date()
    }
    
    func updateProgress(bytesDownloaded: Int64, totalBytes: Int64) {
        self.bytesDownloaded = bytesDownloaded
        self.totalBytes = totalBytes
        self.progress = totalBytes > 0 ? Double(bytesDownloaded) / Double(totalBytes) : 0.0
        self.lastUpdatedAt = Date()
    }
    
    func pause() {
        guard state == "downloading" else { return }
        state = "paused"
        lastUpdatedAt = Date()
    }
    
    func complete() {
        state = "completed"
        progress = 1.0
        completedAt = Date()
        lastUpdatedAt = Date()
    }
    
    func fail(error: String) {
        state = "failed"
        errorMessage = error
        retryCount += 1
        lastUpdatedAt = Date()
    }
    
    var canRetry: Bool {
        state == "failed" && retryCount < maxRetries
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}
```

---

### 5.3 Modelo: PendingProgress

**Propósito**: Progreso de lectura pendiente de sincronización con backend.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Storage/SwiftData/PendingProgress.swift`

```swift
import Foundation
import SwiftData

/// Progreso de lectura de material pendiente de sincronización
///
/// Guarda el progreso del estudiante localmente y lo marca para
/// sincronización cuando haya conexión.
@Model
final class PendingProgress {
    // MARK: - Primary Key
    
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - References
    
    var materialId: UUID
    var studentId: UUID
    
    // MARK: - Progress Data
    
    var progressPercentage: Double // 0.0 a 100.0
    var timeSpentSeconds: Int // Tiempo total de lectura
    var lastPage: Int // Última página leída
    var totalPages: Int
    
    // MARK: - Sync State
    
    var needsSync: Bool
    var syncAttempts: Int
    var lastSyncAttemptAt: Date?
    var lastSyncError: String?
    
    // MARK: - Timestamps
    
    var createdAt: Date
    var updatedAt: Date
    var lastAccessAt: Date // Última vez que se actualizó el progreso
    
    // MARK: - Initialization
    
    init(
        materialId: UUID,
        studentId: UUID,
        progressPercentage: Double = 0.0,
        timeSpentSeconds: Int = 0,
        lastPage: Int = 0,
        totalPages: Int = 0
    ) {
        self.id = UUID()
        self.materialId = materialId
        self.studentId = studentId
        self.progressPercentage = progressPercentage
        self.timeSpentSeconds = timeSpentSeconds
        self.lastPage = lastPage
        self.totalPages = totalPages
        self.needsSync = true
        self.syncAttempts = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastAccessAt = Date()
    }
    
    // MARK: - Update Methods
    
    func updateProgress(page: Int, totalPages: Int, timeSpent: Int) {
        self.lastPage = page
        self.totalPages = totalPages
        self.timeSpentSeconds = timeSpent
        self.progressPercentage = totalPages > 0 
            ? (Double(page) / Double(totalPages)) * 100.0 
            : 0.0
        self.needsSync = true
        self.updatedAt = Date()
        self.lastAccessAt = Date()
    }
    
    func markAsSynced() {
        self.needsSync = false
        self.syncAttempts = 0
        self.lastSyncError = nil
        self.updatedAt = Date()
    }
    
    func recordSyncFailure(error: String) {
        self.syncAttempts += 1
        self.lastSyncAttemptAt = Date()
        self.lastSyncError = error
        self.updatedAt = Date()
    }
    
    var shouldRetrySync: Bool {
        needsSync && syncAttempts < 5
    }
}
```

---

### 5.4 Modelo: PendingQuizAttempt

**Propósito**: Intento de quiz offline pendiente de envío al backend.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Storage/SwiftData/PendingQuizAttempt.swift`

```swift
import Foundation
import SwiftData

/// Intento de quiz realizado offline pendiente de envío
///
/// Almacena las respuestas del estudiante a un quiz cuando no hay conexión,
/// para enviarlas al backend cuando se recupere la red.
@Model
final class PendingQuizAttempt {
    // MARK: - Primary Key
    
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - References
    
    var materialId: UUID
    var assessmentId: UUID // ID del quiz en MongoDB
    var studentId: UUID
    
    // MARK: - Attempt Data
    
    var answers: Data // JSON serializado de [{ questionId: String, answer: String }]
    var startedAt: Date
    var completedAt: Date
    var durationSeconds: Int
    
    // MARK: - Client-Side Scoring (Opcional)
    
    var correctAnswersCount: Int?
    var totalQuestions: Int?
    var estimatedScore: Double? // Score calculado localmente (provisional)
    
    // MARK: - Sync State
    
    var needsSync: Bool
    var syncAttempts: Int
    var lastSyncAttemptAt: Date?
    var lastSyncError: String?
    
    // MARK: - Server Response (Post-Sync)
    
    var serverAttemptId: UUID? // ID asignado por el backend después de sync
    var serverScore: Double? // Score definitivo del backend
    var synced: Bool
    
    // MARK: - Timestamps
    
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Initialization
    
    init(
        materialId: UUID,
        assessmentId: UUID,
        studentId: UUID,
        answers: Data,
        startedAt: Date,
        completedAt: Date,
        durationSeconds: Int,
        correctAnswersCount: Int? = nil,
        totalQuestions: Int? = nil,
        estimatedScore: Double? = nil
    ) {
        self.id = UUID()
        self.materialId = materialId
        self.assessmentId = assessmentId
        self.studentId = studentId
        self.answers = answers
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.correctAnswersCount = correctAnswersCount
        self.totalQuestions = totalQuestions
        self.estimatedScore = estimatedScore
        self.needsSync = true
        self.syncAttempts = 0
        self.synced = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Sync Methods
    
    func markAsSynced(serverAttemptId: UUID, serverScore: Double) {
        self.synced = true
        self.needsSync = false
        self.serverAttemptId = serverAttemptId
        self.serverScore = serverScore
        self.syncAttempts = 0
        self.lastSyncError = nil
        self.updatedAt = Date()
    }
    
    func recordSyncFailure(error: String) {
        self.syncAttempts += 1
        self.lastSyncAttemptAt = Date()
        self.lastSyncError = error
        self.updatedAt = Date()
    }
    
    var shouldRetrySync: Bool {
        !synced && needsSync && syncAttempts < 5
    }
    
    // MARK: - Decoding Helpers
    
    func decodedAnswers() -> [[String: String]]? {
        try? JSONDecoder().decode([[String: String]].self, from: answers)
    }
}
```

---

### 5.5 Actualizar ModelContainer

**Ubicación**: `/apple-app/apple_appApp.swift` o donde se configure el ModelContainer.

```swift
import SwiftData

// Configurar ModelContainer con todos los modelos
let schema = Schema([
    // Modelos existentes
    CachedHTTPResponse.self,
    CachedFeatureFlag.self,
    CachedUser.self,
    AppSettings.self,
    SyncQueueItem.self,
    
    // 🆕 Nuevos modelos offline
    CachedMaterial.self,
    DownloadTask.self,
    PendingProgress.self,
    PendingQuizAttempt.self
])

let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false, // Persistir en disco
    cloudKitDatabase: .none // Sin iCloud sync (por ahora)
)

let modelContainer = try ModelContainer(
    for: schema,
    configurations: [modelConfiguration]
)
```

---

## 6. Servicios Requeridos

### 6.1 DownloadManager

**Propósito**: Gestionar descargas de archivos PDF con progreso, pausa/resume, retry.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Services/DownloadManager.swift`

**Responsabilidades**:
- Iniciar descarga de PDF desde URL remota
- Reportar progreso de descarga (bytes descargados, porcentaje)
- Pausar/reanudar descargas
- Reintentar descargas fallidas
- Persistir estado en DownloadTask (SwiftData)
- Notificar a UI cuando descarga completa/falla

**APIs públicas**:
```swift
actor DownloadManager {
    func startDownload(materialId: UUID, sourceURL: URL) async throws -> DownloadTask
    func pauseDownload(taskId: UUID) async throws
    func resumeDownload(taskId: UUID) async throws
    func cancelDownload(taskId: UUID) async throws
    func retryDownload(taskId: UUID) async throws
    func downloadProgress(taskId: UUID) -> AsyncStream<Double>
    func activeDownloads() async -> [DownloadTask]
}
```

**Tecnologías**:
- `URLSession` con `URLSessionDownloadTask`
- `URLSessionDelegate` para tracking de progreso
- SwiftData para persistir `DownloadTask`
- `AsyncStream` para progreso observable

---

### 6.2 FileStorageService

**Propósito**: Gestionar almacenamiento de archivos descargados en FileManager.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Services/FileStorageService.swift`

**Responsabilidades**:
- Guardar archivo descargado en directorio local (`Application Support/Downloads/`)
- Calcular hash SHA-256 del archivo para verificar integridad
- Obtener URL local del archivo para PDFKit
- Eliminar archivo del disco
- Calcular espacio total usado por descargas

**APIs públicas**:
```swift
actor FileStorageService {
    func saveFile(from tempURL: URL, for materialId: UUID) async throws -> URL
    func getFileURL(for materialId: UUID) async -> URL?
    func deleteFile(for materialId: UUID) async throws
    func calculateFileHash(at url: URL) async throws -> String
    func totalStorageUsed() async throws -> Int64
    func availableDiskSpace() async throws -> Int64
}
```

**Estructura de Directorios**:
```
/Application Support/
  └── EduGo/
      ├── Downloads/
      │   ├── {material-uuid-1}.pdf
      │   ├── {material-uuid-2}.pdf
      │   └── {material-uuid-3}.pdf
      ├── Cache/
      │   └── (cache temporal de imágenes, etc.)
      └── Database/
          └── default.store (SwiftData)
```

---

### 6.3 OfflineSyncService

**Propósito**: Sincronizar datos locales con backend cuando hay conexión.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Services/OfflineSyncService.swift`

**Responsabilidades**:
- Sincronizar progreso de lectura pendiente (`PendingProgress`)
- Enviar intentos de quiz pendientes (`PendingQuizAttempt`)
- Actualizar cache de materiales con cambios del servidor
- Resolver conflictos si hay cambios concurrentes
- Reportar estado de sincronización a UI

**APIs públicas**:
```swift
actor OfflineSyncService {
    func syncAllPendingData() async throws
    func syncProgress() async throws -> Int // Retorna cantidad sincronizada
    func syncQuizAttempts() async throws -> Int
    func refreshMaterialCache() async throws
    func pendingSyncCount() async -> Int
}
```

**Integración con existentes**:
- Usa `NetworkSyncCoordinator` para auto-sync al reconectar
- Usa `OfflineQueue` para requests HTTP pendientes
- Usa `ConflictResolver` para manejar HTTP 409

---

### 6.4 StorageMonitor

**Propósito**: Monitorear espacio en disco y alertar cuando se está llenando.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Services/StorageMonitor.swift`

**Responsabilidades**:
- Monitorear espacio disponible en disco
- Alertar cuando espacio < 500 MB
- Sugerir materiales para eliminar (basado en `lastAccessedAt`)
- Proveer métricas para UI de gestión de almacenamiento

**APIs públicas**:
```swift
actor StorageMonitor {
    func availableSpace() async throws -> Int64
    func usedSpaceByDownloads() async throws -> Int64
    func shouldWarnLowSpace() async throws -> Bool
    func oldestMaterials(limit: Int) async -> [CachedMaterial]
}
```

---

### 6.5 CacheCleaner

**Propósito**: Limpiar automáticamente cache antiguo según políticas.

**Ubicación**: `/Packages/EduGoDataLayer/Sources/EduGoDataLayer/Services/CacheCleaner.swift`

**Responsabilidades**:
- Eliminar materiales no accedidos en 30+ días
- Limpiar respuestas HTTP cacheadas antiguas
- Eliminar descargas fallidas > 7 días
- Ejecutar limpieza en background al iniciar app

**APIs públicas**:
```swift
actor CacheCleaner {
    func cleanOldMaterials(olderThan days: Int) async throws -> Int
    func cleanFailedDownloads() async throws -> Int
    func cleanHTTPCache(olderThan days: Int) async throws
    func performFullCleanup() async throws
}
```

**Políticas de Limpieza**:
| Tipo de Dato | Política | Días |
|--------------|----------|------|
| Materiales no accedidos | Eliminar archivo PDF local | 30 |
| Descargas fallidas | Eliminar DownloadTask | 7 |
| HTTP Cache | Eliminar CachedHTTPResponse | 14 |
| Quiz attempts synced | Eliminar PendingQuizAttempt | 7 |

---

## 7. Flujos de Datos

### 7.1 Flujo: Descarga de Material PDF

```
Usuario                  MaterialListView      DownloadManager      FileStorageService     SwiftData
   │                            │                      │                     │                  │
   │  1. Tap "Descargar"        │                      │                     │                  │
   ├───────────────────────────>│                      │                     │                  │
   │                            │                      │                     │                  │
   │                            │  2. startDownload()  │                     │                  │
   │                            ├─────────────────────>│                     │                  │
   │                            │                      │                     │                  │
   │                            │                      │  3. Crear DownloadTask                 │
   │                            │                      ├────────────────────────────────────────>│
   │                            │                      │                     │                  │
   │                            │                      │  4. URLSession.download()              │
   │                            │                      ├──────────────┐      │                  │
   │                            │                      │  Descargando │      │                  │
   │                            │                      │              │      │                  │
   │                            │  5. Progress updates │              │      │                  │
   │                            │  (AsyncStream)       │              │      │                  │
   │  6. Mostrar barra progreso │<─────────────────────┤<─────────────┘      │                  │
   │<───────────────────────────┤                      │                     │                  │
   │   "Descargando 45%..."     │                      │                     │                  │
   │                            │                      │                     │                  │
   │                            │                      │  7. Download complete                  │
   │                            │                      │  (tempURL)          │                  │
   │                            │                      │                     │                  │
   │                            │                      │  8. saveFile()      │                  │
   │                            │                      ├────────────────────>│                  │
   │                            │                      │                     │                  │
   │                            │                      │                     │  9. Move file   │
   │                            │                      │                     ├──────────────┐   │
   │                            │                      │                     │  Calculate   │   │
   │                            │                      │                     │  SHA-256     │   │
   │                            │                      │                     │<─────────────┘   │
   │                            │                      │                     │                  │
   │                            │                      │  10. Return localURL│                  │
   │                            │                      │<────────────────────┤                  │
   │                            │                      │                     │                  │
   │                            │                      │  11. Update CachedMaterial             │
   │                            │                      ├────────────────────────────────────────>│
   │                            │                      │  markAsDownloaded() │                  │
   │                            │                      │                     │                  │
   │  12. "Descarga completa"   │                      │                     │                  │
   │  Badge "Disponible offline"│                      │                     │                  │
   │<───────────────────────────┤                      │                     │                  │
```

**Pasos Detallados**:
1. Usuario tap en botón "Descargar para offline"
2. `DownloadManager` crea `DownloadTask` y lo persiste en SwiftData
3. Inicia `URLSession.downloadTask` con la URL del PDF
4. Reporta progreso via `AsyncStream<Double>` cada 500ms
5. UI actualiza `ProgressView` con porcentaje
6. Al completar, `URLSession` retorna `tempURL` del archivo descargado
7. `FileStorageService.saveFile()` mueve archivo a directorio permanente
8. Calcula SHA-256 hash para verificar integridad
9. Actualiza `CachedMaterial.markAsDownloaded()` con URL local y hash
10. UI muestra badge "Disponible offline" en el material

---

### 7.2 Flujo: Actualización de Progreso de Lectura (Offline)

```
PDFReaderView        ProgressTracker      LocalProgressDataSource     SwiftData      OfflineQueue
      │                     │                        │                    │                │
      │  1. Usuario lee     │                        │                    │                │
      │  página 15          │                        │                    │                │
      │                     │                        │                    │                │
      │  2. onPageChange    │                        │                    │                │
      ├────────────────────>│                        │                    │                │
      │                     │                        │                    │                │
      │                     │  3. Debounce 5s        │                    │                │
      │                     ├──────────────┐         │                    │                │
      │                     │  Acumular    │         │                    │                │
      │                     │  cambios     │         │                    │                │
      │                     │<─────────────┘         │                    │                │
      │                     │                        │                    │                │
      │                     │  4. saveProgress()     │                    │                │
      │                     ├───────────────────────>│                    │                │
      │                     │                        │                    │                │
      │                     │                        │  5. Buscar/Crear   │                │
      │                     │                        │  PendingProgress   │                │
      │                     │                        ├───────────────────>│                │
      │                     │                        │                    │                │
      │                     │                        │  6. updateProgress()│                │
      │                     │                        │<───────────────────┤                │
      │                     │                        │  needsSync = true  │                │
      │                     │                        │                    │                │
      │                     │                        │  7. Enqueue sync   │                │
      │                     │                        │  (si hay red)      │                │
      │                     │                        ├───────────────────────────────────>│
      │                     │                        │                    │                │
      │                     │  8. Success            │                    │                │
      │                     │<───────────────────────┤                    │                │
```

**Pasos Detallados**:
1. Usuario lee PDF y cambia de página
2. `PDFReaderView` detecta cambio con `onPageChange`
3. `ProgressTracker` hace debounce de 5 segundos para evitar writes excesivos
4. Guarda progreso local en `PendingProgress` via `LocalProgressDataSource`
5. Marca `needsSync = true` para sincronizar cuando haya red
6. Si hay conexión, agrega request a `OfflineQueue` para sync inmediato
7. Si no hay conexión, espera a `NetworkSyncCoordinator` para auto-sync

---

### 7.3 Flujo: Quiz Offline y Sincronización Posterior

```
QuizView          QuizViewModel      LocalQuizDataSource     SwiftData      NetworkMonitor      APIClient
    │                   │                      │                 │                 │                │
    │  1. Completar     │                      │                 │                 │                │
    │  quiz offline     │                      │                 │                 │                │
    ├──────────────────>│                      │                 │                 │                │
    │                   │                      │                 │                 │                │
    │                   │  2. saveAttempt()    │                 │                 │                │
    │                   ├─────────────────────>│                 │                 │                │
    │                   │                      │                 │                 │                │
    │                   │                      │  3. Crear       │                 │                │
    │                   │                      │  PendingQuizAttempt                │                │
    │                   │                      ├────────────────>│                 │                │
    │                   │                      │  needsSync=true │                 │                │
    │                   │                      │                 │                 │                │
    │  4. "Guardado     │                      │                 │                 │                │
    │  localmente.      │                      │                 │                 │                │
    │  Se enviará       │                      │                 │                 │                │
    │  cuando haya red" │                      │                 │                 │                │
    │<──────────────────┤                      │                 │                 │                │
    │                   │                      │                 │                 │                │
    │                   │                      │                 │  5. Red recuperada                │
    │                   │                      │                 │  (después)      │                │
    │                   │                      │                 │<────────────────┤                │
    │                   │                      │                 │                 │                │
    │                   │                      │  6. Trigger     │                 │                │
    │                   │                      │  auto-sync      │                 │                │
    │                   │  7. syncQuizAttempts()                 │                 │                │
    │                   │<─────────────────────┤                 │                 │                │
    │                   │                      │                 │                 │                │
    │                   │  8. GET pending      │                 │                 │                │
    │                   ├─────────────────────>│                 │                 │                │
    │                   │                      │                 │                 │                │
    │                   │  9. POST /attempts   │                 │                 │                │
    │                   ├─────────────────────────────────────────────────────────>│                │
    │                   │                      │                 │                 │                │
    │                   │  10. 201 Created     │                 │                 │                │
    │                   │  { attemptId, score }│                 │                 │                │
    │                   │<─────────────────────────────────────────────────────────┤                │
    │                   │                      │                 │                 │                │
    │                   │  11. markAsSynced()  │                 │                 │                │
    │                   ├─────────────────────>│                 │                 │                │
    │                   │                      │                 │                 │                │
    │  12. "Quiz        │                      │                 │                 │                │
    │  enviado.         │                      │                 │                 │                │
    │  Score: 85/100"   │                      │                 │                 │                │
    │<──────────────────┤                      │                 │                 │                │
```

---

### 7.4 Flujo: Sincronización Automática al Reconectar

```
NetworkMonitor     NetworkSyncCoordinator    OfflineSyncService     LocalDataSources     APIClient
      │                      │                        │                     │                 │
      │  1. Red perdida      │                        │                     │                 │
      │  isConnected=false   │                        │                     │                 │
      ├─────────────────────>│                        │                     │                 │
      │                      │                        │                     │                 │
      │  (Usuario trabaja offline por 2 horas)        │                     │                 │
      │  - Lee materiales    │                        │                     │                 │
      │  - Completa quiz     │                        │                     │                 │
      │  - Actualiza progreso│                        │                     │                 │
      │                      │                        │                     │                 │
      │  2. Red recuperada   │                        │                     │                 │
      │  isConnected=true    │                        │                     │                 │
      ├─────────────────────>│                        │                     │                 │
      │                      │                        │                     │                 │
      │                      │  3. Auto-sync trigger  │                     │                 │
      │                      ├───────────────────────>│                     │                 │
      │                      │                        │                     │                 │
      │                      │                        │  4. GET pending count                 │
      │                      │                        ├────────────────────>│                 │
      │                      │                        │                     │                 │
      │                      │                        │  5. PendingProgress: 15 items         │
      │                      │                        │  PendingQuizAttempt: 2 items          │
      │                      │                        │<────────────────────┤                 │
      │                      │                        │                     │                 │
      │                      │                        │  6. Sync progress (batch)             │
      │                      │                        ├──────────────────────────────────────>│
      │                      │                        │  PUT /progress (bulk)                 │
      │                      │                        │                     │                 │
      │                      │                        │  7. 200 OK          │                 │
      │                      │                        │<──────────────────────────────────────┤
      │                      │                        │                     │                 │
      │                      │                        │  8. Mark synced     │                 │
      │                      │                        ├────────────────────>│                 │
      │                      │                        │                     │                 │
      │                      │                        │  9. Sync quiz attempts                │
      │                      │                        ├──────────────────────────────────────>│
      │                      │                        │  POST /attempts (×2)                  │
      │                      │                        │                     │                 │
      │                      │                        │  10. 201 Created    │                 │
      │                      │                        │<──────────────────────────────────────┤
      │                      │                        │                     │                 │
      │                      │                        │  11. Mark synced    │                 │
      │                      │                        ├────────────────────>│                 │
      │                      │                        │                     │                 │
      │                      │  12. Sync complete     │                     │                 │
      │                      │  (15 progress + 2 quiz)│                     │                 │
      │                      │<───────────────────────┤                     │                 │
      │                      │                        │                     │                 │
      │                      │  13. Notify UI         │                     │                 │
      │                      │  "17 items sincronizados"                    │                 │
```

---

## 8. UI/UX para Offline

### 8.1 Indicadores Visuales

#### Badge "Disponible Offline"

**Ubicación**: En cada card de material en `MaterialListView`

```swift
// Ejemplo de uso en SwiftUI
struct MaterialCard: View {
    let material: CachedMaterial
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(material.title)
                    .font(.headline)
                Text(material.subjectName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 🆕 Badge offline
            if material.isAvailableOffline {
                Label("Offline", systemImage: "arrow.down.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }
}
```

**Diseño**:
- ✅ Icono: `arrow.down.circle.fill` (verde)
- ✅ Texto: "Disponible offline"
- ✅ Posición: Esquina superior derecha del card

---

#### Estado de Descarga

**Ubicación**: Botón de descarga en `MaterialDetailView`

```swift
struct DownloadButton: View {
    @Binding var downloadTask: DownloadTask?
    let onDownload: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Group {
            switch downloadTask?.state {
            case .none:
                // No descargado
                Button(action: onDownload) {
                    Label("Descargar para offline", systemImage: "arrow.down.circle")
                }
                
            case "downloading":
                // Descargando
                VStack {
                    ProgressView(value: downloadTask?.progress ?? 0.0)
                    HStack {
                        Text("Descargando \(downloadTask?.progressPercentage ?? 0)%")
                            .font(.caption)
                        Spacer()
                        Button("Cancelar", action: onCancel)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
            case "completed":
                // Descargado
                Label("Descargado", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                
            case "failed":
                // Error
                Button(action: onDownload) {
                    Label("Reintentar descarga", systemImage: "arrow.clockwise")
                        .foregroundStyle(.red)
                }
                
            default:
                EmptyView()
            }
        }
    }
}
```

---

#### Indicador "Sin Conexión" Global

**Ya existe**: `OfflineBanner` (SPEC-013 completado)

**Ubicación**: Top de `ContentView` cuando `NetworkState.isConnected == false`

```swift
struct ContentView: View {
    @Environment(NetworkState.self) private var networkState
    
    var body: some View {
        VStack(spacing: 0) {
            // 🆕 Banner offline (ya existe)
            if !networkState.isConnected {
                OfflineBanner()
            }
            
            // Contenido principal
            NavigationStack {
                MaterialListView()
            }
        }
    }
}
```

---

#### Queue de Pendientes Visible

**Ubicación**: Sección en `ProfileView` o `SettingsView`

```swift
struct PendingSyncSection: View {
    @Environment(NetworkState.self) private var networkState
    let pendingCount: Int
    
    var body: some View {
        Section {
            HStack {
                Label("Datos pendientes de sincronizar", systemImage: "icloud.and.arrow.up")
                Spacer()
                Text("\(pendingCount)")
                    .foregroundStyle(.secondary)
            }
            
            if !networkState.isConnected {
                Text("Se sincronizarán automáticamente cuando haya conexión")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if pendingCount > 0 {
                Button("Sincronizar ahora") {
                    Task {
                        await networkState.forceSync()
                    }
                }
            }
        } header: {
            Text("Sincronización")
        }
    }
}
```

---

### 8.2 Interacciones de Usuario

#### Botón "Descargar para Offline"

**Ubicación**: `MaterialDetailView`

**Comportamiento**:
1. Tap → Inicia descarga
2. Muestra `ProgressView` con porcentaje
3. Permite cancelar descarga en progreso
4. Al completar, cambia a "Descargado" con checkmark
5. Si falla, muestra "Reintentar"

---

#### Gestión de Almacenamiento

**Ubicación**: Nueva vista `StorageManagementView` en Settings

```swift
struct StorageManagementView: View {
    @State private var totalUsed: Int64 = 0
    @State private var availableSpace: Int64 = 0
    @State private var materials: [CachedMaterial] = []
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Espacio usado")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: totalUsed, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Espacio disponible")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: availableSpace, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Almacenamiento")
            }
            
            Section {
                ForEach(materials) { material in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(material.title)
                            Text("Descargado: \(material.downloadedAt?.formatted() ?? "N/A")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(material.fileSizeFormatted ?? "N/A")
                            .foregroundStyle(.secondary)
                        
                        Button(role: .destructive) {
                            // Eliminar
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            } header: {
                Text("Materiales Descargados")
            }
            
            Section {
                Button("Limpiar cache antiguo (30+ días)") {
                    // Ejecutar CacheCleaner
                }
            }
        }
        .navigationTitle("Gestión de Almacenamiento")
    }
}
```

---

#### Forzar Sincronización Manual

**Ubicación**: Botón en `SettingsView` o pull-to-refresh en `MaterialListView`

```swift
struct MaterialListView: View {
    @Environment(NetworkState.self) private var networkState
    @State private var materials: [CachedMaterial] = []
    
    var body: some View {
        List(materials) { material in
            MaterialCard(material: material)
        }
        .refreshable {
            await networkState.forceSync()
            // Recargar lista
        }
    }
}
```

---

## 9. Manejo de Errores

### 9.1 Errores de Descarga

| Error | Causa | Manejo |
|-------|-------|--------|
| **Network Timeout** | Conexión lenta/inestable | Auto-retry 3 veces con exponential backoff |
| **Disk Full** | Espacio insuficiente | Mostrar alerta "Espacio insuficiente. Libera espacio." |
| **Invalid URL** | URL malformada del backend | Log error, mostrar "Error de servidor" |
| **Unauthorized** | Token expirado | Refrescar token y reintentar |
| **File Corrupted** | Hash no coincide | Eliminar archivo y reintentar descarga |

**Implementación de Retry**:
```swift
actor DownloadManager {
    func startDownload(materialId: UUID, sourceURL: URL) async throws -> DownloadTask {
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                let task = try await performDownload(materialId: materialId, sourceURL: sourceURL)
                return task
            } catch let error as NetworkError {
                retryCount += 1
                if retryCount >= maxRetries {
                    throw error
                }
                
                // Exponential backoff: 2^retry * 1s
                let delay = pow(2.0, Double(retryCount))
                try await Task.sleep(for: .seconds(delay))
            }
        }
        
        throw NetworkError.maxRetriesExceeded
    }
}
```

---

### 9.2 Errores de Sincronización

| Error | Causa | Manejo |
|-------|-------|--------|
| **HTTP 409 Conflict** | Cambio concurrente en servidor | Usar `ConflictResolver` (ya existe) |
| **HTTP 401 Unauthorized** | Token expirado | Refrescar token automáticamente |
| **HTTP 500 Server Error** | Error de backend | Reintentar con backoff, mostrar toast |
| **Network Unreachable** | Sin conexión | Mantener en queue, esperar auto-sync |
| **Data Corruption** | JSON inválido | Log error, descartar item |

**Implementación de Conflict Resolution**:
```swift
// Ya existe en ConflictResolver (SPEC-013)
actor OfflineSyncService {
    func syncProgress() async throws -> Int {
        let pending = await localDataSource.getPendingProgress()
        var syncedCount = 0
        
        for progress in pending {
            do {
                try await apiClient.updateProgress(progress)
                await progress.markAsSynced()
                syncedCount += 1
            } catch let error as NetworkError where error.isConflict {
                // Server tiene versión más reciente
                let resolution = await conflictResolver.resolve(
                    local: progress,
                    remote: error.serverData,
                    strategy: .serverWins // o .clientWins, .manual
                )
                
                if case .serverWins = resolution {
                    // Descartar cambios locales
                    await progress.markAsSynced()
                }
            }
        }
        
        return syncedCount
    }
}
```

---

### 9.3 Errores de Almacenamiento

| Error | Causa | Manejo |
|-------|-------|--------|
| **File Not Found** | Archivo eliminado externamente | Marcar material como no descargado |
| **Permission Denied** | Permisos de filesystem | Solicitar permisos, mostrar alerta |
| **Disk Full** | Espacio insuficiente | Mostrar alerta + sugerir limpieza |
| **Hash Mismatch** | Archivo corrupto | Eliminar y re-descargar |

---

## 10. Consideraciones de Almacenamiento

### 10.1 Límites de Espacio

| Plataforma | Límite Recomendado | Alerta |
|------------|-------------------|--------|
| iOS | 500 MB - 2 GB | Cuando queden < 500 MB libres |
| macOS | 2 GB - 10 GB | Cuando queden < 1 GB libres |
| visionOS | 1 GB - 5 GB | Cuando queden < 500 MB libres |

**Nota**: Límites configurables por usuario en Settings.

---

### 10.2 Limpieza Automática de Cache

**Trigger**: Al iniciar la app (background task)

**Políticas**:
1. **Materiales no accedidos en 30+ días**: Eliminar PDF local (mantener metadata)
2. **Descargas fallidas > 7 días**: Eliminar `DownloadTask`
3. **HTTP cache > 14 días**: Eliminar `CachedHTTPResponse`
4. **Quiz attempts sincronizados > 7 días**: Eliminar `PendingQuizAttempt`

**Implementación**:
```swift
actor CacheCleaner {
    func performFullCleanup() async throws {
        // 1. Limpiar materiales antiguos
        let oldMaterials = await modelContext.fetch(
            FetchDescriptor<CachedMaterial>(
                predicate: #Predicate { material in
                    material.lastAccessedAt ?? Date.distantPast < Date().addingTimeInterval(-30 * 86400)
                }
            )
        )
        
        for material in oldMaterials {
            if let fileURL = material.localFileURL {
                try? await fileStorageService.deleteFile(for: material.id)
            }
            material.markAsDeleted()
        }
        
        // 2. Limpiar descargas fallidas
        let failedDownloads = await modelContext.fetch(
            FetchDescriptor<DownloadTask>(
                predicate: #Predicate { task in
                    task.state == "failed" && task.createdAt < Date().addingTimeInterval(-7 * 86400)
                }
            )
        )
        
        for task in failedDownloads {
            modelContext.delete(task)
        }
        
        // 3. Limpiar HTTP cache
        // (similar pattern)
    }
}
```

---

### 10.3 Priorización de Contenido

**Orden de Eliminación Automática** (cuando espacio es crítico):
1. Descargas fallidas
2. HTTP cache antiguo
3. Materiales no accedidos en 60+ días
4. Materiales no accedidos en 30+ días
5. (Usuario debe eliminar manualmente lo demás)

---

## 11. Testing

### 11.1 Tests Unitarios

#### DownloadManager Tests

```swift
@Test("Download manager inicia descarga correctamente")
func testStartDownload() async throws {
    let manager = DownloadManager(
        modelContext: mockModelContext,
        fileStorage: mockFileStorage
    )
    
    let task = try await manager.startDownload(
        materialId: UUID(),
        sourceURL: URL(string: "https://example.com/material.pdf")!
    )
    
    #expect(task.state == "pending")
    #expect(task.progress == 0.0)
}

@Test("Download manager reporta progreso")
func testDownloadProgress() async throws {
    let manager = DownloadManager(...)
    let task = try await manager.startDownload(...)
    
    var progressValues: [Double] = []
    
    for await progress in manager.downloadProgress(taskId: task.id) {
        progressValues.append(progress)
        if progress >= 1.0 {
            break
        }
    }
    
    #expect(progressValues.last == 1.0)
}

@Test("Download manager reintenta en caso de fallo")
func testDownloadRetry() async throws {
    let manager = DownloadManager(...)
    mockURLSession.shouldFail = true // Simular fallo
    
    let task = try await manager.startDownload(...)
    
    #expect(task.retryCount > 0)
    #expect(task.retryCount <= task.maxRetries)
}
```

---

#### FileStorageService Tests

```swift
@Test("FileStorage guarda archivo correctamente")
func testSaveFile() async throws {
    let service = FileStorageService()
    let tempURL = URL(fileURLWithPath: "/tmp/test.pdf")
    
    // Crear archivo temporal
    try Data("test".utf8).write(to: tempURL)
    
    let savedURL = try await service.saveFile(
        from: tempURL,
        for: UUID()
    )
    
    #expect(FileManager.default.fileExists(atPath: savedURL.path))
}

@Test("FileStorage calcula hash correctamente")
func testCalculateHash() async throws {
    let service = FileStorageService()
    let url = URL(fileURLWithPath: "/tmp/test.pdf")
    
    let hash = try await service.calculateFileHash(at: url)
    
    #expect(hash.count == 64) // SHA-256 = 64 caracteres hex
}
```

---

#### OfflineSyncService Tests

```swift
@Test("OfflineSync sincroniza progreso correctamente")
func testSyncProgress() async throws {
    let service = OfflineSyncService(...)
    
    // Crear progreso pendiente
    let progress = PendingProgress(
        materialId: UUID(),
        studentId: UUID(),
        progressPercentage: 75.0
    )
    await modelContext.insert(progress)
    
    let syncedCount = try await service.syncProgress()
    
    #expect(syncedCount == 1)
    #expect(progress.needsSync == false)
}

@Test("OfflineSync maneja conflictos HTTP 409")
func testSyncConflict() async throws {
    let service = OfflineSyncService(...)
    mockAPIClient.shouldReturn409 = true
    
    let progress = PendingProgress(...)
    await modelContext.insert(progress)
    
    let syncedCount = try await service.syncProgress()
    
    // Debe resolver conflicto sin crash
    #expect(syncedCount >= 0)
}
```

---

### 11.2 Tests de Integración

#### Flujo Completo: Descarga → Lectura → Progreso → Sync

```swift
@Test("Flujo completo offline")
func testCompleteOfflineFlow() async throws {
    // 1. Descargar material
    let downloadManager = DownloadManager(...)
    let task = try await downloadManager.startDownload(...)
    
    // Esperar a que complete
    for await progress in downloadManager.downloadProgress(taskId: task.id) {
        if progress >= 1.0 { break }
    }
    
    #expect(task.state == "completed")
    
    // 2. Simular lectura
    let progressTracker = ProgressTracker(...)
    await progressTracker.updateProgress(page: 10, totalPages: 50)
    
    // 3. Verificar persistencia local
    let pendingProgress = await modelContext.fetch(
        FetchDescriptor<PendingProgress>(...)
    )
    #expect(pendingProgress.count == 1)
    #expect(pendingProgress[0].needsSync == true)
    
    // 4. Simular reconexión
    networkMonitor.setConnected(true)
    
    // 5. Auto-sync
    let syncService = OfflineSyncService(...)
    let syncedCount = try await syncService.syncAllPendingData()
    
    #expect(syncedCount == 1)
    #expect(pendingProgress[0].needsSync == false)
}
```

---

### 11.3 Tests de Simulación de Pérdida de Conexión

#### Usando Network Link Conditioner (iOS Simulator)

1. **Configurar Network Link Conditioner**:
   - Xcode → Debug → Simulate Network Conditions → 100% Loss

2. **Ejecutar tests**:
```swift
@Test("Operaciones offline se encolan correctamente")
func testOfflineQueue() async throws {
    // Simular pérdida de red
    networkMonitor.setConnected(false)
    
    // Intentar actualizar progreso
    let progressService = ProgressService(...)
    try await progressService.updateProgress(...)
    
    // Verificar que se encoló
    let queuedCount = await offlineQueue.pendingCount()
    #expect(queuedCount == 1)
    
    // Simular reconexión
    networkMonitor.setConnected(true)
    
    // Auto-sync debe procesar
    await networkSyncCoordinator.syncNow()
    
    let remainingCount = await offlineQueue.pendingCount()
    #expect(remainingCount == 0)
}
```

---

## 12. Plan de Implementación

### Fase 1: Modelos y Persistencia (Semana 1)

**Duración**: 5 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 1.1 | Crear modelo `CachedMaterial` en SwiftData | 4h | Dev iOS |
| 1.2 | Crear modelo `DownloadTask` en SwiftData | 3h | Dev iOS |
| 1.3 | Crear modelo `PendingProgress` en SwiftData | 3h | Dev iOS |
| 1.4 | Crear modelo `PendingQuizAttempt` en SwiftData | 3h | Dev iOS |
| 1.5 | Actualizar `ModelContainer` con nuevos modelos | 1h | Dev iOS |
| 1.6 | Tests unitarios de modelos | 6h | Dev iOS |

**Total**: 20h (2.5 días)

---

### Fase 2: Download Manager (Semana 2)

**Duración**: 5 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 2.1 | Implementar `DownloadManager` base con URLSession | 8h | Dev iOS |
| 2.2 | Agregar tracking de progreso con AsyncStream | 4h | Dev iOS |
| 2.3 | Implementar pause/resume/cancel | 4h | Dev iOS |
| 2.4 | Implementar retry logic con exponential backoff | 4h | Dev iOS |
| 2.5 | Integrar con SwiftData (DownloadTask) | 3h | Dev iOS |
| 2.6 | Tests unitarios de DownloadManager | 8h | Dev iOS |
| 2.7 | Tests de integración con URLSession mock | 6h | Dev iOS |

**Total**: 37h (4.6 días)

---

### Fase 3: File Storage Service (Semana 2-3)

**Duración**: 3 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 3.1 | Implementar `FileStorageService` con FileManager | 6h | Dev iOS |
| 3.2 | Implementar cálculo de SHA-256 hash | 3h | Dev iOS |
| 3.3 | Implementar gestión de directorios | 2h | Dev iOS |
| 3.4 | Implementar `totalStorageUsed()` y `availableDiskSpace()` | 3h | Dev iOS |
| 3.5 | Tests unitarios de FileStorageService | 6h | Dev iOS |

**Total**: 20h (2.5 días)

---

### Fase 4: Data Sources Locales (Semana 3-4)

**Duración**: 5 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 4.1 | Implementar `LocalMaterialDataSource` | 6h | Dev iOS |
| 4.2 | Implementar `LocalProgressDataSource` | 6h | Dev iOS |
| 4.3 | Implementar `LocalQuizDataSource` | 6h | Dev iOS |
| 4.4 | Integrar con Repository Pattern existente | 8h | Dev iOS |
| 4.5 | Tests unitarios de Data Sources | 10h | Dev iOS |

**Total**: 36h (4.5 días)

---

### Fase 5: Offline Sync Service (Semana 4-5)

**Duración**: 5 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 5.1 | Implementar `OfflineSyncService` base | 8h | Dev iOS |
| 5.2 | Implementar `syncProgress()` con batch updates | 6h | Dev iOS |
| 5.3 | Implementar `syncQuizAttempts()` | 6h | Dev iOS |
| 5.4 | Integrar con `NetworkSyncCoordinator` existente | 4h | Dev iOS |
| 5.5 | Integrar con `ConflictResolver` existente | 4h | Dev iOS |
| 5.6 | Tests unitarios de OfflineSyncService | 8h | Dev iOS |
| 5.7 | Tests de integración con APIClient mock | 8h | Dev iOS |

**Total**: 44h (5.5 días)

---

### Fase 6: UI Components (Semana 5-6)

**Duración**: 5 días
**Prioridad**: 🟡 P1 - Alta

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 6.1 | Implementar `DownloadButton` con estados | 4h | Dev iOS |
| 6.2 | Implementar badge "Disponible offline" | 2h | Dev iOS |
| 6.3 | Implementar `StorageManagementView` | 8h | Dev iOS |
| 6.4 | Integrar indicadores en `MaterialListView` | 4h | Dev iOS |
| 6.5 | Integrar download UI en `MaterialDetailView` | 6h | Dev iOS |
| 6.6 | Implementar pull-to-refresh para sync manual | 3h | Dev iOS |
| 6.7 | Tests de UI (ViewInspector) | 8h | Dev iOS |

**Total**: 35h (4.4 días)

---

### Fase 7: Storage Management (Semana 6-7)

**Duración**: 4 días
**Prioridad**: 🟡 P1 - Alta

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 7.1 | Implementar `StorageMonitor` | 6h | Dev iOS |
| 7.2 | Implementar `CacheCleaner` con políticas | 8h | Dev iOS |
| 7.3 | Implementar alerta de espacio bajo | 3h | Dev iOS |
| 7.4 | Implementar limpieza automática al iniciar app | 4h | Dev iOS |
| 7.5 | Tests unitarios de StorageMonitor y CacheCleaner | 6h | Dev iOS |

**Total**: 27h (3.4 días)

---

### Fase 8: Testing y QA (Semana 7-8)

**Duración**: 5 días
**Prioridad**: 🔴 P0 - Crítica

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 8.1 | Tests de integración end-to-end | 12h | Dev iOS + QA |
| 8.2 | Tests de simulación de pérdida de conexión | 8h | Dev iOS + QA |
| 8.3 | Tests de performance (descarga grande, múltiples archivos) | 6h | Dev iOS + QA |
| 8.4 | Tests de edge cases (disco lleno, archivos corruptos) | 6h | Dev iOS + QA |
| 8.5 | Tests en dispositivos reales (iOS 18, 17, 16) | 8h | QA |

**Total**: 40h (5 días)

---

### Fase 9: Documentación y Deployment (Semana 8)

**Duración**: 2 días
**Prioridad**: 🟢 P2 - Media

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 9.1 | Documentar APIs públicas (DocC) | 4h | Dev iOS |
| 9.2 | Crear guía de usuario para modo offline | 3h | Tech Writer |
| 9.3 | Actualizar CHANGELOG.md | 1h | Dev iOS |
| 9.4 | Code review completo | 6h | Tech Lead |
| 9.5 | Merge a main y deploy a TestFlight | 2h | Dev iOS |

**Total**: 16h (2 días)

---

### Resumen de Estimación

| Fase | Duración | Horas | Prioridad |
|------|----------|-------|-----------|
| Fase 1: Modelos y Persistencia | 2.5 días | 20h | 🔴 P0 |
| Fase 2: Download Manager | 4.6 días | 37h | 🔴 P0 |
| Fase 3: File Storage Service | 2.5 días | 20h | 🔴 P0 |
| Fase 4: Data Sources Locales | 4.5 días | 36h | 🔴 P0 |
| Fase 5: Offline Sync Service | 5.5 días | 44h | 🔴 P0 |
| Fase 6: UI Components | 4.4 días | 35h | 🟡 P1 |
| Fase 7: Storage Management | 3.4 días | 27h | 🟡 P1 |
| Fase 8: Testing y QA | 5 días | 40h | 🔴 P0 |
| Fase 9: Documentación | 2 días | 16h | 🟢 P2 |

**TOTAL**: **34.4 días** (≈ **7 semanas**) | **275 horas**

**Nota**: Estimación para 1 desarrollador iOS senior a tiempo completo. Puede reducirse con equipo de 2 desarrolladores.

---

## Dependencias

### Dependencias Internas

| Componente | Depende de |
|------------|------------|
| DownloadManager | FileStorageService, SwiftData models |
| OfflineSyncService | NetworkMonitor, OfflineQueue, ConflictResolver |
| UI Components | DownloadManager, OfflineSyncService, NetworkState |
| CacheCleaner | FileStorageService, StorageMonitor |

### Dependencias Externas

- ✅ **NetworkMonitor** (ya existe)
- ✅ **NetworkSyncCoordinator** (ya existe)
- ✅ **OfflineQueue** (ya existe)
- ✅ **ConflictResolver** (ya existe)
- ✅ **SwiftData** (framework de Apple)
- ❌ Backend API debe soportar:
  - Bulk update de progreso (`PUT /v1/progress/bulk`)
  - Validación de hash de archivos
  - Endpoints para obtener última versión de materiales

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Espacio en disco insuficiente | Alta | Alto | Implementar StorageMonitor con alertas proactivas |
| Corrupción de archivos descargados | Media | Alto | Validar hash SHA-256 después de descarga |
| Conflictos de sincronización complejos | Media | Medio | Usar ConflictResolver con estrategia serverWins por defecto |
| Performance en dispositivos antiguos | Baja | Medio | Limitar descargas concurrentes a 2, usar background tasks |
| Cambios en backend durante desarrollo | Media | Medio | Mantener comunicación con equipo backend, versionar APIs |

---

## Próximos Pasos

1. ✅ **Revisar y aprobar este spec** con equipo (Product, iOS, Backend)
2. 📝 **Crear SPEC-SYNC.md** con detalles avanzados de sincronización (Fase 2)
3. 🎨 **Diseño UI/UX completo** con mockups en Figma (Diseñador)
4. 🚀 **Iniciar Fase 1** (Modelos SwiftData)
5. 📊 **Configurar tracking** en Linear/Jira con todas las tareas

---

## Referencias

- **SPEC-013 (Offline-First UI)**: `/docs/specs/archived/completed-specs/offline-first/SPEC-013-COMPLETADO.md`
- **SPEC-004 (Network Layer)**: (referenciado en SPEC-013)
- **SPEC-005 (SwiftData Integration)**: (referenciado en SPEC-013)
- **Database Analysis**: `/EDUGO_DATABASE_ANALYSIS.md`
- **Flujos Críticos**: `/FLUJOS_CRITICOS.md`
- **Apple Documentation**:
  - [SwiftData](https://developer.apple.com/documentation/swiftdata)
  - [URLSession Downloads](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background)
  - [FileManager](https://developer.apple.com/documentation/foundation/filemanager)

---

**Versión**: 1.0  
**Fecha de Creación**: 1 de Diciembre, 2025  
**Autor**: Claude Code (AI Assistant)  
**Estado**: 📝 Especificación - Pendiente de Aprobación
