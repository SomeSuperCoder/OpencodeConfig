# 🐳 Configuración del Contenedor — Entorno de Desarrollo de opencode

> **Ejecuta opencode en un contenedor aislado y reproducible con todas las dependencias preinstaladas.**

Esta guía te guía a través de la configuración y uso del contenedor Podman de opencode desde cero. No se requiere experiencia previa con contenedores.

---

## 📋 Prerrequisitos

| Requisito | Por qué |
|-----------|---------|
| **Podman** | Runtime de contenedores (reemplazo directo de Docker) |
| **Git** | Clonar el repositorio de configuración |
| **Internet** | La primera compilación descarga ~1GB de paquetes |

### Instalar Podman

```bash
# Fedora / RHEL
sudo dnf install -y podman

# Ubuntu / Debian
sudo apt install -y podman

# macOS (Apple Silicon o Intel)
brew install podman
podman machine init
podman machine start

# Arch
sudo pacman -S podman
```

### Verificar

```bash
podman --version
# podman version 5.x.x o posterior
```

---

## ⚡ Inicio Rápido (3 Comandos)

```bash
# 1. Clonar la configuración (en CUALQUIER directorio — NO en tu ~/.config/opencode real)
git clone <your-repo-url> ~/opencode-container
cd ~/opencode-container

# 2. Compilar la imagen (solo la primera vez — toma unos minutos)
./scripts/launcher.sh --build

# 3. Ya estás dentro. Ejecuta opencode dentro del contenedor.
opencode
```

Eso es todo. El launcher maneja todo: compilación de la imagen, configuración de la clave API, montajes del espacio de trabajo, soporte de portapapeles.

**Tu primer proyecto** — el launcher te deja en un shell bash dentro del contenedor. Elige tu camino:

🆕 **Nuevo proyecto** — créalo, entra en él y empieza a trabajar:

```bash
create-project my-api      # crea (git, configuración por proyecto, codegraph)
cd my-api                  # entra en él
opencode                   # empieza a trabajar
```

📂 **Proyecto existente** — monta tu carpeta de proyectos, entra en él y conéctalo:

```bash
./scripts/launcher.sh ~/code    # en el host — monta tu carpeta de proyectos

cd /workspace/my-api            # dentro del contenedor — entra en el proyecto
setup-project                   # inicializa OpenSpec y CodeGraph
opencode                        # empieza a trabajar
```

> **⚠️ Importante:** Clona en un **directorio separado** (por ejemplo, `~/opencode-container`), NO en `~/.config/opencode`. El contenedor integra su propia copia de la configuración al momento de compilar. El `~/.config/opencode` de tu host permanece intacto.

---

## 🔧 Configuración Detallada — Paso a Paso

### Paso 1: Instalar Podman

