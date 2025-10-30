# 🔐 Manejo de Secretos - EduGo

Guía completa para trabajar con secretos de forma segura en todos los ambientes.

---

## 📋 ÍNDICE

1. [¿Qué es SOPS?](#qué-es-sops)
2. [¿Por qué SOPS + Age?](#por-qué-sops--age)
3. [Setup Inicial (Cada Developer)](#setup-inicial-cada-developer)
4. [Workflow por Ambiente](#workflow-por-ambiente)
5. [Comandos Útiles](#comandos-útiles)
6. [Troubleshooting](#troubleshooting)

---

## 🤔 ¿Qué es SOPS?

**SOPS** = **S**ecrets **OP**eration**S** (por Mozilla)

Es una herramienta que permite **encriptar archivos de secretos** para commitearlos de forma segura en git.

### Problema que Resuelve

**❌ Sin SOPS**:
```bash
# .env.prod (NO se puede commitear - secretos expuestos)
POSTGRES_PASSWORD=super_secret_password_123
MONGODB_URI=mongodb://admin:real_password@prod/edugo
OPENAI_API_KEY=sk-proj-real-production-key
```

- ❌ Si lo commiteas: Secretos expuestos en GitHub
- ❌ Si no lo commiteas: Cada developer pide secretos manualmente
- ❌ Cambios de secretos: No trackeados
- ❌ Rotación: Difícil coordinar

**✅ Con SOPS**:
```bash
# .env.prod.enc (encriptado - PUEDE commitarse)
{
    "data": "ENC[AES256_GCM,data:encrypted_data_here...]",
    "sops": {
        "age": [{
            "recipient": "age1ql3z7hjy54pw3hyww5...",
            "enc": "..."
        }]
    }
}
```

- ✅ Secretos encriptados en git
- ✅ Versionados (git history)
- ✅ Auditables (quién cambió qué)
- ✅ Rotación fácil (editar, encriptar, commitear)

---

## 🔑 ¿Qué es Age?

**Age** = **A**ctually **G**ood **E**ncryption

Algoritmo de encriptación moderno y simple (por Google).

### Ventajas sobre GPG

| Característica | Age | GPG |
|----------------|-----|-----|
| **Simplicidad** | ✅ 1 comando | ❌ Complejo |
| **Tamaño de clave** | 62 chars | 4096+ chars |
| **Setup** | 1 minuto | 15 minutos |
| **Performance** | Rápido | Lento |
| **Curva de aprendizaje** | Baja | Alta |

### Cómo Funciona Age

```
Developer 1               Developer 2
├─ Clave Privada          ├─ Clave Privada (diferente)
│  (secreta, NO compartir) │  (secreta, NO compartir)
│                          │
└─ Clave Pública          └─ Clave Pública (diferente)
   (compartir con equipo)    (compartir con equipo)

         ↓                          ↓
         
      .sops.yaml (en git)
      ├─ age: "clave_publica_dev1"
      └─ age: "clave_publica_dev2"
      
         ↓
         
   .env.dev (valores reales)
         ↓
   SOPS encripta para AMBOS
         ↓
   .env.dev.enc (ambos pueden desencriptar)
```

**✅ Cada developer puede desencriptar** con su propia clave privada
**✅ Un solo archivo encriptado** funciona para todos

---

## 🚀 Setup Inicial (Cada Developer)

### 1. Instalar SOPS + Age

```bash
# Ejecutar script de setup
./scripts/secrets/setup-sops.sh

# Esto instala:
# - SOPS (encriptador)
# - Age (algoritmo de encriptación)
# - Genera tu clave Age personal
```

**Salida**:
```
🔐 Setup SOPS + Age para Encriptación de Secretos

📦 Instalando SOPS...
✓ SOPS instalado

📦 Instalando Age...
✓ Age instalado

🔑 Generando nueva clave Age...
✓ Clave generada: /Users/tu/.config/sops/age/keys.txt

📋 Tu clave pública Age:
Public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

⚠️  IMPORTANTE:
1. Guarda tu clave PRIVADA en lugar seguro: /Users/tu/.config/sops/age/keys.txt
2. Comparte tu clave PÚBLICA con el equipo para .sops.yaml
3. NUNCA commitees tu clave privada

✅ Setup completo
💡 Siguiente paso: Actualizar .sops.yaml con tu clave pública
```

### 2. Compartir tu Clave Pública

```bash
# Ver tu clave pública
grep "public key:" ~/.config/sops/age/keys.txt

# Copiar y enviar al team lead (Slack, email, etc.)
```

### 3. Team Lead Agrega tu Clave

El team lead agrega tu clave pública a `.sops.yaml`:

```yaml
creation_rules:
  - path_regex: \.env\.dev\.enc$
    age: >-
      age1dev_clave_publica_dev1,
      age1dev_clave_publica_dev2,
      age1dev_TU_CLAVE_PUBLICA_AQUI
```

### 4. Desencriptar Secretos

```bash
# Desencriptar todos los ambientes
./scripts/secrets/decrypt-all.sh

# O uno específico
./scripts/secrets/decrypt.sh dev

# Esto crea .env.dev con valores reales
```

### 5. Usar

```bash
APP_ENV=dev go run source/api-mobile/cmd/main.go
# Lee .env.dev automáticamente
```

---

## 🔄 Workflow por Ambiente

### LOCAL (Tu Laptop)

**NO necesita SOPS** - Valores fijos en archivos committed

```yaml
# config-local.yaml (en git - valores desarrollo OK)
database:
  postgres:
    password: "edugo_pass"

# .env.local (en git - valores desarrollo OK)
POSTGRES_PASSWORD=edugo_pass
OPENAI_API_KEY=sk-test-key-local
```

**Uso**:
```bash
# Iniciar con Docker local persistente
make local-start-all

# O sin Docker
APP_ENV=local make run
```

**✅ Sin encriptación** (valores de desarrollo, OK exponerlos)

---

### DEV (Servidor Compartido)

**USA SOPS** - Valores reales encriptados

#### Primera Vez (Nuevo Developer)

```bash
# 1. Setup SOPS y generar tu clave
./scripts/secrets/setup-sops.sh

# 2. Compartir clave pública con team lead
grep "public key:" ~/.config/sops/age/keys.txt
# Enviar por Slack/Email

# 3. Esperar que team lead agregue tu clave a .sops.yaml
# (Team lead hace PR con tu clave agregada)

# 4. Pull cambios
git pull

# 5. Desencriptar secretos
./scripts/secrets/decrypt.sh dev
# Crea .env.dev

# 6. Usar
APP_ENV=dev go run source/api-mobile/cmd/main.go
```

#### Editar Secretos (Team Lead)

```bash
# 1. Editar valores reales
vim .env.dev

# 2. Encriptar
./scripts/secrets/encrypt.sh dev
# Crea .env.dev.enc

# 3. Commitear archivo encriptado
git add .env.dev.enc
git commit -m "chore(secrets): update dev database password"
git push

# 4. Notificar al equipo
# Equipo ejecuta: ./scripts/secrets/decrypt.sh dev
```

#### Usar Secretos DEV

```bash
# Desencriptar (si hay cambios)
./scripts/secrets/decrypt.sh dev

# Ejecutar con ambiente dev
APP_ENV=dev go run source/api-mobile/cmd/main.go

# Viper carga:
# 1. .env.dev (secretos desencriptados)
# 2. config-dev.yaml (configuración)
# 3. config.yaml (base)
```

---

### QA/PROD (Servidores de Staging/Producción)

**Mismo workflow que DEV**, pero:

- **QA**: Solo team leads tienen la clave
- **PROD**: Solo DevOps/SRE tienen la clave

**Mejor práctica PROD**:
- ❌ NO usar archivos .env en producción
- ✅ Usar Kubernetes Secrets
- ✅ Usar HashiCorp Vault
- ✅ Usar AWS Secrets Manager

---

## 📚 ¿Cómo Cada Developer Tiene su Propia Clave?

### Concepto: Encriptación Asimétrica con Age

Age permite **múltiples destinatarios** para un mismo archivo encriptado.

#### Ejemplo Práctico

**3 Developers en el equipo**:

```
Developer Juan:
  Clave Privada: age-secret-key-juan (solo él tiene)
  Clave Pública: age1juan... (compartida)

Developer María:
  Clave Privada: age-secret-key-maria (solo ella tiene)
  Clave Pública: age1maria... (compartida)

Developer Carlos:
  Clave Privada: age-secret-key-carlos (solo él tiene)
  Clave Pública: age1carlos... (compartida)
```

#### .sops.yaml (en git)

```yaml
creation_rules:
  - path_regex: \.env\.dev\.enc$
    age: >-
      age1juan...,
      age1maria...,
      age1carlos...
```

#### Encriptar (Team Lead)

```bash
# Team lead edita secretos
vim .env.dev
# POSTGRES_PASSWORD=real_dev_password

# Encripta
sops -e .env.dev > .env.dev.enc
# SOPS encripta para las 3 claves públicas

# Commitea
git add .env.dev.enc
git commit -m "chore: update dev secrets"
```

#### Desencriptar (Cada Developer)

```bash
# Juan desencripta con SU clave privada
sops -d .env.dev.enc > .env.dev
# ✅ Funciona con su clave

# María desencripta con SU clave privada  
sops -d .env.dev.enc > .env.dev
# ✅ Funciona con su clave

# Carlos desencripta con SU clave privada
sops -d .env.dev.enc > .env.dev
# ✅ Funciona con su clave
```

**✅ Un solo archivo `.env.dev.enc`** funciona para todos los developers
**✅ Cada uno usa su propia clave privada**
**✅ No necesitan compartir claves privadas**

---

## 🔒 Seguridad de las Claves

### Dónde se Guardan las Claves

**Clave Privada** (secreta):
```
~/.config/sops/age/keys.txt

# NUNCA COMPARTIR
# NUNCA COMMITEAR
# Backup en lugar seguro (1Password, etc.)
```

**Clave Pública** (compartible):
```
age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

# Compartir con team lead
# Se agrega a .sops.yaml (committed)
```

### ¿Qué pasa si Pierdo mi Clave Privada?

**Solución**:
1. Generar nueva clave: `age-keygen -o ~/.config/sops/age/keys.txt`
2. Compartir nueva clave pública con team lead
3. Team lead agrega nueva clave a `.sops.yaml`
4. Puedes desencriptar secretos con nueva clave

**NO se pierden los secretos** porque otros developers pueden re-encriptar.

---

## 📝 Comandos Make

```bash
# Setup inicial (una vez)
make secrets-setup

# Desencriptar ambiente específico
make secrets-decrypt ENV=dev
make secrets-decrypt ENV=qa

# Encriptar ambiente específico (Team Lead)
make secrets-encrypt ENV=dev
make secrets-encrypt ENV=qa

# Desencriptar todos
make secrets-decrypt-all

# Encriptar todos (Team Lead)
make secrets-encrypt-all
```

---

## 🎯 Best Practices

### ✅ DO (Hacer)

- ✅ Usar `.env.local` para desarrollo local (valores fijos OK)
- ✅ Usar SOPS para dev/qa (encriptar secretos reales)
- ✅ Usar Vault/K8s Secrets para producción (NO archivos)
- ✅ Rotar secretos regularmente
- ✅ Hacer backup de tu clave privada Age
- ✅ Commitear `.env.*.enc` (archivos encriptados)
- ✅ Compartir clave pública con equipo

### ❌ DON'T (No Hacer)

- ❌ Commitear `.env.dev` o `.env.qa` (valores reales)
- ❌ Compartir tu clave privada Age
- ❌ Poner secretos en archivos config-{env}.yaml
- ❌ Hardcodear secretos en código
- ❌ Usar `.env.prod` en producción (usar Vault)
- ❌ Commitear archivos con "PASSWORD" o "SECRET" sin encriptar

---

## 🔄 Rotación de Secretos

### Cuando Rotar

- 🔄 Cada 90 días (política recomendada)
- 🔄 Cuando un developer sale del equipo
- 🔄 Después de un incidente de seguridad
- 🔄 Al cambiar de proveedor de servicios

### Cómo Rotar

```bash
# 1. Generar nuevo secreto (ej: nuevo password PostgreSQL)

# 2. Actualizar en servidor real
# (cambiar password en PostgreSQL dev)

# 3. Editar .env.dev
vim .env.dev
# POSTGRES_PASSWORD=new_password_456

# 4. Encriptar
./scripts/secrets/encrypt.sh dev

# 5. Commitear
git add .env.dev.enc
git commit -m "chore(secrets): rotate dev postgres password"
git push

# 6. Notificar equipo
# Slack: "🔐 Secretos dev rotados, ejecutar: make secrets-decrypt ENV=dev"

# 7. Equipo desencripta
make secrets-decrypt ENV=dev

# 8. Todos tienen nuevo password
```

---

## 🛡️ Niveles de Seguridad por Ambiente

### LOCAL (Tu Laptop)

**Nivel**: 🔓 **Bajo** (OK para desarrollo)

- Valores fijos en `config-local.yaml`
- Contenedores Docker locales
- Secretos NO reales (edugo_pass, sk-test-key)

**✅ Puede commitarse** porque no son secretos reales

---

### DEV (Servidor Compartido Team)

**Nivel**: 🔒 **Medio** (SOPS obligatorio)

- Archivos `.env.dev.enc` encriptados con SOPS
- Clave Age compartida entre developers
- Secretos reales pero de ambiente dev (no producción)

**✅ Seguro** porque:
- Archivo encriptado en git
- Solo developers con clave pueden desencriptar
- Trackeado en git (auditoria)

---

### QA (Servidor Staging)

**Nivel**: 🔒🔒 **Alto** (SOPS con clave restringida)

- Solo team leads tienen la clave Age
- Developers NO pueden desencriptar directamente
- Secretos cerca de producción

---

### PROD (Producción)

**Nivel**: 🔒🔒🔒 **Muy Alto** (Vault / K8s Secrets)

- **NO usar archivos .env**
- Usar HashiCorp Vault
- O Kubernetes Secrets
- O AWS Secrets Manager

**Solo DevOps/SRE** acceden a secretos prod

---

## 🎓 Tutorial Paso a Paso

### Escenario: Nuevo Developer Entra al Equipo

**Developer (Juan)**:

```bash
# Día 1 - Setup
git clone https://github.com/company/edugo
cd EduGo/Analisys

# Generar mi clave Age
./scripts/secrets/setup-sops.sh

# Mi clave pública:
# age1juan3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

# Enviar por Slack al team lead
```

**Team Lead (María)**:

```bash
# Recibo clave pública de Juan
# La agrego a .sops.yaml

vim .sops.yaml
# Agregar: age1juan3z7hjy54pw3hyww5... a la lista

# Re-encriptar secretos para incluir a Juan
./scripts/secrets/decrypt.sh dev
./scripts/secrets/encrypt.sh dev

# Commitear
git add .sops.yaml .env.dev.enc
git commit -m "chore(secrets): add Juan's Age key"
git push
```

**Developer (Juan)**:

```bash
# Pull cambios
git pull

# Ahora puedo desencriptar
./scripts/secrets/decrypt.sh dev
# ✅ Funciona con MI clave

# Ejecutar app
APP_ENV=dev make run
# ✅ Conecta a servidor dev
```

---

## 📖 Archivos de Secretos

| Archivo | En Git | Contenido | Uso |
|---------|--------|-----------|-----|
| `.env.local` | ✅ Sí | Valores desarrollo | Local (no secretos reales) |
| `.env.dev` | ❌ No | Valores reales dev | Desencriptado local |
| `.env.dev.enc` | ✅ Sí | Valores dev encriptados | Commiteable |
| `.env.dev.template` | ✅ Sí | Template sin valores | Referencia |
| `.env.qa.enc` | ✅ Sí | Valores QA encriptados | Solo team leads |
| `.env.prod.enc` | ✅ Sí | Valores prod encriptados | Solo DevOps |

---

## 🔧 Troubleshooting

### "no key found"

```bash
# Verificar clave Age
cat ~/.config/sops/age/keys.txt

# Si no existe, generar
age-keygen -o ~/.config/sops/age/keys.txt
```

### "failed to decrypt"

**Causa**: Tu clave pública NO está en `.sops.yaml`

**Solución**:
```bash
# 1. Verificar tu clave pública
grep "public key:" ~/.config/sops/age/keys.txt

# 2. Verificar .sops.yaml
cat .sops.yaml

# 3. Si no está tu clave: contactar team lead
```

### "SOPS_AGE_KEY_FILE not set"

```bash
# Exportar variable de ambiente
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# O agregar a ~/.bashrc o ~/.zshrc
echo 'export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt' >> ~/.zshrc
```

### Ver Secretos Sin Guardar

```bash
# Ver archivo encriptado temporalmente (no guarda)
sops .env.dev.enc
# Abre editor con valores desencriptados
# Al cerrar, NO modifica archivo
```

---

## 🎯 Comandos de Referencia Rápida

```bash
# === SETUP (una vez) ===
make secrets-setup              # Instalar SOPS + Age + generar clave

# === DESENCRIPTAR (developers) ===
make secrets-decrypt ENV=dev    # Desencriptar dev
make secrets-decrypt-all        # Desencriptar todos

# === ENCRIPTAR (team lead) ===
make secrets-encrypt ENV=dev    # Encriptar dev después de editar
make secrets-encrypt-all        # Encriptar todos

# === USAR ===
APP_ENV=dev make run            # Lee .env.dev automáticamente
APP_ENV=qa make run             # Lee .env.qa automáticamente

# === VER TU CLAVE PÚBLICA ===
grep "public key:" ~/.config/sops/age/keys.txt
```

---

## 📚 Más Información

- **SOPS GitHub**: https://github.com/getsops/sops
- **Age GitHub**: https://github.com/FiloSottile/age
- **SOPS Tutorial**: https://dev.to/stack-labs/manage-your-secrets-in-git-with-sops-common-operations-118g

---

**Última actualización**: 2025-10-29
**Versión**: 1.0
