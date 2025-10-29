# HU-ADM-JER-01: Crear Unidad Académica

**Como** administrador o docente owner
**Quiero** crear una unidad académica en la jerarquía
**Para** organizar estudiantes y materiales por año, sección o club

## Flujo
1. Admin/Docente accede a "Jerarquía" → "Crear Unidad"
2. Admin selecciona unidad padre (o null para raíz)
3. Admin completa: tipo (grade/section/club), nombre, código
4. `POST /v1/units` con datos
5. API valida permisos (admin o owner de unidad padre)
6. API valida jerarquía (trigger previene ciclos)
7. API crea `academic_unit`
8. API asigna automáticamente al creador como `owner` si es docente

## Criterios
- Trigger previene jerarquía circular
- Código único por escuela
- Crear hijo requiere ser owner del padre

## Request
```http
POST /v1/units
{
  "parent_unit_id": "uuid-school",
  "school_id": "uuid-school",
  "unit_type": "grade",
  "display_name": "5.º Año",
  "code": "5TO"
}

Response 201: {"unit_id": "uuid", "display_name": "5.º Año"}
```

**Prioridad**: Alta | **Estimación**: 5 puntos
