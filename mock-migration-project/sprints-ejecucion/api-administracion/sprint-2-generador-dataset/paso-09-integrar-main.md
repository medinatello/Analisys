# Paso 9: Integrar Generador con Main

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 8 completado

## Objetivo
Conectar generador con CLI principal.

## Codigo a Implementar

Modificar cmd/main.go, actualizar runGenerator:

```go
import (
	"fmt"
	"os"
	"github.com/spf13/cobra"
	"github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
	"github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/generator"
)

func runGenerator(cmd *cobra.Command, args []string) {
	fmt.Println("🔨 Mock Generator v1.0.0")
	fmt.Printf("📂 Testing dir: %s\n", testingDir)
	fmt.Printf("📁 Output dir: %s\n", outputDir)
	fmt.Println("")
	
	// Parser
	p := parser.NewSQLParser()
	fmt.Println("⏳ Parseando archivos SQL...")
	tables, err := p.ParseDirectory(testingDir)
	if err != nil {
		fmt.Printf("❌ Error parseando: %v\n", err)
		os.Exit(1)
	}
	
	fmt.Printf("✅ Parseados %d archivos SQL\n", len(tables))
	
	// Generador
	fmt.Println("\n⏳ Generando dataset...")
	gen := generator.NewDatasetGenerator(outputDir, tables)
	if err := gen.Generate(); err != nil {
		fmt.Printf("❌ Error generando: %v\n", err)
		os.Exit(1)
	}
	
	fmt.Println("✅ Dataset generado exitosamente")
	fmt.Printf("📁 Archivos en: %s\n", outputDir)
}
```

## Validacion

```bash
go build -o bin/mock-generator cmd/main.go
```

## Siguiente Paso
→ [paso-10-compilar-ejecutar.md]
