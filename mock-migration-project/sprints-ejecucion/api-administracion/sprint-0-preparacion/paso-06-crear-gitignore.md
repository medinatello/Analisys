# Paso 6: Configurar .gitignore

**Duracion estimada:** 3 minutos
**Prerequisitos:** Paso 5 completado

## Objetivo
Crear archivo .gitignore para excluir archivos generados y temporales.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/.gitignore

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Crear .gitignore
```bash
cat > .gitignore << 'GITIGNORE'
# Binarios
bin/
*.exe
mock-generator

# Go
*.test
*.out
coverage.txt

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Temporales
tmp/
temp/
*.log
GITIGNORE
```

### 3. Verificar contenido
```bash
cat .gitignore
```

## Codigo a Implementar

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/.gitignore`
```
# Binarios
bin/
*.exe
mock-generator

# Go
*.test
*.out
coverage.txt

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Temporales
tmp/
temp/
*.log
```

## Validacion

### Criterio de Exito
- [ ] Archivo .gitignore existe
- [ ] Archivo contiene reglas para bin/
- [ ] Archivo contiene reglas para archivos temporales

### Comandos de Validacion
```bash
test -f .gitignore && echo "OK: .gitignore existe" || echo "ERROR: .gitignore no existe"
grep "bin/" .gitignore && echo "OK: regla bin/ presente"
grep ".DS_Store" .gitignore && echo "OK: regla .DS_Store presente"
```

## Troubleshooting

**Problema:** Archivo no se crea
**Solucion:** Verificar permisos de escritura

## Sprint Completado

Has completado el Sprint 0. Tu ambiente esta listo para comenzar el desarrollo.

## Siguiente Sprint
→ [../sprint-1-parser-sql/README.md]
