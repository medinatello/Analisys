# Paso 5: Implementar Generacion de database.go

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 4 completado

## Objetivo
Implementar metodo que ejecuta template de database.go.

## Codigo a Implementar

Ya implementado en paso 2, ahora integrar en Generate():

```go
func (g *DatasetGenerator) Generate() error {
	if err := os.MkdirAll(g.outputDir, 0755); err != nil {
		return fmt.Errorf("error creando directorio: %w", err)
	}
	
	// Generar database.go
	if err := g.generateDatabase(); err != nil {
		return fmt.Errorf("error generando database.go: %w", err)
	}
	
	return nil
}
```

## Validacion

```bash
go build ./pkg/generator
```

## Siguiente Paso
→ [paso-06-generar-tables.md]
