# 🔐 Manejo de Secretos con SOPS

SOPS (Secrets OPerationS) permite encriptar secretos para commitearlos de forma segura.

## ¿Qué es SOPS?

**SOPS** = Secrets OPerationS (por Mozilla)
**Age** = Encriptación moderna y simple

**Ventajas**:
- ✅ Secretos encriptados en git
- ✅ Versionados y auditables
- ✅ Cada developer usa su propia clave
- ✅ Cambios trackeados en git
- ✅ Rotación de secretos fácil

## Setup Inicial (Una sola vez)

```bash
# Instalar SOPS + Age y generar tu clave
./scripts/secrets/setup-sops.sh

# Esto crea ~/.config/sops/age/keys.txt con tu clave privada
# Y muestra tu clave pública para compartir con el equipo
```

**IMPORTANTE**: 
- Guarda tu clave privada (`~/.config/sops/age/keys.txt`) en lugar seguro
- Comparte solo tu clave PÚBLICA con el team lead
- NUNCA commitees tu clave privada

## Workflow para Developers

### 1. Primera vez en el proyecto

```bash
# Clonar repo
git clone <repo>
cd EduGo/Analisys

# Setup SOPS (genera tu clave)
./scripts/secrets/setup-sops.sh

# Compartir tu clave pública con team lead
grep "public key:" ~/.config/sops/age/keys.txt

# Team lead agrega tu clave a .sops.yaml

# Desencriptar secretos
./scripts/secrets/decrypt-all.sh
# Esto crea .env.dev, .env.qa, .env.prod

# Usar
APP_ENV=dev go run source/api-mobile/cmd/main.go
```

### 2. Editar secretos (Team Lead)

```bash
# Editar secretos dev
vim .env.dev

# Encriptar
./scripts/secrets/encrypt.sh dev
# Crea .env.dev.enc

# Commitear
git add .env.dev.enc
git commit -m "chore: update dev secrets"
git push
```

### 3. Actualizar secretos (Otros Developers)

```bash
# Pull cambios
git pull

# Desencriptar
./scripts/secrets/decrypt.sh dev
# Actualiza .env.dev con nuevos valores

# Usar
APP_ENV=dev go run source/api-mobile/cmd/main.go
```

## Comandos

```bash
# Setup (una vez)
./scripts/secrets/setup-sops.sh

# Encriptar un ambiente
./scripts/secrets/encrypt.sh dev
./scripts/secrets/encrypt.sh qa
./scripts/secrets/encrypt.sh prod

# Desencriptar un ambiente
./scripts/secrets/decrypt.sh dev
./scripts/secrets/decrypt.sh qa
./scripts/secrets/decrypt.sh prod

# Encriptar/Desencriptar todos
./scripts/secrets/encrypt-all.sh
./scripts/secrets/decrypt-all.sh
```

## Archivos

| Archivo | En Git | Descripción |
|---------|--------|-------------|
| `.env.local` | ✅ Sí | Valores local (no son secretos) |
| `.env.dev` | ❌ No (.gitignore) | Valores reales dev |
| `.env.dev.enc` | ✅ Sí | Valores dev encriptados |
| `.env.qa` | ❌ No (.gitignore) | Valores reales QA |
| `.env.qa.enc` | ✅ Sí | Valores QA encriptados |
| `.env.prod` | ❌ No (.gitignore) | Valores reales prod |
| `.env.prod.enc` | ✅ Sí | Valores prod encriptados |

## Seguridad

**Por Ambiente**:
- **local**: Valores fijos (config-local.yaml) - OK commitear
- **dev**: SOPS con Age (clave compartida team)
- **qa**: SOPS con Age (clave team leads)
- **prod**: Kubernetes Secrets / Vault (NO archivos)

## Rotación de Secretos

```bash
# 1. Generar nuevos secretos
# 2. Editar .env.dev
vim .env.dev

# 3. Encriptar
./scripts/secrets/encrypt.sh dev

# 4. Commitear
git add .env.dev.enc
git commit -m "chore(secrets): rotate dev passwords"
git push

# 5. Notificar al equipo
# Team ejecuta: ./scripts/secrets/decrypt.sh dev
```

## Troubleshooting

**Error: "no key found"**
```bash
# Verificar que tengas clave Age
cat ~/.config/sops/age/keys.txt

# Si no existe, generar
age-keygen -o ~/.config/sops/age/keys.txt
```

**Error: "failed to decrypt"**
```bash
# Tu clave pública debe estar en .sops.yaml
# Contactar al team lead para agregarla
```

## Ver Secretos Encriptados (Sin Desencriptar)

```bash
# Ver estructura del archivo encriptado
sops .env.dev.enc
# Abre en editor con valores desencriptados temporalmente
```

---

**Documentación completa**: Ver SECRETS.md en raíz
