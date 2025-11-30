# Paso 4: Extraer Datos de INSERT

**Duracion estimada:** 25 minutos
**Prerequisitos:** Paso 3 completado

## Objetivo
Implementar extraccion de nombre de tabla, columnas y valores desde INSERT statements.

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/sql_parser.go

## Codigo a Implementar

Reemplazar el metodo `extractInsertData`:

```go
func (sp *SQLParser) extractInsertData(insert *ast.InsertStmt) *TableData {
	// Extraer nombre de tabla
	tableName := insert.Table.TableRefs.Left.(*ast.TableSource).Source.(*ast.TableName).Name.O
	
	// Extraer columnas
	var columns []string
	for _, col := range insert.Columns {
		columns = append(columns, col.Name.O)
	}
	
	// Extraer valores
	var rows [][]interface{}
	for _, list := range insert.Lists {
		var row []interface{}
		for _, expr := range list {
			val := sp.evalExpr(expr)
			row = append(row, val)
		}
		rows = append(rows, row)
	}
	
	return &TableData{
		Table:   tableName,
		Columns: columns,
		Rows:    rows,
	}
}

func (sp *SQLParser) evalExpr(expr ast.ExprNode) interface{} {
	// TODO: Implementar en paso 5
	return "stub"
}
```

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Agregar metodo extractInsertData completo al archivo
# (Reemplazar el stub anterior)
```

## Validacion

### Criterio de Exito
- [ ] Codigo compila sin errores
- [ ] Metodo extractInsertData implementado
- [ ] Metodo evalExpr stub creado

### Comandos de Validacion
```bash
go build ./pkg/parser
grep -q "extractInsertData" pkg/parser/sql_parser.go && echo "OK: extractInsertData presente"
grep -q "evalExpr" pkg/parser/sql_parser.go && echo "OK: evalExpr presente"
```

## Siguiente Paso
→ [paso-05-evaluar-expresiones.md]
