# Paso 2: Crear Estructura del Parser

**Duracion estimada:** 20 minutos
**Prerequisitos:** Paso 1 completado

## Objetivo
Crear la estructura basica del parser SQL con tipos de datos.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/sql_parser.go
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/types.go

## Codigo a Implementar

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/types.go`

```go
package parser

// TableData contiene los datos extraidos de un INSERT
type TableData struct {
	Table   string
	Columns []string
	Rows    [][]interface{}
}
```

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/sql_parser.go`

```go
package parser

import (
	"github.com/pingcap/tidb/parser"
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

// ParseDirectory parseara un directorio en el siguiente paso
func (sp *SQLParser) ParseDirectory(dir string) (map[string]*TableData, error) {
	// TODO: Implementar en paso 3
	return make(map[string]*TableData), nil
}
```

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Crear types.go
cat > pkg/parser/types.go << 'TYPES'
package parser

type TableData struct {
	Table   string
	Columns []string
	Rows    [][]interface{}
}
TYPES

# Crear sql_parser.go
cat > pkg/parser/sql_parser.go << 'PARSER'
package parser

import (
	"github.com/pingcap/tidb/parser"
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
	return make(map[string]*TableData), nil
}
PARSER
```

## Validacion

### Criterio de Exito
- [ ] Archivo pkg/parser/types.go existe
- [ ] Archivo pkg/parser/sql_parser.go existe
- [ ] Archivos compilan sin errores

### Comandos de Validacion
```bash
test -f pkg/parser/types.go && echo "OK: types.go existe"
test -f pkg/parser/sql_parser.go && echo "OK: sql_parser.go existe"
go build ./pkg/parser
echo $?
# Output esperado: 0
```

## Siguiente Paso
→ [paso-03-implementar-parse-directory.md]
