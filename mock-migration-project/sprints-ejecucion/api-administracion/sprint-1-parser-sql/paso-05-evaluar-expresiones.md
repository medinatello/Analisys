# Paso 5: Evaluar Expresiones SQL

**Duracion estimada:** 20 minutos
**Prerequisitos:** Paso 4 completado

## Objetivo
Implementar evaluacion de valores literales y funciones SQL (NOW(), UUID, etc).

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/sql_parser.go

## Codigo a Implementar

Reemplazar el metodo `evalExpr`:

```go
func (sp *SQLParser) evalExpr(expr ast.ExprNode) interface{} {
	switch e := expr.(type) {
	case *ast.ValueExpr:
		// Valores literales (strings, numeros, booleans)
		datum := e.GetDatumString()
		cleaned := strings.Trim(datum, "'")
		return cleaned
		
	case *ast.FuncCallExpr:
		// Funciones SQL
		funcName := strings.ToLower(e.FnName.L)
		switch funcName {
		case "now":
			return "NOW()"
		case "gen_random_uuid":
			return "UUID()"
		case "current_date":
			return "CURRENT_DATE()"
		default:
			return fmt.Sprintf("FUNC(%s)", funcName)
		}
		
	default:
		return ""
	}
}
```

Agregar import de `strings`:

```go
import (
	"fmt"
	"os"
	"path/filepath"
	"strings"  // AGREGAR ESTA LINEA
	"github.com/pingcap/tidb/parser"
	"github.com/pingcap/tidb/parser/ast"
	_ "github.com/pingcap/tidb/parser/test_driver"
)
```

## Validacion

### Criterio de Exito
- [ ] Codigo compila sin errores
- [ ] Metodo evalExpr maneja ValueExpr
- [ ] Metodo evalExpr maneja FuncCallExpr

### Comandos de Validacion
```bash
go build ./pkg/parser
grep -q "case \*ast.ValueExpr" pkg/parser/sql_parser.go && echo "OK: Maneja ValueExpr"
grep -q "case \*ast.FuncCallExpr" pkg/parser/sql_parser.go && echo "OK: Maneja FuncCallExpr"
```

## Siguiente Paso
→ [paso-06-crear-tipos.md]