Consulta la sección de [Prerrequisitos](#-prerrequisitos) arriba.

### Paso 2: Clonar la Configuración

```bash
# Clonar en un directorio dedicado — NO en tu ~/.config/opencode real
git clone <your-repo-url> ~/opencode-container
cd ~/opencode-container
```

> **¿Por qué un directorio separado?** El Containerfile copia archivos del directorio clonado a la imagen al momento de compilar. El `~/.config/opencode` de tu host nunca se toca. Puedes nombrar el directorio como quieras.

### Paso 3: Compilar la Imagen del Contenedor

```bash
./scripts/launcher.sh --build
```

En la primera ejecución, verás:
```
🔨 Force building image 'opencode-env'...
   Containerfile: /home/allen/.config/opencode/Containerfile

[build output...]
✅ Image built successfully.
```

Esto toma 3-10 minutos dependiendo de tu máquina y velocidad de internet. Ejecuciones subsiguientes son instantáneas (capas en caché).

### Paso 4: Clave API de Tavily

En el primer lanzamiento, el launcher solicita tu clave API de [Tavily](https://tavily.com):

```
🔑 Tavily API key not found.
   Tavily is needed for web search in opencode.

   Enter your Tavily API key (or press Enter to skip): tvly-xxxxx
   ✅ Key saved to /home/allen/.config/opencode/.secrets/tavily.key
```

La clave se almacena en tu directorio clonado en `.secrets/tavily.key` y se monta en solo lectura dentro del contenedor. Puedes omitir esto si no necesitas búsqueda web.

### Paso 5: Empezar a Trabajar

Te sumerges en un shell bash dentro del contenedor, en `/workspace`:

```
🚀 Launching opencode container...

   Workspace:      /home/allen → /workspace
   State volume:   opencode-state → /home/allen/.config/opencode/data
   Config:         baked into image (not mounted from host)
   User:           1000:1000
   Hostname:       opencode-env
```

**¿Y ahora qué?**
- 🆕 **Nuevo proyecto:** ejecuta `create-project my-api` → `cd my-api` → `opencode` (ver [Crear un Nuevo Proyecto](#crear-un-nuevo-proyecto)).
- 📂 **Proyecto existente:** relanza con su ruta — `./scripts/launcher.sh /path/to/my/project` — y luego `setup-project` y `opencode` (ver [Abrir un Proyecto Existente](#abrir-un-proyecto-existente)).

---

## 🖥️ Ejecutar el Contenedor

### Uso Básico

```bash
# Ejecutar en el directorio actual
./scripts/launcher.sh

# Ejecutar en un directorio específico
./scripts/launcher.sh /path/to/my/project

# Forzar recompilación de la imagen, luego ejecutar
./scripts/launcher.sh --build

# Combinar opciones
./scripts/launcher.sh /my/project --build
```

### Opciones del Launcher

| Opción | Descripción |
|--------|-------------|
| `--build` | Forzar recompilación de la imagen antes de ejecutar |
| `--help` | Mostrar mensaje de ayuda |
| `WORKSPACE_DIR` | Directorio a montar como `/workspace` (por defecto: directorio actual) |
| `-- EXTRA_ARGS` | Argumentos adicionales de `podman run` |

### Qué Hace el Launcher

1. ✅ Verifica si Podman está instalado
2. ✅ Compila la imagen si no existe (o si se pasa `--build`)
3. ✅ Solicita la clave API de Tavily en la primera ejecución
4. ✅ Monta tu directorio de trabajo como `/workspace`
5. ✅ Monta el archivo de secretos en solo lectura
6. ✅ Habilita el soporte de portapapeles (socket X11 si está disponible)
7. ✅ Mapea tu UID de host dentro del contenedor (sin archivos con propiedad de root)
8. ✅ Te sumerge en un shell bash

### Pasar Argumentos Adicionales

```bash
# Pasar variables de entorno
./scripts/launcher.sh -- --env MY_VAR=value

# Establecer un hostname personalizado
./scripts/launcher.sh -- --hostname my-dev
```

---

## 🏗️ Qué Hay Dentro del Contenedor

El contenedor se basa en **Fedora 44** e incluye:

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| **Node.js** | 22 | Runtime de JavaScript |
| **pnpm** | 10.33.0 | Gestor de paquetes |
| **Rust** | 1.97.1 | Herramientas compiladas |
| **Nushell** | — | Shell de datos estructurados |
| **just** | 1.55.1 | Ejecutor de tareas |
| **opencode-ai** | latest | El TUI |
| **codegraph** | 1.5.0 | Inteligencia de la base de código |
| **agentmemory** | 0.9.28 | Memoria persistente |
| **openspec** | 1.7.0 | Gestión de especificaciones |

Además: `git`, `curl`, `jq`, `ripgrep`, `tree`, `tmux`, `python3`, `gh`, `podman`, `xclip`, y herramientas de compilación (`gcc`, `make`, `cmake`).

### Servidores MCP

| Servidor | Estado | Qué Hace |
|----------|--------|----------|
| **codegraph** | Local (empaquetado) | Exploración de la base de código, búsqueda de símbolos, cadenas de llamadas |
| **tavily** | Remoto | Búsqueda web, extracción de documentación |
| **agentmemory** | Local (empaquetado) | Memoria persistente entre sesiones |

Todos los servidores MCP están preconfigurados y se cargan automáticamente al ejecutar `opencode`.

---

## 📁 Trabajar Dentro del Contenedor

### Crear un Nuevo Proyecto

```bash
create-project my-api
```

Esto crea:
- Directorio `my-api/` con git inicializado
- `README.md` con plantilla básica
- Archivo de configuración `.opencode/opencode.json`
- Índice de Codegraph (si está disponible)

**Opciones:**
```bash
create-project my-api --no-git          # Omitir inicialización de git
create-project my-api --no-codegraph    # Omitir inicialización de codegraph
create-project my-api --dir ~/projects  # Crear en un directorio padre específico
```

### Abrir un Proyecto Existente

Monta cualquier proyecto existente como `/workspace` pasando su ruta al launcher:

```bash
# En el host
./scripts/launcher.sh /path/to/my/project
```

Caes en la raíz del proyecto dentro del contenedor. Conéctalo para opencode:

```bash
# 1. Inicializa OpenSpec + CodeGraph para este directorio
setup-project

# 2. Empieza a trabajar
opencode
```

**Qué hace `setup-project`** — inicializa las dos cosas que los agentes necesitan para ser eficaces en una base de código existente:

- **OpenSpec** (`openspec init`) — desarrollo dirigido por especificaciones: una estructura `openspec/` (config, cambios, specs) además de herramientas de OpenCode en `.opencode/`
- **CodeGraph** (`codegraph init`) — indexa la base de código (`.codegraph/`) para que los agentes puedan explorar símbolos, cadenas de llamadas y alcance de impacto

Es seguro volver a ejecutarlo — ambas herramientas son idempotentes. Pasa un directorio para apuntar a algo distinto del actual (`setup-project /path/to/project`).

> Los archivos son **bidireccionales** — las ediciones que hagas dentro del contenedor aparecen en tu host y viceversa.

### Ejecutar opencode

```bash
opencode
```

Esto lanza el TUI. Todos los agentes, skills y servidores MCP se cargan desde la imagen — no se necesita configuración.

### Trabajar con Archivos

Tu espacio de trabajo (`~/` en el host) se monta en `/workspace` dentro del contenedor. **Los archivos son bidireccionales** — los cambios que haces dentro del contenedor aparecen en tu host y viceversa.

```bash
# Dentro del contenedor
cd /workspace
ls                  # Ver tus archivos del host
opencode            # Iniciar el TUI
git status          # Git funciona como se esperaba
pnpm install        # Instalar dependencias
```

### Soporte de Portapapeles

Si estás en una máquina de escritorio Linux con X11, las operaciones de portapapeles funcionan automáticamente. El launcher monta el socket X11 y el archivo Xauthority.

---

## ⚙️ Configuración

### Cómo Funciona la Configuración

**La configuración del contenedor está CONTROLADA por la imagen del contenedor.** Esto significa:

- ✅ Los agentes, skills, configuraciones MCP y `AGENTS.md` se integran en la imagen al momento de compilar
- ✅ Siempre son consistentes — cada compilación recibe la misma configuración
- ❌ Los cambios que hagas a los archivos de configuración dentro del contenedor **no afectan al host**
- ❌ Los cambios que hagas a los archivos de configuración en el host **no afectan al contenedor**

Esto es intencional. El contenedor es un entorno aislado y reproducible.

### Actualizar la Configuración del Contenedor

Para actualizar la configuración que viene con el contenedor:

1. **Edita archivos en tu host** (en tu directorio clonado, por ejemplo, `~/opencode-container/`)
2. **Recompila la imagen:**

```bash
./scripts/launcher.sh --build
```

Esto recoge los cambios de configuración de tu host y los integra en la nueva imagen.

### Gestión de Secretos

Los secretos se manejan por separado de la configuración — se **montan en tiempo de ejecución**, no se integran.

| Secreto | Ubicación | Cómo se Monta |
|---------|-----------|---------------|
| Clave API de Tavily | `<cloned-dir>/.secrets/tavily.key` | Montaje de enlace en solo lectura |

**Reglas:**
- El directorio `.secrets/` **nunca se envía a git** (verifica tu `.gitignore`)
- Los secretos se montan en solo lectura — el contenedor puede leer pero no modificar
- Si omites la solicitud de la clave Tavily, la búsqueda web no funcionarás (puedes agregarla más tarde creando el archivo)

**Para agregar una clave más tarde:**
```bash
# En el host — en tu directorio clonado
mkdir -p ~/opencode-container/.secrets
echo -n "tvly-your-key-here" > ~/opencode-container/.secrets/tavily.key
chmod 600 ~/opencode-container/.secrets/tavily.key
```

---

## 🏛️ Arquitectura

### Qué se Monta (Host → Contenedor)

| Ruta del Host | Ruta del Contenedor | Modo |
|---------------|---------------------|------|
| `~/` (o directorio especificado) | `/workspace` | Lectura/Escritura |
| `<cloned-dir>/.secrets/tavily.key` | `/home/allen/.config/opencode/.secrets/tavily.key` | Solo lectura |
| `/tmp/.X11-unix` | `/tmp/.X11-unix` | Lectura/Escritura (si X11 está disponible) |
| `~/.Xauthority` | `/home/allen/.Xauthority` | Lectura/Escritura (si X11 está disponible) |

### Qué se Integra en la Imagen

| Componente | Ruta en el Contenedor |
|------------|-----------------------|
| Agentes | `/home/allen/.config/opencode/agents/` |
| Skills | `/home/allen/.config/opencode/skills/` |
| AGENTS.md | `/home/allen/.config/opencode/AGENTS.md` |
| Configuración de opencode | `/home/allen/.config/opencode/opencode.jsonc` |
| Dependencias de paquetes | `/home/allen/.config/opencode/node_modules/` |
| Scripts | `/usr/local/bin/first-run`, `/usr/local/bin/create-project`, `/usr/local/bin/setup-project` |

### Estado Persistente

Un volumen con nombre (`opencode-state`) almacena:
- `state_store.db` — estado de la sesión de opencode
- Caché de `node_modules/` — instalaciones subsiguientes más rápidas

Esto sobrevive a recompilaciones del contenedor.

### Mapeo de Usuario

El contenedor se ejecuta como un usuario sin root (`allen`, UID 1000) con `--userns keep-id`. Tu UID de host se mapea dentro del contenedor, por lo que los archivos que creas dentro tienen la propiedad correcta en el host.

---

## 🔍 Solución de Problemas

### "podman is not installed or not in PATH"

```bash
# Verificar instalación
podman --version

# Si no se encuentra, instálalo:
# Fedora:   sudo dnf install podman
# Ubuntu:   sudo apt install podman
# macOS:    brew install podman && podman machine init && podman machine start
```

### La Compilación Falla con "permission denied"

```bash
# Si ejecutas rootless podman, asegúrate de que tu usuario esté en el grupo correcto
# (generalmente automático en distribuciones modernas)
# Intenta compilar explícitamente:
podman build -t opencode-env -f Containerfile .
```

### "Tavily search won't work"

Omitiste la solicitud de la clave API o el archivo no existe. Agrégala manualmente:

```bash
# En tu directorio clonado (por ejemplo, ~/opencode-container)
mkdir -p .secrets
echo -n "tvly-your-key" > .secrets/tavily.key
chmod 600 .secrets/tavily.key
```

Luego reinicia el contenedor — recoge la clave automáticamente.

### El Portapapeles No Funciona (xclip dentro del contenedor)

Asegúrate de que X11 esté disponible:

```bash
# En el host, verifica si X11 está ejecutándose
echo $DISPLAY
ls /tmp/.X11-unix/

# Si está vacío, X11 no se está ejecutando — el portapapeles no funcionará dentro del contenedor
# Esto es esperado en servidores sin interfaz gráfica
```

### El Contenedor No Puede Ver Mis Archivos

Asegúrate de pasar el directorio correcto:

```bash
# Por defecto: monta el directorio actual
cd ~/my-project
./scripts/launcher.sh

# O especifica explícitamente
./scripts/launcher.sh ~/my-project
```

### La Configuración de Primera Ejecución Tarda Mucho

La primera ejecución ejecuta `pnpm install` para las dependencias de configuración. Ejecuciones subsiguientes omiten esto (en caché mediante el archivo de marcador `.initialized`).

### La Configuración del Contenedor Está Desactualizada

Si actualizaste archivos en el host y quieres que estén en el contenedor:

```bash
./scripts/launcher.sh --build
```

Esto recompila la imagen, recogiendo todos los cambios del host.

### "opencode: command not found" Dentro del Contenedor

La imagen podría estar desactualizada. Recompila:

```bash
./scripts/launcher.sh --build
```

### La Compilación de la Imagen Es Lenta

La primera compilación descarga ~1GB de paquetes. Compilaciones subsiguientes usan el caché de capas de Podman y solo recompilan las capas modificadas (típicamente segundos).

---

## 🔗 Referencia Rápida

```bash
# Instalar podman
sudo dnf install podman        # Fedora
sudo apt install podman        # Ubuntu
brew install podman            # macOS

# Compilar y ejecutar
cd ~/opencode-container        # O donde lo hayas clonado
./scripts/launcher.sh --build  # Primera vez / después de cambios de configuración
./scripts/launcher.sh          # Ejecuciones subsiguientes

# Dentro del contenedor
create-project my-app          # Nuevo proyecto
setup-project                  # Configurar un proyecto existente (OpenSpec + CodeGraph)
opencode                       # Iniciar el TUI

# En el host
~/opencode-container/.secrets/ # Directorio de secretos
```

---

*Creado para la empresa de software de opencode. Cada especialista obtiene un entorno reproducible e idéntico — sin "funciona en mi máquina".*