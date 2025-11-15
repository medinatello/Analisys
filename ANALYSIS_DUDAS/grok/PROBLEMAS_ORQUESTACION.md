Analisys/ANALYSIS_DUDAS/claude/PROBLEMAS_ORQUESTACION.md
# 🔄 Problemas de Orquestación Detectados

## Orden de Desarrollo

### Problemas Encontrados
1. **Dependencia circular potencial entre Worker y API-mobile**
   - Documentado: Worker genera assessments que API-mobile consume
   - Problema: API-mobile necesita assessments para funcionar, pero Worker depende de materiales creados por API-mobile
   - Solución: Implementar assessments "dummy" para desarrollo inicial, luego conectar Worker

2. **Publicación de edugo-shared requiere coordinación**
   - Documentado: Todos los proyectos requieren shared v1.3.0+
   - Problema: Cambios breaking en shared requieren actualizar todos los consumidores simultáneamente
   - Solución: Usar semantic versioning estricto y deprecation warnings

3. **Deployment order no considera dependencias de infraestructura**
   - Documentado: Dev-environment último
   - Problema: Cambios en APIs requieren actualizar Docker Compose
   - Solución: Automatizar updates de docker-compose.yml con cambios en APIs

## Dependencias

### Dependencias No Resueltas
- **OpenAI API quota management**: No hay estrategia para rate limiting distribuido
- **AWS S3 permissions**: Roles IAM no especificados para Worker
- **Database migrations**: No hay coordinación entre proyectos que comparten schemas
- **Message versioning**: Qué hacer cuando producer y consumer tienen versiones diferentes

### Dependencias Circulares
- **Configuración shared**: Projects dependen de shared, pero shared podría necesitar configuración de projects
- **Logging centralizado**: Worker envía logs, pero quién los consume para monitoring

## Desarrollo en Paralelo

### Qué SÍ se puede desarrollar en paralelo
- API-mobile y API-admin (mismo dominio pero diferentes endpoints)
- Worker processors individuales (summary vs quiz generation)
- Shared modules independientes (auth vs database vs messaging)
- Testing de cada proyecto (unit tests no requieren otros proyectos)

### Qué NO se puede desarrollar en paralelo
- Cualquier cosa que toque schemas compartidos (PostgreSQL tables)
- Cambios en edugo-shared (requiere rebuild de todos)
- Message contracts entre API y Worker
- End-to-end testing (requiere todos los componentes)