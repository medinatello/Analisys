# Paso 3: Implementar ParseDirectory

**Duracion estimada:** 20 minutos
**Prerequisitos:** Paso 2 completado

## Objetivo
Implementar la funcion que lee todos los archivos SQL de un directorio.

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/sql_parser.go

## Codigo a Implementar

Reemplazar el metodo `ParseDirectory` en sql_parser.go:

```go
func (sp *SQLParser) ParseDirectory(dir string) (map[string]*TableData, error) {
	result := make(map[string]*TableData)
	
	// Listar archivos .sql
	files, err := filepath.Glob(filepath.Join(dir, "*.sql"))
	if err != nil {
		return nil, fmt.Errorf("error listando archivos: %w", err)
	}
	
	// Parsear cada archivo
	for _, file := range files {
		content, err := os.ReadFile(file)
		if err != nil {
			continue // Skip archivos que no se pueden leer
		}
		
		// Parsear SQL
		stmts, _, err := sp.p.Parse(string(content), "", "")
		if err != nil {
			continue // Skip archivos con errores de sintaxis
		}
		
		// Extraer INSERT statements
		for _, stmt := range stmts {
			if insert, ok := stmt.(*ast.InsertStmt); ok {
				data := sp.extractInsertData(insert)
				result[data.Table] = data
			}
		}
	}
	
	return result, nil
}
```

Agregar imports necesarios al inicio del archivo:

```go
import (
	"fmt"
	"os"
	"path/filepath"
	"github.com/pingcap/tidb/parser"
	"github.com/pingcap/tidb/parser/ast"
	_ "github.com/pingcap/tidb/parser/test_driver"
)
```

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Editar sql_parser.go - reemplazar imports
cat > pkg/parser/sql_parser.go << 'PARSEREOF'
package parser

import (
	"fmt"
	"os"
	"path/filepath"
	"github.com/pingcap/tidb/parser"
	"github.com/pingcap/tidb/parser/ast"
	_ "github.com/pingcap/tidb/parser/test_driver"
)

type SQLParser struct {
	p *parser.Parser
}

func NewSQLParser() *SQLParser {
	return &SQLParser{
		p: parser.New(),
	}
}

func (sp *SQLParser) ParseDirectory(dir string) (map[string]*TableData, error) {
	result := make(map[string]*TableData)
	
	files, err := filepath.Glob(filepath.Join(dir, "*.sql"))
	if err != nil {
		return nil, fmt.Errorf("error listando archivos: %w", err)
	}
	
	for _, file := range files {
		content, err := os.ReadFile(file)
		if err != nil {
			continue
		}
		
		stmts, _, err := sp.p.Parse(string(content), "", "")
		if err != nil {
			continue
		}
		
		for _, stmt := range stmts {
			if insert, ok := stmt.(*ast.InsertStmt); ok {
				data := sp.extractInsertData(insert)
				result[data.Table] = data
			}
		}
	}
	
	return result, nil
}

func (sp *SQLParser) extractInsertData(insert *ast.InsertStmt) *TableData {
	// TODO: Implementar en paso 4
	return &TableData{
		Table:   "stub",
		Columns: []string{},
		Rows:    [][]interface{}{},
	}
}
PARSEREOF
```

## Validacion

### Criterio de Exito
- [ ] Codigo compila sin errores
- [ ] Imports incluyen filepath y os
- [ ] Metodo ParseDirectory implementado

### Comandos de Validacion
```bash
go build ./pkg/parser
echo $?
# Output esperado: 0
```

## Siguiente Paso
→ [paso-04-extraer-insert-data.md]
