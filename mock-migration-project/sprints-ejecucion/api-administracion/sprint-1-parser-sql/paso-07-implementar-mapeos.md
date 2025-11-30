# Paso 7: Integrar Parser con Main

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 6 completado

## Objetivo
Conectar el parser con el CLI principal para mostrar estadisticas.

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/cmd/main.go

## Codigo a Implementar

Reemplazar la funcion `runGenerator` en cmd/main.go:

```go
import (
	"fmt"
	"os"
	"github.com/spf13/cobra"
	"github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
)

func runGenerator(cmd *cobra.Command, args []string) {
	fmt.Println("🔨 Mock Generator v1.0.0")
	fmt.Printf("📂 Testing dir: %s\n", testingDir)
	fmt.Printf("📁 Output dir: %s\n", outputDir)
	fmt.Println("")
	
	// Crear parser
	p := parser.NewSQLParser()
	
	// Parsear directorio
	fmt.Println("⏳ Parseando archivos SQL...")
	tables, err := p.ParseDirectory(testingDir)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		os.Exit(1)
	}
	
	// Mostrar estadisticas
	fmt.Printf("\n✅ Parseados %d archivos SQL\n\n", len(tables))
	fmt.Println("Estadisticas por tabla:")
	for tableName, data := range tables {
		fmt.Printf("  - %-20s: %d registros, %d columnas\n", 
			tableName, len(data.Rows), len(data.Columns))
	}
	
	fmt.Println("\n✨ Analisis completado")
}
```

## Validacion

### Criterio de Exito
- [ ] Import de pkg/parser agregado
- [ ] Funcion runGenerator actualizada
- [ ] Codigo compila

### Comandos de Validacion
```bash
go build -o bin/mock-generator cmd/main.go
test -f bin/mock-generator && echo "OK: Binario compilado"
```

## Siguiente Paso
→ [paso-08-compilar-binario.md]
