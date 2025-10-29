# HU-ADM-USR-01: Crear Usuario del Sistema

**Como** administrador
**Quiero** crear un nuevo usuario con su rol y perfil
**Para** dar acceso al sistema a docentes, estudiantes o tutores

## Flujo
1. Admin accede a panel "Usuarios" → "Crear Usuario"
2. Admin completa formulario: nombre, email, rol (teacher/student/guardian), perfil específico
3. `POST /v1/users` con datos
4. API valida email único
5. API crea `app_user` + perfil correspondiente en transacción
6. API genera contraseña temporal segura
7. API envía email de bienvenida con credenciales temporales
8. Admin recibe confirmación con user_id

## Criterios
- Email único en sistema
- Perfil coherente con rol (teacher → teacher_profile)
- Contraseña temporal debe cambiarse en primer login
- Operación registrada en `audit_log`

## Request
```http
POST /v1/users
{
  "name": "María González",
  "email": "maria@example.com",
  "system_role": "teacher",
  "profile_data": {
    "specialization": "Matemáticas",
    "preferred_language": "es"
  }
}

Response 201: {"user_id": "uuid", "temporary_password": "Abc123!@#"}
```

**Prioridad**: Alta | **Estimación**: 5 puntos
