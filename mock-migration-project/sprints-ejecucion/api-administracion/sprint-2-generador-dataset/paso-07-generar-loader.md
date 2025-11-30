# Paso 7: Implementar Generacion de Loader

**Duracion estimada:** 20 minutos
**Prerequisitos:** Paso 6 completado

## Objetivo
Generar load_data.go con funciones de carga por tabla.

## Codigo a Implementar

```go
func (g *DatasetGenerator) generateLoader() error {
	tmpl, err := template.New("loader").Parse(loaderTemplate)
	if err != nil {
		return err
	}
	
	var tables []struct{ Name string }
	for tableName := range g.tables {
		tables = append(tables, struct{ Name string }{
			Name: toCamelCase(tableName),
		})
	}
	
	data := struct {
		Tables []struct{ Name string }
	}{
		Tables: tables,
	}
	
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return err
	}
	
	filename := filepath.Join(g.outputDir, "load_data.go")
	return os.WriteFile(filename, buf.Bytes(), 0644)
}
```

Actualizar Generate():

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
	
	return nil
}
```

## Siguiente Paso
→ [paso-08-formatear-codigo.md]
