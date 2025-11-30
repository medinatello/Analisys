# Paso 1: Crear Estructura Base del Generador

**Duracion estimada:** 15 minutos
**Prerequisitos:** Sprint 1 completado

## Objetivo
Crear la estructura basica del generador de dataset.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/generator/dataset_generator.go

## Codigo a Implementar

```go
package generator

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"text/template"
	"github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
)

type DatasetGenerator struct {
	outputDir string
	tables    map[string]*parser.TableData
}

func NewDatasetGenerator(outputDir string, tables map[string]*parser.TableData) *DatasetGenerator {
	return &DatasetGenerator{
		outputDir: outputDir,
		tables:    tables,
	}
}

func (g *DatasetGenerator) Generate() error {
	// Crear directorio de salida
	if err := os.MkdirAll(g.outputDir, 0755); err != nil {
		return fmt.Errorf("error creando directorio: %w", err)
	}
	
	// TODO: Generar archivos (siguientes pasos)
	
	return nil
}
```

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

cat > pkg/generator/dataset_generator.go << 'GENEOF'
package generator

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"text/template"
	"github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
)

type DatasetGenerator struct {
	outputDir string
	tables    map[string]*parser.TableData
}

func NewDatasetGenerator(outputDir string, tables map[string]*parser.TableData) *DatasetGenerator {
	return &DatasetGenerator{
		outputDir: outputDir,
		tables:    tables,
	}
}

func (g *DatasetGenerator) Generate() error {
	if err := os.MkdirAll(g.outputDir, 0755); err != nil {
		return fmt.Errorf("error creando directorio: %w", err)
	}
	return nil
}
GENEOF
```

## Validacion

### Criterio de Exito
- [ ] Archivo pkg/generator/dataset_generator.go existe
- [ ] Struct DatasetGenerator definida
- [ ] Metodo Generate existe

### Comandos de Validacion
```bash
test -f pkg/generator/dataset_generator.go && echo "OK: dataset_generator.go existe"
go build ./pkg/generator
```

## Siguiente Paso
→ [paso-02-template-database.md]
