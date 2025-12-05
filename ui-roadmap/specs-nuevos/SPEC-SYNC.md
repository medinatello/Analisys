# SPEC-SYNC: Estrategia de Sincronización Avanzada - App Apple EduGo

**Versión**: 1.0
**Fecha**: 1 de Diciembre, 2025
**Plataforma**: iOS 18.0+, macOS 15.0+, visionOS 2.0+
**Swift**: 6.0
**Estado**: 📝 ESPECIFICACIÓN - Segunda Fase (Post SPEC-OFFLINE)

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Prerrequisitos](#2-prerrequisitos)
3. [Estrategias de Sincronización](#3-estrategias-de-sincronización)
4. [Frecuencia y Triggers](#4-frecuencia-y-triggers)
5. [Manejo de Conflictos](#5-manejo-de-conflictos)
6. [Retry Policy](#6-retry-policy)
7. [Optimizaciones](#7-optimizaciones)
8. [Arquitectura de Sincronización](#8-arquitectura-de-sincronización)
9. [Implementación Detallada](#9-implementación-detallada)
10. [Monitoreo y Debugging](#10-monitoreo-y-debugging)
11. [Plan de Implementación](#11-plan-de-implementación)

---

## 1. Resumen Ejecutivo

### Contexto

Este spec es la **Segunda Fase** del sistema de persistencia offline de EduGo. Asume que **SPEC-OFFLINE.md** ya fue implementado, lo que significa que tenemos:

- ✅ Persistencia local con SwiftData (CachedMaterial, PendingProgress, etc.)
- ✅ DownloadManager funcional
- ✅ OfflineSyncService básico
- ✅ NetworkMonitor y NetworkSyncCoordinator

### Objetivo

Implementar una estrategia de sincronización **robusta, eficiente y confiable** que:

1. **Minimice conflictos** entre cambios locales y remotos
2. **Optimice uso de red** con sincronización delta (solo cambios)
3. **Maneje conflictos complejos** con UI para resolución manual cuando sea necesario
4. **Garantice consistencia eventual** de datos entre cliente y servidor
5. **Provea visibilidad** del estado de sincronización al usuario

### Alcance de Esta Fase

| Característica | Primera Fase (SPEC-OFFLINE) | Segunda Fase (Este Spec) |
|----------------|------------------------------|--------------------------|
| **Sync Básico** | ✅ Auto-sync al reconectar | ✅ Ya implementado |
| **Sync Manual** | ✅ Pull-to-refresh | ✅ Ya implementado |
| **Conflictos Simples** | ✅ HTTP 409 con serverWins | ⬆️ Mejorar con UI manual |
| **Sync Bidireccional** | ❌ No implementado | 🆕 Implementar |
| **Delta Sync** | ❌ Full sync siempre | 🆕 Solo cambios |
| **Merge Inteligente** | ❌ No hay merge | 🆕 Merge automático |
| **UI de Conflictos** | ❌ No hay UI | 🆕 Resolver manualmente |
| **Metrics y Logging** | ⚠️ Básico | 🆕 Completo |

---

## 2. Prerrequisitos

### 2.1 Componentes Implementados (SPEC-OFFLINE)

Antes de iniciar esta fase, deben estar implementados:

- ✅ **Modelos SwiftData**: CachedMaterial, DownloadTask, PendingProgress, PendingQuizAttempt
- ✅ **DownloadManager**: Descarga de PDFs con progreso
- ✅ **FileStorageService**: Gestión de archivos locales
- ✅ **OfflineSyncService**: Sync básico de progreso y quiz attempts
- ✅ **NetworkMonitor**: Detección de conectividad
- ✅ **NetworkSyncCoordinator**: Auto-sync al reconectar

### 2.2 Backend APIs Requeridas

El backend debe exponer los siguientes endpoints:

| Endpoint | Método | Propósito |
|----------|--------|-----------|
| `/v1/sync/materials/delta` | POST | Obtener materiales modificados desde timestamp |
| `/v1/sync/progress/delta` | POST | Obtener progreso modificado desde timestamp |
| `/v1/sync/progress/bulk` | PUT | Actualizar múltiples progresos en una request |
| `/v1/sync/quiz/bulk` | POST | Enviar múltiples quiz attempts |
| `/v1/sync/metadata` | GET | Obtener metadatos de sincronización (última versión, checksums) |

**Ejemplo de Request Delta Sync**:
```json
POST /v1/sync/materials/delta
{
  "last_sync_at": "2025-12-01T10:30:00Z",
  "device_id": "iPhone-UUID",
  "material_ids": ["uuid1", "uuid2", "uuid3"]
}

Response 200 OK:
{
  "materials": [
    {
      "id": "uuid1",
      "title": "Material actualizado",
      "updated_at": "2025-12-01T11:00:00Z",
      "version": 2
    }
  ],
  "deleted_material_ids": ["uuid5"],
  "server_timestamp": "2025-12-01T12:00:00Z"
}
```

---

## 3. Estrategias de Sincronización

### 3.1 Tipos de Sincronización

#### A. Pull Sync (Cliente descarga cambios del servidor)

**Cuándo**: Al abrir la app, pull-to-refresh, cada 15 minutos en background

**Proceso**:
1. Cliente envía `last_sync_at` timestamp
2. Servidor retorna solo cambios desde ese timestamp
3. Cliente aplica cambios localmente
4. Cliente actualiza `last_sync_at`

**Ventajas**:
- Eficiente (solo cambios)
- Bajo uso de red
- Rápido

**Desventajas**:
- No sube cambios locales
- Requiere clock sync entre cliente y servidor

---

#### B. Push Sync (Cliente sube cambios al servidor)

**Cuándo**: Después de operaciones locales (guardar progreso, completar quiz)

**Proceso**:
1. Cliente identifica items con `needsSync = true`
2. Cliente envía batch de cambios al servidor
3. Servidor procesa y retorna confirmación
4. Cliente marca items como sincronizados

**Ventajas**:
- Envía cambios inmediatamente
- Reduce riesgo de conflictos

**Desventajas**:
- Puede generar conflictos si servidor cambió
- Requiere manejo de HTTP 409

---

#### C. Bidirectional Sync (Pull + Push + Merge)

**Cuándo**: Sincronización completa periódica (cada 30 min o manual)

**Proceso**:
1. **Pull**: Descargar cambios del servidor
2. **Detect Conflicts**: Comparar cambios locales vs remotos
3. **Merge**: Aplicar estrategia de merge (auto o manual)
4. **Push**: Enviar cambios locales resueltos
5. **Confirm**: Actualizar timestamps de sync

**Ventajas**:
- Sincronización completa
- Detecta y resuelve conflictos
- Consistencia eventual garantizada

**Desventajas**:
- Más complejo
- Puede requerir intervención del usuario

---

### 3.2 Estrategia Recomendada para EduGo

**Híbrida: Pull Optimista + Push Inmediato + Bidirectional Periódico**

| Operación | Estrategia | Frecuencia |
|-----------|------------|------------|
| **Abrir app** | Pull Sync | Una vez al iniciar |
| **Actualizar progreso** | Push Sync | Inmediato (debounced 5s) |
| **Completar quiz** | Push Sync | Inmediato |
| **Pull-to-refresh** | Bidirectional Sync | Manual |
| **Background sync** | Pull Sync | Cada 15 min (iOS Background Tasks) |
| **Reconectar red** | Bidirectional Sync | Una vez al detectar red |
| **Sync completo** | Bidirectional Sync | Cada 30 min o manual |

---

## 4. Frecuencia y Triggers

### 4.1 Triggers Automáticos

#### Trigger 1: App Launch (Inicio de App)

```swift
@main
struct EduGoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var syncService = OfflineSyncService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    // Pull sync al activar
                    await syncService.performPullSync()
                }
            }
        }
    }
}
```

**Comportamiento**:
- Ejecutar Pull Sync al abrir la app
- Timeout: 10 segundos
- Si falla: continuar offline, mostrar toast

---

#### Trigger 2: Network Reconnection (Reconexión de Red)

```swift
// Ya existe en NetworkSyncCoordinator (SPEC-OFFLINE)
actor NetworkSyncCoordinator {
    func startMonitoring() {
        monitoringTask = Task { [networkMonitor, offlineQueue] in
            let stream = await MainActor.run {
                networkMonitor.connectionStream()
            }

            for await isConnected in stream where isConnected {
                // �� Mejorar: Bidirectional Sync al reconectar
                await offlineSyncService.performBidirectionalSync()
            }
        }
    }
}
```

**Comportamiento**:
- Ejecutar Bidirectional Sync al detectar red
- Push cambios locales pendientes primero
- Luego Pull cambios del servidor
- Resolver conflictos si existen

---

#### Trigger 3: Background Fetch (iOS Background Tasks)

```swift
// Registrar background task en AppDelegate o App
func registerBackgroundTasks() {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.edugo.sync",
        using: nil
    ) { task in
        handleSyncTask(task: task as! BGAppRefreshTask)
    }
}

func handleSyncTask(task: BGAppRefreshTask) {
    let syncTask = Task {
        await OfflineSyncService.shared.performPullSync()
    }
    
    task.expirationHandler = {
        syncTask.cancel()
    }
    
    Task {
        await syncTask.value
        task.setTaskCompleted(success: true)
        scheduleNextSync()
    }
}

func scheduleNextSync() {
    let request = BGAppRefreshTaskRequest(identifier: "com.edugo.sync")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
    
    try? BGTaskScheduler.shared.submit(request)
}
```

**Frecuencia**: Cada 15 minutos (iOS determina el momento exacto)

**Nota**: Requiere `Background Modes` capability en Xcode.

---

#### Trigger 4: User Action (Pull-to-Refresh)

```swift
struct MaterialListView: View {
    @State private var syncService = OfflineSyncService.shared
    
    var body: some View {
        List {
            // ...
        }
        .refreshable {
            await syncService.performBidirectionalSync()
        }
    }
}
```

**Comportamiento**:
- Ejecutar Bidirectional Sync completo
- Mostrar spinner mientras sincroniza
- Mostrar toast con resultado ("X items sincronizados")

---

#### Trigger 5: Periodic Sync (Timer en Foreground)

```swift
actor PeriodicSyncManager {
    private var timer: Timer?
    
    func startPeriodicSync(interval: TimeInterval = 30 * 60) { // 30 min
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await OfflineSyncService.shared.performBidirectionalSync()
            }
        }
    }
    
    func stopPeriodicSync() {
        timer?.invalidate()
        timer = nil
    }
}
```

**Frecuencia**: Cada 30 minutos mientras la app está abierta

---

### 4.2 Triggers Manuales

| Acción del Usuario | Sync Type | Ubicación UI |
|--------------------|-----------|--------------|
| Pull-to-refresh | Bidirectional | MaterialListView, ProgressView |
| Botón "Sincronizar ahora" | Bidirectional | SettingsView → Sync section |
| Forzar resolución de conflicto | Push specific item | ConflictResolutionView |

---

## 5. Manejo de Conflictos

### 5.1 Tipos de Conflictos

#### Conflicto Tipo 1: Update-Update (Ambos modificaron el mismo dato)

**Escenario**:
- Usuario A actualiza progreso de Material X a 50% (offline)
- Usuario B (mismo usuario, otro dispositivo) actualiza a 75% (online)
- Usuario A reconecta y intenta sincronizar su 50%

**Detección**:
```swift
struct SyncConflict {
    let localData: Data
    let remoteData: Data
    let localTimestamp: Date
    let remoteTimestamp: Date
    let field: String // "progress"
}
```

**Estrategias de Resolución**:

| Estrategia | Descripción | Cuándo Usar |
|------------|-------------|-------------|
| **ServerWins** | Descartar cambios locales | Por defecto para materiales |
| **ClientWins** | Subir cambios locales | Cuando usuario confirma |
| **LastWriteWins** | El timestamp más reciente gana | Para progreso de lectura |
| **Merge** | Combinar ambos cambios | Para progreso (tomar el mayor) |
| **Manual** | Usuario decide | Para conflictos críticos |

---

#### Conflicto Tipo 2: Delete-Update (Uno eliminó, otro modificó)

**Escenario**:
- Material X fue eliminado en servidor (por admin)
- Usuario tiene Material X descargado y actualiza progreso offline
- Al sincronizar, servidor retorna 404 Not Found

**Resolución**:
- Marcar material como eliminado localmente
- Descartar cambios de progreso
- Notificar al usuario: "Material ya no está disponible"

---

#### Conflicto Tipo 3: Create-Create (Duplicados)

**Escenario**:
- Usuario crea nota/anotación offline
- Otro dispositivo crea la misma nota
- Al sincronizar, hay dos IDs diferentes para el mismo contenido

**Resolución**:
- Usar UUIDs determinísticos (basados en contenido hash)
- Backend deduplica por hash de contenido
- Cliente mantiene solo la versión del servidor

---

### 5.2 Algoritmo de Merge para Progreso

**Progreso de Lectura**: Tomar el **mayor** entre local y remoto

```swift
extension OfflineSyncService {
    func mergeProgress(
        local: PendingProgress,
        remote: RemoteProgress
    ) -> MergedProgress {
        // Regla 1: Tomar el progreso mayor
        let finalProgress = max(
            local.progressPercentage,
            remote.progressPercentage
        )
        
        // Regla 2: Sumar tiempo de lectura (no reemplazar)
        let finalTimeSpent = local.timeSpentSeconds + remote.timeSpentSeconds
        
        // Regla 3: Tomar la última página mayor
        let finalLastPage = max(local.lastPage, remote.lastPage)
        
        // Regla 4: Timestamp más reciente
        let finalTimestamp = max(local.updatedAt, remote.updatedAt)
        
        return MergedProgress(
            progressPercentage: finalProgress,
            timeSpentSeconds: finalTimeSpent,
            lastPage: finalLastPage,
            updatedAt: finalTimestamp
        )
    }
}
```

**Justificación**:
- Usuario nunca pierde progreso (siempre avanza)
- Tiempo de lectura es acumulativo
- Timestamp refleja actividad más reciente

---

### 5.3 UI para Resolución Manual de Conflictos

#### ConflictResolutionView

```swift
struct ConflictResolutionView: View {
    let conflict: SyncConflict
    let onResolve: (ConflictResolution) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Conflicto de Sincronización")
                .font(.title2)
                .bold()
            
            Text("Tus cambios locales difieren de los datos del servidor")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
            
            // Local changes
            VStack(alignment: .leading, spacing: 8) {
                Text("Tus Cambios (Local)")
                    .font(.headline)
                
                ConflictDataView(data: conflict.localData)
                
                Text("Modificado: \(conflict.localTimestamp.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Server changes
            VStack(alignment: .leading, spacing: 8) {
                Text("Datos del Servidor")
                    .font(.headline)
                
                ConflictDataView(data: conflict.remoteData)
                
                Text("Modificado: \(conflict.remoteTimestamp.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            Divider()
            
            // Actions
            VStack(spacing: 12) {
                Button {
                    onResolve(.clientWins)
                } label: {
                    Label("Usar Mis Cambios", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onResolve(.serverWins)
                } label: {
                    Label("Usar Datos del Servidor", systemImage: "icloud.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                if conflict.canMerge {
                    Button {
                        onResolve(.merge)
                    } label: {
                        Label("Combinar Ambos", systemImage: "arrow.triangle.merge")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
```

**Cuándo Mostrar**:
- Solo para conflictos de datos críticos (notas, anotaciones personalizadas)
- Para progreso: merge automático sin UI
- Para quiz attempts: serverWins automáticamente (score definitivo del backend)

---

## 6. Retry Policy

### 6.1 Política de Reintentos

#### Exponential Backoff con Jitter

```swift
actor RetryManager {
    private let maxRetries: Int = 5
    private let baseDelay: TimeInterval = 1.0 // 1 segundo
    private let maxDelay: TimeInterval = 60.0 // 60 segundos
    
    func calculateDelay(attempt: Int) -> TimeInterval {
        // Exponential: 2^attempt * baseDelay
        let exponentialDelay = pow(2.0, Double(attempt)) * baseDelay
        
        // Cap at maxDelay
        let cappedDelay = min(exponentialDelay, maxDelay)
        
        // Add jitter (±20% random)
        let jitter = cappedDelay * 0.2 * Double.random(in: -1...1)
        
        return cappedDelay + jitter
    }
    
    func shouldRetry(attempt: Int, error: Error) -> Bool {
        guard attempt < maxRetries else { return false }
        
        // Retry solo en errores transitorios
        if let networkError = error as? NetworkError {
            switch networkError {
            case .timeout, .connectionLost, .serverError:
                return true
            case .unauthorized, .forbidden, .notFound:
                return false // No reintentar en errores permanentes
            default:
                return true
            }
        }
        
        return true
    }
}
```

**Tabla de Delays**:

| Intento | Delay Base | Delay con Jitter |
|---------|------------|------------------|
| 1 | 2s | 1.6s - 2.4s |
| 2 | 4s | 3.2s - 4.8s |
| 3 | 8s | 6.4s - 9.6s |
| 4 | 16s | 12.8s - 19.2s |
| 5 | 32s | 25.6s - 38.4s |
| 6+ | 60s (max) | 48s - 72s |

---

### 6.2 Errores No Retryables

| Error | Código HTTP | Acción |
|-------|-------------|--------|
| Unauthorized | 401 | Refresh token, no retry |
| Forbidden | 403 | No retry, log out usuario |
| Not Found | 404 | No retry, marcar como eliminado |
| Unprocessable Entity | 422 | No retry, datos inválidos |
| Too Many Requests | 429 | Retry después de `Retry-After` header |

---

### 6.3 Circuit Breaker Pattern

Prevenir reintentos infinitos cuando el servidor está caído.

```swift
actor CircuitBreaker {
    enum State {
        case closed // Funcionando normal
        case open // Servidor caído, no intentar
        case halfOpen // Probando recuperación
    }
    
    private var state: State = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private let failureThreshold: Int = 5
    private let timeout: TimeInterval = 60.0 // 1 minuto
    
    func recordSuccess() {
        state = .closed
        failureCount = 0
    }
    
    func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        
        if failureCount >= failureThreshold {
            state = .open
        }
    }
    
    func canAttempt() -> Bool {
        switch state {
        case .closed:
            return true
            
        case .open:
            // Intentar recuperación después de timeout
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > timeout {
                state = .halfOpen
                return true
            }
            return false
            
        case .halfOpen:
            return true
        }
    }
}
```

**Uso**:
```swift
actor OfflineSyncService {
    private let circuitBreaker = CircuitBreaker()
    
    func syncProgress() async throws -> Int {
        guard await circuitBreaker.canAttempt() else {
            throw SyncError.serverUnavailable
        }
        
        do {
            let count = try await performSync()
            await circuitBreaker.recordSuccess()
            return count
        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }
}
```

---

## 7. Optimizaciones

### 7.1 Batch Updates (Actualización por Lotes)

En lugar de enviar 1 request por cada progreso, enviar todos juntos.

**Antes (Ineficiente)**:
```swift
// ❌ 10 requests para 10 progresos
for progress in pendingProgress {
    try await apiClient.updateProgress(progress)
}
```

**Después (Eficiente)**:
```swift
// ✅ 1 request para 10 progresos
let batch = pendingProgress.map { /* convert to DTO */ }
try await apiClient.bulkUpdateProgress(batch)
```

**Backend Endpoint**:
```
PUT /v1/sync/progress/bulk
{
  "updates": [
    { "material_id": "uuid1", "progress": 50.0, "time_spent": 300 },
    { "material_id": "uuid2", "progress": 75.0, "time_spent": 450 }
  ]
}
```

**Beneficios**:
- Reduce requests de N a 1
- Reduce latencia total
- Reduce uso de batería

---

### 7.2 Delta Sync (Solo Cambios)

Solo descargar materiales que cambiaron desde última sincronización.

**Request**:
```json
POST /v1/sync/materials/delta
{
  "last_sync_at": "2025-12-01T10:00:00Z",
  "material_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Response**:
```json
{
  "materials": [
    {
      "id": "uuid1",
      "title": "Material Actualizado",
      "updated_at": "2025-12-01T11:00:00Z",
      "version": 2
    }
  ],
  "deleted_material_ids": ["uuid5"],
  "server_timestamp": "2025-12-01T12:00:00Z"
}
```

**Implementación**:
```swift
actor OfflineSyncService {
    func performDeltaSync() async throws {
        // Obtener último timestamp de sync
        let lastSync = await getLastSyncTimestamp()
        
        // Request delta desde ese timestamp
        let delta = try await apiClient.getMaterialsDelta(since: lastSync)
        
        // Aplicar cambios localmente
        for material in delta.materials {
            await updateOrInsertMaterial(material)
        }
        
        // Eliminar materiales borrados en servidor
        for deletedId in delta.deletedMaterialIds {
            await deleteMaterial(id: deletedId)
        }
        
        // Actualizar timestamp
        await saveLastSyncTimestamp(delta.serverTimestamp)
    }
}
```

**Beneficios**:
- Reduce payload de red (solo cambios)
- Más rápido
- Menor uso de datos móviles

---

### 7.3 Compression (Compresión de Datos)

Comprimir payload de requests/responses grandes.

```swift
extension APIClient {
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        compression: Bool = true
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        
        if compression {
            request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        }
        
        // ...
    }
}
```

**Beneficios**:
- Reduce tamaño de transferencia en ~70%
- Más rápido en conexiones lentas
- Menor uso de datos

---

### 7.4 Paginación para Sync de Listas

No descargar 1000 materiales de una vez.

```swift
actor OfflineSyncService {
    func syncMaterials(pageSize: Int = 50) async throws {
        var page = 1
        var hasMore = true
        
        while hasMore {
            let response = try await apiClient.getMaterials(
                page: page,
                pageSize: pageSize
            )
            
            for material in response.materials {
                await updateOrInsertMaterial(material)
            }
            
            hasMore = response.hasMore
            page += 1
            
            // Yield control para evitar bloquear UI
            await Task.yield()
        }
    }
}
```

---

## 8. Arquitectura de Sincronización

### 8.1 Diagrama de Componentes

```
┌──────────────────────────────────────────────────────────────┐
│                         APP LAYER                             │
│  SwiftUI Views + ViewModels                                  │
│  - MaterialListView, ProgressView, SettingsView              │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────────────┐
│                    SYNC COORDINATOR                           │
│  Orquesta sincronización completa                            │
│                                                               │
│  - OfflineSyncService (actor)                                │
│    • performPullSync()                                        │
│    • performPushSync()                                        │
│    • performBidirectionalSync()                              │
│    • resolveConflicts()                                       │
└────┬────────┬────────┬────────┬────────────────────────────┘
     │        │        │        │
     ↓        ↓        ↓        ↓
┌─────────┬─────────┬─────────┬──────────────┐
│ Material│ Progress│  Quiz   │  Conflict    │
│ Sync    │  Sync   │  Sync   │  Resolver    │
│ Service │ Service │ Service │  (existing)  │
└────┬────┴────┬────┴────┬────┴────┬─────────┘
     │         │         │         │
     ↓         ↓         ↓         ↓
┌──────────────────────────────────────────────┐
│           DATA SOURCES LAYER                 │
│                                               │
│  Local:                  Remote:             │
│  - SwiftData             - APIClient         │
│  - FileManager           - URLSession        │
└──────────────────────────────────────────────┘
```

---

### 8.2 Flujo de Bidirectional Sync

```
1. PULL PHASE
   ├─ Request delta desde last_sync_at
   ├─ Recibir cambios del servidor
   ├─ Detectar conflictos (comparar con cambios locales)
   └─ Aplicar cambios no conflictivos
   
2. CONFLICT RESOLUTION PHASE
   ├─ Identificar items con conflicto
   ├─ Aplicar estrategia automática (merge, lastWriteWins)
   ├─ Si requiere manual: mostrar UI
   └─ Resolver todos los conflictos
   
3. PUSH PHASE
   ├─ Obtener items pendientes (needsSync = true)
   ├─ Batch updates (agrupar por tipo)
   ├─ Enviar al servidor
   ├─ Manejar errores (retry, circuit breaker)
   └─ Marcar como sincronizado
   
4. FINALIZATION
   ├─ Actualizar last_sync_at timestamp
   ├─ Limpiar items antiguos
   ├─ Notificar a UI con resultado
   └─ Log metrics
```

---

## 9. Implementación Detallada

### 9.1 MaterialSyncService

```swift
/// Servicio especializado en sincronización de materiales
actor MaterialSyncService {
    private let apiClient: APIClient
    private let localDataSource: LocalMaterialDataSource
    private let modelContext: ModelContext
    
    // MARK: - Pull Sync
    
    func pullMaterials(since lastSync: Date?) async throws -> Int {
        let delta = try await apiClient.getMaterialsDelta(since: lastSync)
        
        var updatedCount = 0
        
        // Actualizar/insertar materiales modificados
        for remoteMaterial in delta.materials {
            let local = await localDataSource.getMaterial(id: remoteMaterial.id)
            
            if let existing = local {
                // Actualizar
                existing.title = remoteMaterial.title
                existing.materialDescription = remoteMaterial.description
                existing.updatedAt = remoteMaterial.updatedAt
                existing.lastSyncedAt = Date()
                updatedCount += 1
            } else {
                // Insertar nuevo
                let cached = CachedMaterial(
                    id: remoteMaterial.id,
                    title: remoteMaterial.title,
                    materialDescription: remoteMaterial.description,
                    // ... otros campos
                )
                modelContext.insert(cached)
                updatedCount += 1
            }
        }
        
        // Eliminar materiales borrados en servidor
        for deletedId in delta.deletedMaterialIds {
            await localDataSource.deleteMaterial(id: deletedId)
        }
        
        try modelContext.save()
        
        return updatedCount
    }
    
    // MARK: - Push Sync
    
    func pushLocalChanges() async throws -> Int {
        // Materiales marcados como needsSync
        let pending = await localDataSource.getMaterialsNeedingSync()
        
        guard !pending.isEmpty else { return 0 }
        
        var syncedCount = 0
        
        for material in pending {
            do {
                try await apiClient.updateMaterial(material)
                material.needsSync = false
                material.lastSyncedAt = Date()
                syncedCount += 1
            } catch let error as NetworkError where error.isConflict {
                // Manejar conflicto (ver siguiente sección)
                try await handleConflict(material: material, error: error)
            }
        }
        
        try modelContext.save()
        
        return syncedCount
    }
    
    // MARK: - Conflict Handling
    
    private func handleConflict(
        material: CachedMaterial,
        error: NetworkError
    ) async throws {
        guard let remoteData = error.serverData else {
            throw SyncError.conflictWithoutServerData
        }
        
        let remoteMaterial = try JSONDecoder().decode(
            MaterialDTO.self,
            from: remoteData
        )
        
        // Estrategia: Server Wins (para materiales)
        material.title = remoteMaterial.title
        material.materialDescription = remoteMaterial.description
        material.updatedAt = remoteMaterial.updatedAt
        material.needsSync = false
        material.lastSyncedAt = Date()
    }
}
```

---

### 9.2 ProgressSyncService

```swift
/// Servicio especializado en sincronización de progreso de lectura
actor ProgressSyncService {
    private let apiClient: APIClient
    private let localDataSource: LocalProgressDataSource
    private let modelContext: ModelContext
    
    // MARK: - Pull Sync
    
    func pullProgress(since lastSync: Date?) async throws -> Int {
        let delta = try await apiClient.getProgressDelta(since: lastSync)
        
        var updatedCount = 0
        
        for remoteProgress in delta.progressItems {
            let local = await localDataSource.getProgress(
                materialId: remoteProgress.materialId,
                studentId: remoteProgress.studentId
            )
            
            if let existing = local {
                // Merge: tomar el mayor progreso
                let merged = mergeProgress(local: existing, remote: remoteProgress)
                existing.progressPercentage = merged.progressPercentage
                existing.timeSpentSeconds = merged.timeSpentSeconds
                existing.lastPage = merged.lastPage
                existing.updatedAt = merged.updatedAt
                existing.needsSync = false
                updatedCount += 1
            } else {
                // Insertar nuevo
                let pending = PendingProgress(
                    materialId: remoteProgress.materialId,
                    studentId: remoteProgress.studentId,
                    progressPercentage: remoteProgress.progressPercentage,
                    timeSpentSeconds: remoteProgress.timeSpentSeconds,
                    lastPage: remoteProgress.lastPage,
                    totalPages: remoteProgress.totalPages
                )
                pending.needsSync = false
                modelContext.insert(pending)
                updatedCount += 1
            }
        }
        
        try modelContext.save()
        
        return updatedCount
    }
    
    // MARK: - Push Sync (Batch)
    
    func pushLocalProgress() async throws -> Int {
        let pending = await localDataSource.getProgressNeedingSync()
        
        guard !pending.isEmpty else { return 0 }
        
        // Convertir a DTOs
        let dtos = pending.map { ProgressUpdateDTO(from: $0) }
        
        // Enviar en batch
        try await apiClient.bulkUpdateProgress(dtos)
        
        // Marcar todos como sincronizados
        for progress in pending {
            progress.markAsSynced()
        }
        
        try modelContext.save()
        
        return pending.count
    }
    
    // MARK: - Merge Logic
    
    private func mergeProgress(
        local: PendingProgress,
        remote: RemoteProgress
    ) -> MergedProgress {
        let finalProgress = max(
            local.progressPercentage,
            remote.progressPercentage
        )
        
        let finalTimeSpent = local.timeSpentSeconds + remote.timeSpentSeconds
        
        let finalLastPage = max(local.lastPage, remote.lastPage)
        
        let finalTimestamp = max(local.updatedAt, remote.updatedAt)
        
        return MergedProgress(
            progressPercentage: finalProgress,
            timeSpentSeconds: finalTimeSpent,
            lastPage: finalLastPage,
            updatedAt: finalTimestamp
        )
    }
}

// MARK: - DTOs

struct ProgressUpdateDTO: Codable {
    let materialId: UUID
    let studentId: UUID
    let progressPercentage: Double
    let timeSpentSeconds: Int
    let lastPage: Int
    
    init(from progress: PendingProgress) {
        self.materialId = progress.materialId
        self.studentId = progress.studentId
        self.progressPercentage = progress.progressPercentage
        self.timeSpentSeconds = progress.timeSpentSeconds
        self.lastPage = progress.lastPage
    }
}

struct MergedProgress {
    let progressPercentage: Double
    let timeSpentSeconds: Int
    let lastPage: Int
    let updatedAt: Date
}
```

---

### 9.3 QuizSyncService

```swift
/// Servicio especializado en sincronización de quiz attempts
actor QuizSyncService {
    private let apiClient: APIClient
    private let localDataSource: LocalQuizDataSource
    private let modelContext: ModelContext
    
    // MARK: - Push Sync (Batch)
    
    func pushQuizAttempts() async throws -> Int {
        let pending = await localDataSource.getAttemptsNeedingSync()
        
        guard !pending.isEmpty else { return 0 }
        
        var syncedCount = 0
        
        // Enviar en batch
        let dtos = pending.map { QuizAttemptDTO(from: $0) }
        let results = try await apiClient.bulkSubmitQuizAttempts(dtos)
        
        // Actualizar con resultados del servidor
        for (attempt, result) in zip(pending, results) {
            attempt.markAsSynced(
                serverAttemptId: result.attemptId,
                serverScore: result.score
            )
            syncedCount += 1
        }
        
        try modelContext.save()
        
        return syncedCount
    }
    
    // MARK: - Pull Sync
    
    func pullQuizResults(since lastSync: Date?) async throws -> Int {
        // Quiz attempts son create-only (no se modifican después)
        // Solo necesitamos verificar si alguno falló en el servidor
        
        let serverAttempts = try await apiClient.getQuizAttempts(since: lastSync)
        
        // Marcar como sincronizados los que existen en servidor
        for serverAttempt in serverAttempts {
            if let local = await localDataSource.getAttempt(id: serverAttempt.id) {
                local.markAsSynced(
                    serverAttemptId: serverAttempt.id,
                    serverScore: serverAttempt.score
                )
            }
        }
        
        try modelContext.save()
        
        return serverAttempts.count
    }
}

// MARK: - DTOs

struct QuizAttemptDTO: Codable {
    let materialId: UUID
    let assessmentId: UUID
    let studentId: UUID
    let answers: [[String: String]]
    let startedAt: Date
    let completedAt: Date
    let durationSeconds: Int
    
    init(from attempt: PendingQuizAttempt) {
        self.materialId = attempt.materialId
        self.assessmentId = attempt.assessmentId
        self.studentId = attempt.studentId
        self.answers = (try? JSONDecoder().decode(
            [[String: String]].self,
            from: attempt.answers
        )) ?? []
        self.startedAt = attempt.startedAt
        self.completedAt = attempt.completedAt
        self.durationSeconds = attempt.durationSeconds
    }
}

struct QuizAttemptResult: Codable {
    let attemptId: UUID
    let score: Double
    let correctAnswers: Int
    let totalQuestions: Int
}
```

---

### 9.4 OfflineSyncService (Orquestador)

```swift
/// Servicio principal que orquesta toda la sincronización
actor OfflineSyncService {
    static let shared = OfflineSyncService()
    
    private let materialSync: MaterialSyncService
    private let progressSync: ProgressSyncService
    private let quizSync: QuizSyncService
    private let conflictResolver: ConflictResolver
    private let retryManager: RetryManager
    private let circuitBreaker: CircuitBreaker
    private let networkMonitor: NetworkMonitor
    
    private var lastSyncTimestamp: Date?
    
    // MARK: - Public API
    
    /// Pull sync: descargar cambios del servidor
    func performPullSync() async throws {
        guard await networkMonitor.isConnected else {
            throw SyncError.noConnection
        }
        
        guard await circuitBreaker.canAttempt() else {
            throw SyncError.serverUnavailable
        }
        
        do {
            let materialCount = try await materialSync.pullMaterials(
                since: lastSyncTimestamp
            )
            
            let progressCount = try await progressSync.pullProgress(
                since: lastSyncTimestamp
            )
            
            let quizCount = try await quizSync.pullQuizResults(
                since: lastSyncTimestamp
            )
            
            lastSyncTimestamp = Date()
            
            await circuitBreaker.recordSuccess()
            
            logSyncMetrics(
                type: "pull",
                materials: materialCount,
                progress: progressCount,
                quiz: quizCount
            )
            
        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }
    
    /// Push sync: subir cambios locales al servidor
    func performPushSync() async throws {
        guard await networkMonitor.isConnected else {
            throw SyncError.noConnection
        }
        
        guard await circuitBreaker.canAttempt() else {
            throw SyncError.serverUnavailable
        }
        
        do {
            let progressCount = try await progressSync.pushLocalProgress()
            let quizCount = try await quizSync.pushQuizAttempts()
            
            await circuitBreaker.recordSuccess()
            
            logSyncMetrics(
                type: "push",
                progress: progressCount,
                quiz: quizCount
            )
            
        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }
    
    /// Bidirectional sync: pull + push completo
    func performBidirectionalSync() async throws {
        // 1. Pull primero (obtener últimos cambios del servidor)
        try await performPullSync()
        
        // 2. Push después (subir cambios locales)
        try await performPushSync()
    }
    
    /// Obtener cantidad de items pendientes de sincronización
    func pendingSyncCount() async -> Int {
        let progressCount = await progressSync.pendingCount()
        let quizCount = await quizSync.pendingCount()
        return progressCount + quizCount
    }
    
    // MARK: - Metrics
    
    private func logSyncMetrics(
        type: String,
        materials: Int = 0,
        progress: Int = 0,
        quiz: Int = 0
    ) {
        let total = materials + progress + quiz
        
        Logger.shared.info(
            "Sync \(type) completed",
            metadata: [
                "materials": materials,
                "progress": progress,
                "quiz": quiz,
                "total": total
            ]
        )
    }
}

// MARK: - Errors

enum SyncError: Error {
    case noConnection
    case serverUnavailable
    case conflictWithoutServerData
    case maxRetriesExceeded
}
```

---

## 10. Monitoreo y Debugging

### 10.1 Métricas de Sincronización

**Eventos a Trackear**:

| Métrica | Descripción | Importancia |
|---------|-------------|-------------|
| `sync.pull.success` | Pull sync exitoso | Alta |
| `sync.push.success` | Push sync exitoso | Alta |
| `sync.conflict.detected` | Conflicto detectado | Alta |
| `sync.conflict.resolved` | Conflicto resuelto | Alta |
| `sync.error.network` | Error de red | Alta |
| `sync.error.server` | Error de servidor | Alta |
| `sync.duration` | Duración de sync | Media |
| `sync.items.count` | Items sincronizados | Media |
| `sync.retry.attempt` | Reintento de sync | Media |

**Implementación con Observability**:
```swift
import EduGoObservability

actor OfflineSyncService {
    func performPullSync() async throws {
        let startTime = Date()
        
        MetricsTracker.shared.track(
            event: "sync.pull.start",
            metadata: [
                "last_sync": lastSyncTimestamp?.ISO8601Format() ?? "never"
            ]
        )
        
        do {
            // Sync logic...
            
            let duration = Date().timeIntervalSince(startTime)
            
            MetricsTracker.shared.track(
                event: "sync.pull.success",
                metadata: [
                    "duration_ms": Int(duration * 1000),
                    "items_synced": totalSynced
                ]
            )
            
        } catch {
            MetricsTracker.shared.track(
                event: "sync.pull.error",
                metadata: [
                    "error": String(describing: error)
                ]
            )
            
            throw error
        }
    }
}
```

---

### 10.2 Logging de Debug

```swift
extension OfflineSyncService {
    private func debugLog(
        _ message: String,
        metadata: [String: Any] = [:]
    ) {
        #if DEBUG
        let formattedMetadata = metadata
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ", ")
        
        print("[SyncService] \(message) | \(formattedMetadata)")
        #endif
    }
}
```

**Uso**:
```swift
debugLog("Starting pull sync", metadata: [
    "last_sync": lastSyncTimestamp ?? "never",
    "network": networkMonitor.isConnected
])
```

---

### 10.3 UI de Estado de Sincronización (Debug)

Para desarrollo y testing, mostrar estado detallado en Settings.

```swift
struct SyncDebugView: View {
    @State private var lastSync: Date?
    @State private var pendingCount: Int = 0
    @State private var isCircuitOpen: Bool = false
    
    var body: some View {
        List {
            Section("Estado de Sincronización") {
                LabeledContent("Última sincronización") {
                    Text(lastSync?.formatted() ?? "Nunca")
                }
                
                LabeledContent("Items pendientes") {
                    Text("\(pendingCount)")
                }
                
                LabeledContent("Circuit Breaker") {
                    Text(isCircuitOpen ? "ABIERTO" : "Cerrado")
                        .foregroundStyle(isCircuitOpen ? .red : .green)
                }
            }
            
            Section("Acciones") {
                Button("Forzar Pull Sync") {
                    Task {
                        try? await OfflineSyncService.shared.performPullSync()
                    }
                }
                
                Button("Forzar Push Sync") {
                    Task {
                        try? await OfflineSyncService.shared.performPushSync()
                    }
                }
                
                Button("Resetear Circuit Breaker") {
                    // ...
                }
            }
        }
        .navigationTitle("Sync Debug")
    }
}
```

---

## 11. Plan de Implementación

### Fase 1: Delta Sync y Batch Updates (Semana 1-2)

**Duración**: 10 días  
**Prioridad**: 🔴 P0

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 1.1 | Backend: Implementar endpoint `/sync/materials/delta` | 8h | Backend Dev |
| 1.2 | Backend: Implementar endpoint `/sync/progress/bulk` | 6h | Backend Dev |
| 1.3 | iOS: Implementar `MaterialSyncService.pullMaterials()` | 8h | iOS Dev |
| 1.4 | iOS: Implementar `ProgressSyncService.pushLocalProgress()` (batch) | 8h | iOS Dev |
| 1.5 | iOS: Actualizar `OfflineSyncService` para usar delta sync | 6h | iOS Dev |
| 1.6 | Tests unitarios de sync services | 12h | iOS Dev |
| 1.7 | Tests de integración con backend mock | 8h | iOS Dev + QA |

**Total**: 56h (7 días)

---

### Fase 2: Merge Logic y Conflict Resolution (Semana 2-3)

**Duración**: 8 días  
**Prioridad**: 🔴 P0

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 2.1 | Implementar `mergeProgress()` con lógica de mayor valor | 6h | iOS Dev |
| 2.2 | Implementar detección automática de conflictos | 8h | iOS Dev |
| 2.3 | Extender `ConflictResolver` con estrategias merge/lastWriteWins | 8h | iOS Dev |
| 2.4 | Implementar `ConflictResolutionView` UI | 12h | iOS Dev |
| 2.5 | Integrar resolución manual en flow de sync | 6h | iOS Dev |
| 2.6 | Tests unitarios de merge logic | 8h | iOS Dev |
| 2.7 | Tests de conflictos (simular conflictos reales) | 10h | iOS Dev + QA |

**Total**: 58h (7.25 días)

---

### Fase 3: Retry Policy y Circuit Breaker (Semana 3-4)

**Duración**: 5 días  
**Prioridad**: 🟡 P1

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 3.1 | Implementar `RetryManager` con exponential backoff | 6h | iOS Dev |
| 3.2 | Implementar `CircuitBreaker` pattern | 8h | iOS Dev |
| 3.3 | Integrar retry logic en `OfflineSyncService` | 6h | iOS Dev |
| 3.4 | Configurar errores no retryables | 3h | iOS Dev |
| 3.5 | Tests unitarios de retry y circuit breaker | 8h | iOS Dev |
| 3.6 | Tests de simulación de servidor caído | 6h | iOS Dev + QA |

**Total**: 37h (4.6 días)

---

### Fase 4: Background Sync y Periodic Sync (Semana 4-5)

**Duración**: 5 días  
**Prioridad**: 🟡 P1

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 4.1 | Configurar Background Tasks capability | 2h | iOS Dev |
| 4.2 | Implementar background fetch handler | 6h | iOS Dev |
| 4.3 | Implementar `PeriodicSyncManager` con timer | 4h | iOS Dev |
| 4.4 | Integrar con `NetworkSyncCoordinator` | 4h | iOS Dev |
| 4.5 | Tests de background sync (simular background) | 8h | iOS Dev + QA |
| 4.6 | Optimizar battery usage (profiling) | 6h | iOS Dev |

**Total**: 30h (3.75 días)

---

### Fase 5: Optimizaciones (Semana 5)

**Duración**: 4 días  
**Prioridad**: 🟢 P2

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 5.1 | Implementar compresión gzip en requests | 4h | iOS Dev |
| 5.2 | Implementar paginación en sync de listas | 6h | iOS Dev |
| 5.3 | Optimizar queries SwiftData (índices) | 4h | iOS Dev |
| 5.4 | Profiling y benchmarks de performance | 8h | iOS Dev |
| 5.5 | Optimizar uso de memoria en sync grandes | 6h | iOS Dev |

**Total**: 28h (3.5 días)

---

### Fase 6: Monitoreo y Logging (Semana 5-6)

**Duración**: 3 días  
**Prioridad**: 🟡 P1

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 6.1 | Integrar metrics tracking en sync services | 6h | iOS Dev |
| 6.2 | Implementar logging de debug detallado | 4h | iOS Dev |
| 6.3 | Crear `SyncDebugView` para testing | 6h | iOS Dev |
| 6.4 | Configurar analytics events | 4h | iOS Dev |

**Total**: 20h (2.5 días)

---

### Fase 7: Testing Completo (Semana 6-7)

**Duración**: 5 días  
**Prioridad**: 🔴 P0

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 7.1 | Tests end-to-end de flujo completo | 12h | iOS Dev + QA |
| 7.2 | Tests de edge cases (conflictos múltiples, etc.) | 8h | iOS Dev + QA |
| 7.3 | Tests de performance (1000+ items) | 6h | iOS Dev + QA |
| 7.4 | Tests en dispositivos reales (múltiples iOS versions) | 8h | QA |
| 7.5 | Regression testing de SPEC-OFFLINE | 6h | QA |

**Total**: 40h (5 días)

---

### Fase 8: Documentación y Deploy (Semana 7)

**Duración**: 2 días  
**Prioridad**: 🟢 P2

| # | Tarea | Estimación | Responsable |
|---|-------|-----------|-------------|
| 8.1 | Documentar APIs de sync services (DocC) | 4h | iOS Dev |
| 8.2 | Actualizar guía de usuario | 3h | Tech Writer |
| 8.3 | Crear troubleshooting guide | 3h | Tech Writer |
| 8.4 | Code review completo | 6h | Tech Lead |
| 8.5 | Merge y deploy a TestFlight | 2h | iOS Dev |

**Total**: 18h (2.25 días)

---

### Resumen Total

| Fase | Duración | Horas | Prioridad |
|------|----------|-------|-----------|
| Fase 1: Delta Sync y Batch | 7 días | 56h | 🔴 P0 |
| Fase 2: Merge y Conflicts | 7.25 días | 58h | 🔴 P0 |
| Fase 3: Retry y Circuit Breaker | 4.6 días | 37h | 🟡 P1 |
| Fase 4: Background Sync | 3.75 días | 30h | 🟡 P1 |
| Fase 5: Optimizaciones | 3.5 días | 28h | 🟢 P2 |
| Fase 6: Monitoreo | 2.5 días | 20h | 🟡 P1 |
| Fase 7: Testing | 5 días | 40h | 🔴 P0 |
| Fase 8: Documentación | 2.25 días | 18h | 🟢 P2 |

**TOTAL**: **35.85 días** (≈ **7 semanas**) | **287 horas**

**Nota**: Estimación para 1 desarrollador iOS senior + 1 backend developer + 1 QA. Con equipo completo, puede completarse en 5-6 semanas.

---

## Dependencias

### Dependencias de SPEC-OFFLINE (Prerrequisitos)

- ✅ CachedMaterial, DownloadTask, PendingProgress, PendingQuizAttempt (SwiftData models)
- ✅ DownloadManager, FileStorageService
- ✅ OfflineSyncService básico
- ✅ NetworkMonitor, NetworkSyncCoordinator
- ✅ ConflictResolver básico

### Dependencias de Backend

- ❌ `/v1/sync/materials/delta` endpoint
- ❌ `/v1/sync/progress/delta` endpoint
- ❌ `/v1/sync/progress/bulk` endpoint (PUT batch)
- ❌ `/v1/sync/quiz/bulk` endpoint (POST batch)
- ❌ Soporte para timestamps de sincronización
- ❌ Versioning de materiales

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Sincronización delta compleja de implementar | Alta | Alto | Empezar con full sync, migrar a delta después |
| Conflictos difíciles de reproducir en testing | Media | Alto | Crear herramienta de simulación de conflictos |
| Clock drift entre cliente y servidor | Media | Medio | Usar server timestamp en responses |
| Performance con muchos items pendientes | Media | Medio | Implementar paginación y batch size limits |
| Backend no listo a tiempo | Baja | Alto | Mock backend con Postman/Mockoon |

---

## Próximos Pasos

1. ✅ **Aprobar SPEC-SYNC** con equipo (Product, iOS, Backend)
2. 📝 **Sincronizar con equipo Backend** para APIs requeridas
3. 🎨 **Diseño UI de ConflictResolutionView** en Figma
4. 🚀 **Iniciar Fase 1** (Delta Sync y Batch Updates)
5. 📊 **Tracking en Linear/Jira** con todas las tareas

---

## Referencias

- **SPEC-OFFLINE**: `/docs/specs/ui-roadmap/specs-nuevos/SPEC-OFFLINE.md`
- **SPEC-013 (Offline-First UI)**: `/docs/specs/archived/completed-specs/offline-first/SPEC-013-COMPLETADO.md`
- **Database Analysis**: `/EDUGO_DATABASE_ANALYSIS.md`
- **Apple Documentation**:
  - [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
  - [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
  - [SwiftData Sync](https://developer.apple.com/documentation/swiftdata/syncing-data-across-devices)

---

**Versión**: 1.0  
**Fecha de Creación**: 1 de Diciembre, 2025  
**Autor**: Claude Code (AI Assistant)  
**Estado**: 📝 Especificación - Segunda Fase (Post SPEC-OFFLINE)
