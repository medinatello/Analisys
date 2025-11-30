# Paso 6: Crear Mapeos de Tipos

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 5 completado

## Objetivo
Crear archivo con mapeos de tablas SQL a entities Go.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/types/mappings.go

## Codigo a Implementar

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/types/mappings.go`

```go
package types

// TableToEntity mapea nombre de tabla SQL a nombre de entity Go
var TableToEntity = map[string]string{
	"users":              "User",
	"schools":            "School",
	"academic_units":     "AcademicUnit",
	"memberships":        "Membership",
	"materials":          "Material",
	"subjects":           "Subject",
	"units":              "Unit",
	"guardian_relations": "GuardianRelation",
}

// TableToCamel convierte nombre de tabla a CamelCase para estructuras
var TableToCamel = map[string]string{
	"users":              "Users",
	"schools":            "Schools",
	"academic_units":     "AcademicUnits",
	"memberships":        "Memberships",
	"materials":          "Materials",
	"subjects":           "Subjects",
	"units":              "Units",
	"guardian_relations": "GuardianRelations",
}

// GetEntityName retorna el nombre de la entity para una tabla
func GetEntityName(table string) string {
	if entity, ok := TableToEntity[table]; ok {
		return entity
	}
	return table
}

// GetTableCamel retorna el nombre CamelCase para una tabla
func GetTableCamel(table string) string {
	if camel, ok := TableToCamel[table]; ok {
		return camel
	}
	return table
}
```

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

cat > pkg/types/mappings.go << 'MAPPINGSEOF'
package types

var TableToEntity = map[string]string{
	"users":              "User",
	"schools":            "School",
	"academic_units":     "AcademicUnit",
	"memberships":        "Membership",
	"materials":          "Material",
	"subjects":           "Subject",
	"units":              "Unit",
	"guardian_relations": "GuardianRelation",
}

var TableToCamel = map[string]string{
	"users":              "Users",
	"schools":            "Schools",
	"academic_units":     "AcademicUnits",
	"memberships":        "Memberships",
	"materials":          "Materials",
	"subjects":           "Subjects",
	"units":              "Units",
	"guardian_relations": "GuardianRelations",
}

func GetEntityName(table string) string {
	if entity, ok := TableToEntity[table]; ok {
		return entity
	}
	return table
}

func GetTableCamel(table string) string {
	if camel, ok := TableToCamel[table]; ok {
		return camel
	}
	return table
}
MAPPINGSEOF
```

## Validacion

### Criterio de Exito
- [ ] Archivo pkg/types/mappings.go existe
- [ ] Contiene mapa TableToEntity
- [ ] Contiene mapa TableToCamel
- [ ] Codigo compila

### Comandos de Validacion
```bash
test -f pkg/types/mappings.go && echo "OK: mappings.go existe"
go build ./pkg/types
grep -q "TableToEntity" pkg/types/mappings.go && echo "OK: TableToEntity presente"
```

## Siguiente Paso
→ [paso-07-implementar-mapeos.md]
