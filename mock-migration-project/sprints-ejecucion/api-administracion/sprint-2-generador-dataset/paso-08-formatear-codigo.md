# Paso 8: Formatear Codigo Generado

**Duracion estimada:** 10 minutos
**Prerequisitos:** Paso 7 completado

## Objetivo
Aplicar gofmt a todos los archivos generados.

## Codigo a Implementar

Agregar al final de Generate():

```go
func (g *DatasetGenerator) Generate() error {
	os.MkdirAll(g.outputDir, 0755)
	
	if err := g.generateDatabase(); err != nil {
		return err
	}
	
	if err := g.generateTables(); err != nil {
		return err
	}
	
	if err := g.generateLoader(); err != nil {
		return err
	}
	
	// Formatear codigo
	cmd := exec.Command("gofmt", "-w", g.outputDir)
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error formateando codigo: %w", err)
	}
	
	return nil
}
```

## Validacion

```bash
go build ./pkg/generator
```

## Siguiente Paso
→ [paso-09-integrar-main.md]
