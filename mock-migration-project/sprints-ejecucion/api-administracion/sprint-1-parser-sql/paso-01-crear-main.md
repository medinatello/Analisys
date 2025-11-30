# Paso 1: Crear CLI Principal con Cobra

**Duracion estimada:** 15 minutos
**Prerequisitos:** Sprint 0 completado

## Objetivo
Crear el punto de entrada del generador con CLI usando Cobra.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/cmd/main.go

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Crear cmd/main.go
```bash
cat > cmd/main.go << 'MAINEOF'
package main

import (
	"fmt"
	"os"
	"github.com/spf13/cobra"
)

var (
	testingDir string
	outputDir  string
)

var rootCmd = &cobra.Command{
	Use:   "mock-generator",
	Short: "Genera codigo Go desde scripts SQL de testing",
	Long:  "Parser de SQL que genera dataset mock para desarrollo frontend",
	Run:   runGenerator,
}

func init() {
	rootCmd.Flags().StringVar(&testingDir, "testing", "../../postgres/migrations/testing", "Directorio con SQL de testing")
	rootCmd.Flags().StringVar(&outputDir, "output", "../../mock/dataset", "Directorio de salida")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func runGenerator(cmd *cobra.Command, args []string) {
	fmt.Println("🔨 Mock Generator v1.0.0")
	fmt.Printf("📂 Testing dir: %s\n", testingDir)
	fmt.Printf("📁 Output dir: %s\n", outputDir)
	fmt.Println("⏳ Procesando...")
	
	// TODO: Implementar parser en siguiente paso
	fmt.Println("✅ Completado (stub)")
}
MAINEOF
```

## Codigo a Implementar

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/cmd/main.go`

```go
package main

import (
	"fmt"
	"os"
	"github.com/spf13/cobra"
)

var (
	testingDir string
	outputDir  string
)

var rootCmd = &cobra.Command{
	Use:   "mock-generator",
	Short: "Genera codigo Go desde scripts SQL de testing",
	Long:  "Parser de SQL que genera dataset mock para desarrollo frontend",
	Run:   runGenerator,
}

func init() {
	rootCmd.Flags().StringVar(&testingDir, "testing", "../../postgres/migrations/testing", "Directorio con SQL de testing")
	rootCmd.Flags().StringVar(&outputDir, "output", "../../mock/dataset", "Directorio de salida")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func runGenerator(cmd *cobra.Command, args []string) {
	fmt.Println("🔨 Mock Generator v1.0.0")
	fmt.Printf("📂 Testing dir: %s\n", testingDir)
	fmt.Printf("📁 Output dir: %s\n", outputDir)
	fmt.Println("⏳ Procesando...")
	
	// TODO: Implementar parser en siguiente paso
	fmt.Println("✅ Completado (stub)")
}
```

## Validacion

### Criterio de Exito
- [ ] Archivo cmd/main.go existe
- [ ] Archivo compila sin errores
- [ ] Codigo tiene 40-45 lineas

### Comandos de Validacion
```bash
test -f cmd/main.go && echo "OK: cmd/main.go existe"
go build -o bin/mock-generator cmd/main.go 2>&1 | head -5
test -f bin/mock-generator && echo "OK: Binario compilado"
```

### Output Esperado
```
OK: cmd/main.go existe
OK: Binario compilado
```

## Troubleshooting

**Problema:** Cannot find package cobra
**Solucion:** Ejecutar `go mod tidy` en el directorio raiz

**Problema:** Syntax error
**Solucion:** Copiar exactamente el codigo de arriba

## Siguiente Paso
→ [paso-02-crear-parser-basico.md]
