# Paso 8: Probar Imports y Dependencias

**Duración estimada:** 15 minutos
**Prerequisitos:** ✅ Paso 7 completado

## Objetivo
Crear archivo de prueba para validar imports del dataset.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Crear archivo de prueba
cat > internal/infrastructure/persistence/mock/dataset/dataset_test.go << 'TESTEOF'
package dataset

import (
    "testing"
)

func TestDatasetLoad(t *testing.T) {
    db := NewMockDatabase()
    
    if db == nil {
        t.Fatal("Database is nil")
    }
    
    db.LoadData()
    
    if len(db.Users) != 8 {
        t.Errorf("Expected 8 users, got %d", len(db.Users))
    }
    
    if len(db.Schools) != 3 {
        t.Errorf("Expected 3 schools, got %d", len(db.Schools))
    }
    
    if len(db.Materials) != 3 {
        t.Errorf("Expected 3 materials, got %d", len(db.Materials))
    }
}
TESTEOF

# Ejecutar test
go test ./internal/infrastructure/persistence/mock/dataset/ -v
```

**Output esperado:**
```
=== RUN   TestDatasetLoad
--- PASS: TestDatasetLoad (0.00s)
PASS
ok      github.com/EduGoGroup/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset
```

## Validación
- [ ] Test pasa correctamente
- [ ] 8 users cargados
- [ ] 3 schools cargadas
- [ ] 3 materials cargados

## Sprint 1 Completado ✅

**Resultado:**
- ✅ Dataset generado y copiado
- ✅ Package configurado correctamente
- ✅ Compila sin errores
- ✅ Test básico funciona
- ✅ Coherente con api-admin

## Siguiente Sprint
→ [../sprint-2-implementar-fixtures/README.md]
