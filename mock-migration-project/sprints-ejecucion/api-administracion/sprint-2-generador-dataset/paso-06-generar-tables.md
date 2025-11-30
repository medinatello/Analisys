# Paso 6: Implementar Generacion de Tablas

**Duracion estimada:** 25 minutos
**Prerequisitos:** Paso 5 completado

## Objetivo
Generar archivo *_table.go para cada tabla.

## Codigo a Implementar

```go
func (g *DatasetGenerator) generateTables() error {
	for tableName := range g.tables {
		if err := g.generateTable(tableName); err != nil {
			return err
		}
	}
	return nil
}

func (g *DatasetGenerator) generateTable(tableName string) error {
	tmpl, err := template.New("table").Parse(tableTemplate)
	if err != nil {
		return err
	}
	
	data := struct {
		TableCamel string
		EntityName string
	}{
		TableCamel: toCamelCase(tableName),
		EntityName: getEntityName(tableName),
	}
	
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return err
	}
	
	filename := filepath.Join(g.outputDir, tableName+"_table.go")
	return os.WriteFile(filename, buf.Bytes(), 0644)
}

func getEntityName(table string) string {
	mapping := map[string]string{
		"users":           "User",
		"schools":         "School",
		"academic_units":  "AcademicUnit",
		"memberships":     "Membership",
		"materials":       "Material",
	}
	if entity, ok := mapping[table]; ok {
		return entity
	}
	return toCamelCase(table)
}
```

Actualizar Generate():

```go
func (g *DatasetGenerator) Generate() error {
	if err := os.MkdirAll(g.outputDir, 0755); err != nil {
		return fmt.Errorf("error creando directorio: %w", err)
	}
	
	if err := g.generateDatabase(); err != nil {
		return fmt.Errorf("error generando database.go: %w", err)
	}
	
	if err := g.generateTables(); err != nil {
		return fmt.Errorf("error generando tablas: %w", err)
	}
	
	return nil
}
```

## Validacion

```bash
go build ./pkg/generator
```

## Siguiente Paso
→ [paso-07-generar-loader.md]
