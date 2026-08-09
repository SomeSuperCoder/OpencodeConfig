# 🏢 La Empresa de Software de Opencode

> **Deja de pedirle a un asistente. Empieza a dirigir una empresa.**

**🌐 Idiomas:** [English](./README.md) · [Español (España)](./README.es.md) · [Русский](./README.ru.md)

Un único CLI de IA para programar se convierte en una **empresa de software autoorganizada** — un Jefe de Equipo que comanda, 15 Líderes de Campo que orquestan, 61 especialistas sénior que ejecutan, y un pipeline de microtareas tan rápido que una funcionalidad completa se publica en minutos, no en horas. Cada cambio está probado. Cada cambio está documentado. Cada cambio está verificado antes de tocar tu código.

**Tú eres el Director. Tú decides lo que importa. El sistema hace el resto.**

🐳 **[Configuración del Contenedor](./CONTAINER_SETUP.es.md)** · [Русский](./CONTAINER_SETUP.ru.md) — Ejecuta opencode en un contenedor Podman reproducible con todas las dependencias preinstaladas.

---

## 🌋 El Problema Que Esto Elimina

Pídele a un único asistente de IA que "cree el flujo de pago" y obtendrás: un monólogo seguro de sí mismo, un muro de código, cero tests y errores que descubres en producción.

La razón es estructural. Un solo modelo haciendo todo a la vez es un **generalista haciendo cinco trabajos mal** — arquitecto, ingeniero, tester, revisor y auditor de seguridad son un solo cerebro difuso. No hay revisión. No hay verificación. No hay responsabilidad.

**Este proyecto es la cura.** Divide ese cerebro difuso en una **empresa de especialistas** — cada uno un ingeniero sénior con EXACTAMENTE una especialidad, cada uno rápido porque es pequeño, cada uno responsable porque entrega un informe de trabajo, no vibraciones.

---

## ✨ La Empresa, En Un Vistazo

| Nivel | Quién | Su Trabajo |
|-------|-------|------------|
| 👑 **Director** | Tú | Visión, prioridades, decisiones finales |
| 🧠 **Jefe de Equipo** | `team/tech-lead` | Planificar el trabajo, formar las oleadas, revisar, informar, hacer commit |
| 🧑‍💼 **15 Líderes de Campo** | `team/lead/*` | Aconsejar sobre su campo — planificar microtareas, recomendar IDs de especialistas, NUNCA lanzar |
| 👥 **61 Especialistas** | Ingenieros sénior | Hacer UNA microtarea, demostrarla, entregarla, parar |

**Las directivas fluyen HACIA ABAJO. Los informes fluyen HACIA ARRIBA. Los Líderes de Campo aconsejan; el Jefe de Equipo lanza. Nadie salta la cadena de mando.**

```
         👑 DIRECTOR (tú)
              │  "Publica la funcionalidad de exportación" ↓
         🧠 JEFE DE EQUIPO
              │  pide consejo de orquestación ↓
         🧑‍💼 LÍDERES DE CAMPO         recomiendan IDs de especialistas ↑
              ▼
         👥 61 ESPECIALISTAS         cada uno hace UNA microtarea
              ▲  los informes de trabajo fluyen hacia arriba
         🧠 JEFE DE EQUIPO
              │  estado + evidencias + escaladas ↑
         👑 DIRECTOR
```

---

## 🧠 Por Qué Es Rápido — La Asimetría Es Deliberada

La mayoría de los "equipos de IA" fracasan porque cada agente es un prompt gigante que vuelve a derivarlo todo. Este sistema invierte el trade-off clásico:

| Capa | Tamaño del prompt | Por qué |
|------|-------------------|---------|
| **Especialistas** | Diminuto | Una microtarea, una especialidad, **nacen con los datos** — cero exploración |
| **Líderes de Campo** | Pequeño | Conocen el roster y el routing de su campo — planifican microtareas, recomiendan IDs, nunca lanzan |
| **Jefe de Equipo** | Enorme (~1.400 líneas) | Contiene los protocolos, la matriz de routing, las puertas de calidad, las reglas de escalada |
| **AGENTS.md** | Mediano | La constitución universal que todo agente obedece |
| **Skills** | Profundos, carga perezosa | Se cargan solo cuando una microtarea los necesita |

**La regla:** los agentes pequeños trabajan rápido → el cuello de botella es la inyección de contexto → por eso el Jefe de Equipo carga el contexto. Un trabajador bien lanzado termina **en minutos**. Velocidad gracias a la pequeñez.

---

## 🏭 El Pipeline de Microtareas — Por Qué Publica

Cada tarea es un paso por un pipeline donde cada especialista hace exactamente su paso y se detiene:

```
CONTEXTO → DISEÑO → IMPLEMENTACIÓN → TEST → VERIFICACIÓN → ENTREGA
  Scout      Líderes    Ingeniero     Test    QA, Code     Jefe de
            de Campo   (una         Engineer  Reviewer,   Equipo
            + diseño   microtarea)             Security,   hace commit
            espec.                            auditorías
```

**Los Líderes de Campo están en la fase de DISEÑO:** dividen la directiva en las microtareas más pequeñas y recomiendan qué especialista se encarga de cada una. El Jefe de Equipo toma ese plan, lanza él mismo a los especialistas y conduce el resto del pipeline.

**Las leyes que lo hacen funcionar:**

- 📦 **Una sesión = una microtarea.** Entregada = sesión terminada. Sin expansión de alcance, sin "ya que estoy".
- 🍼 **Nacen con los datos.** El Jefe de Equipo inyecta hechos, extractos de código, radio de impacto y la especificación en cada prompt de lanzamiento. Un trabajador nunca explora el código por su cuenta.
- 📤 **Informa, no arregles.** ¿Encontraste un bug fuera de tu especialidad? Escríbelo en tu informe de trabajo. El Jefe de Equipo lo enruta.
- ⚡ **La velocidad es una funcionalidad.** Una microtarea que necesita 6+ pasos era demasiado grande — el Jefe de Equipo debería haberla dividido.

**El Workflow Quirúrgico** — todo agente, toda tarea:

```
① PIENSA  →  ② PLANIFICA  →  ③ ACTÚA  →  ④ VERIFICA  →  ⑤ ENTREGA → PARA
```

Lo más pequeño primero. Una sola pasada. Verificación mínima. Para al entregar.

---

## 🔐 La Disciplina Que Evita El Caos

Cualquiera puede lanzar 30 agentes. El caos es fácil. **La verificación es la parte difícil** — y este sistema es brutal con ella:

| Protocolo | Qué garantiza |
|-----------|---------------|
| 🗣️ **FIRCAC** | Hechos → Problema → Reglas → Casos → Aplicación → Consecuencias. Obligatorio, en voz alta, antes de cada corrección de bug o decisión difícil. |
| 🔍 **ABC** | **No Asumas Nada. No Creas a Nadie. Confírmalo Todo.** La doctrina de verificación — cada afirmación se demuestra, no se confía. |
| 🧪 **Test de UNA ejecución** | Ejecuta la suite una vez, captúralo todo. Nunca vuelvas a ejecutar para "pescar" salida. |
| 🔴🟢 **ROJO-VERDE** | Un cambio recibe COMO MÁXIMO 2 ejecuciones de test, nunca más. Corrige por tandas, no a chorritos. |
| 🏓 **Una especialidad es dueña de los tests** | El Test Engineer ejecuta la suite. Todos los demás consumen el veredicto. Nadie re-ejecuta el verde de otro. |
| 🧠 **Amplificadores de Inteligencia** | CodeGraph primero (nunca grep). Tavily antes de adivinar. Navegador para VER la interfaz. AgentMemory para memoria persistente. Nushell para datos estructurados. |
| 🚦 **Escalada** | Las decisiones humanas suben con opciones + plazo. Las decisiones de implementación se quedan en casa. El Jefe de Equipo escala, nunca adivina. |
| 📤 **CONTRATO DE ENTREGA** | Cada entregable termina con Veredicto + Evidencia + Archivos + Siguiente responsable. Nadie vuelve a parsear texto libre. |
| ✅ **Definición de Terminado** | Probado, documentado, sin errores de tipos, sin código muerto, contrato de entrega cumplido. El trabajo sin testear NO está terminado. |
| 🔄 **Inicio de Sesión** | RECUERDA → comprueba sesiones → describe el mundo → carga la especificación → anuncia. Nunca empieces a ciegas. |
| 🚨 **Modo "Me voy"** | Di "Me voy" — la empresa funciona en pleno modo autónomo, documenta cada decisión e informa cuando vuelves. |

---

## 🔌 Plugins — La Infraestructura Invisible

Cuatro plugins funcionan silenciosamente en segundo plano, haciendo el sistema más inteligente sin que lo notes:

| Plugin | Qué Hace |
|--------|----------|
| 🧹 **opencode-dynamic-context-pruning** | Poda dinámica del contexto para mantenerse dentro de los límites de tokens — los agentes nunca alcanzan el techo |
| 🔍 **opencode-tool-search** | Descubrimiento inteligente de herramientas — los agentes encuentran la herramienta correcta sin hardcodear |
| 📢 **opencode-notifier** | Envía notificaciones cuando las tareas se completan — sabes cuándo algo se publica |
| 🔄 **opencode-auto-resume** | Reanuda automáticamente sesiones interrumpidas — retomas exactamente donde lo dejaste |

Configurado en `opencode.jsonc`:
```jsonc
"plugin": [
  "opencode-dynamic-context-pruning",
  "opencode-tool-search",
  "@mohak34/opencode-notifier@latest",
  "opencode-auto-resume"
]
```

---

## 🧠 Servidores MCP — La Extensión Cerebral

Dos servidores MCP dan a los agentes superpoderes más allá de lo que el LLM puede hacer:

| Servidor | Tipo | Qué Hace |
|----------|------|----------|
| **CodeGraph** | Local (incluido) | Inteligencia del código — lookup de símbolos, cadenas de llamadas, radio de impacto. Reemplaza grep con un grafo de conocimiento. |
| **Tavily** | Remoto | Búsqueda web, extracción de docs, investigación. Los agentes verifican afirmaciones en lugar de adivinar. |
| **AgentMemory** | Local (incluido) | Memoria persistente entre sesiones — hechos, patrones, decisiones de arquitectura sobreviven reinicios. |

```jsonc
"mcp": {
  "codegraph": {
    "type": "local",
    "command": ["codegraph", "serve", "--mcp"]
  },
  "tavily": {
    "type": "remote",
    "url": "https://mcp.tavily.com/mcp/?tavilyApiKey={file:.secrets/tavily.key}"
  }
}
```

---

## 🧰 El Arsenal — Skills, Cargadas Bajo Demanda

19 skills, nunca pre-cargadas, que se extraen al instante en que una microtarea las necesita:

**Razonamiento y verificación:**
`fircac-out-loud` (razonamiento + verificación ABC) · `find-skills` (descubrir nuevas capacidades)

**Oficio de código:**
`testing-patterns` · `api-patterns` · `error-patterns` · `state-patterns` · `caching-patterns` · `refactoring-patterns` · `performance-patterns` · `algorithm-patterns` · `git-patterns`

**Dominio y cumplimiento:**
`security-patterns` · `compliance-patterns` · `domain-knowledge` · `research-patterns`

**Frontend y diseño:**
`a11y-patterns` · `impeccable` (herramienta de diseño por comandos — ejecuta `context.mjs`, enruta a un subcomando; **DESIGN.md es ley**) · `ux-psychology` (optimización de conversión) · `ux-redesign-examples` (patrones de tests AB reales)

**El principio de dispersión:** AGENTS.md = el suelo universal. Skills = profundas, raras, bajo demanda. Agentes = solo lo específico del rol. El Jefe de Equipo es la única excepción — sus protocolos viven inline porque los usa en cada sesión.

---

## 🎨 Patrones de Diseño — La Biblia del Estilo de Código

La empresa sigue 15 patrones de diseño probados. Guías completas en [`CODE_STYLE.md`](./CODE_STYLE.md).

| Patrón | Cuándo | Anti-patrón que elimina |
|--------|--------|------------------------|
| **Inversión de Control** | Dependencias externas | Código que llama a bibliotecas en vez de ser llamado |
| **Dependencia Explícita** | Todas las dependencias | Acoplamiento oculto a través de globales, singletons o service locators |
| **Parsear, No Validar** | Manejo de entrada | Chequeos en runtime que dejan tipos sin tipar |
| **Patrón Tri-state** | Valores opcionales | Confusión null/undefined — Presente/Ausente/Error |
| **Límite de Fallo Rápido** | Manejo de errores | Errores crudos filtrándose entre capas |
| **Un Solo Nivel de Abstracción** | Diseño de funciones | Mezclar orquestación de alto nivel con detalles de bajo nivel |
| **Lector Tolerante** | Datos externos | Parsers frágiles que se rompen con entrada inesperada |
| **Patrón de Valor de Error** | Fallos esperados | Excepciones para flujo de control — errores como valores, nunca throw |
| **Builder Tipado-Seguro** | Construcción compleja | Objetos parcialmente inicializados, constructores telescópicos |
| **Capa Anti-Corruptción** | APIs externas | Lógica de negocio enredada con Stripe/DB/SMTP |
| **Composición Sobre Herencia** | Reutilización de código | Jerarquías de herencia profundas que bloquean comportamiento |
| **Objeto Centinela** | Valores especiales | Números mágicos y chequeos de null |
| **Patrón de Especificación** | Reglas de negocio | Cadenas if-else esparcidas |
| **Tipo Result** | Fallos esperados | Excepciones para flujo de control — Ok/Err, nunca throw |
| **Contexto Acotado** | Modelado de dominio | Objetos Dios que sirven para todo |

**La meta-regla:** El código es un medio de comunicación. Si el lector debe mirar la implementación para entender la llamada, la abstracción está mal.

---

## 📜 El Playbook del Director

Tu manual completo de comandos vive en [`DIRECTOR.md`](./DIRECTOR.md). Aquí está la esencia:

### Tus 7 Poderes

| Poder | Qué Significa |
|-------|---------------|
| 🎯 **Dirigir** | "Publica X" — una línea, la empresa maneja el resto |
| 📊 **Priorizar** | "Haz X antes de Y" — el Jefe de Equipo reordena el pipeline |
| ✅ **Aprobar** | "Publicalo" o "rehazlo" — la empresa espera tu veredicto |
| ⚖️ **Decidir** | "¿Opción A o B?" — la empresa presenta opciones, tú eliges |
| 🔧 **Contratar/Despedir** | "Quita la suite de pentest" — la empresa se reestructura |
| 📋 **Revisar** | "Muéstrame qué se publicó" — la empresa informa con evidencias |
| 🌑 **Modo Oscuro** | "Me voy" — modo autónomo completo, decisiones documentadas |

### Qué Vuelve a Ti

| Artefacto | Qué Contiene |
|-----------|--------------|
| 📦 **Entregable** | Código funcional, probado, verificado |
| 📋 **Informe de Estado** | Qué se publicó, qué está en vuelo, qué está bloqueado |
| ⚠️ **Escalada** | Una decisión que solo tú puedes tomar — opciones + trade-offs + plazo |
| 📜 **Actas del Consejo** | Cada decisión tomada mientras estabas fuera (modo autónomo) |

---

## 🛠️ Scripts — El Cinturón de Herramientas

Cuatro scripts automatizan el flujo de trabajo del contenedor:

| Script | Qué Hace |
|--------|----------|
| `launcher.sh` | Lanza el contenedor Podman — maneja build, mounts, X11, secrets, mapeo de UID |
| `create-project` | Genera un nuevo proyecto opencode — git init, codegraph init, config .opencode |
| `setup-project` | Conecta un proyecto existente para opencode — OpenSpec + CodeGraph init |
| `first-run.sh` | Entry point del contenedor — ejecuta pnpm install en el primer lanzamiento, luego bash |

**Uso:**
```bash
# Proyecto nuevo
create-project my-api --dir ~/projects

# Proyecto existente
setup-project /path/to/project

# Contenedor
./scripts/launcher.sh ~/code          # montar tu carpeta de proyectos
./scripts/launcher.sh --build         # forzar rebuild
```

Documentación completa del contenedor: **[CONTAINER_SETUP.md](./CONTAINER_SETUP.md)** · [Español](./CONTAINER_SETUP.es.md) · [Русский](./CONTAINER_SETUP.ru.md)

---

## ⚙️ Configuración

### opencode.jsonc — El Panel de Control

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-dynamic-context-pruning", "opencode-tool-search", "..."],
  "mcp": { "codegraph": { ... }, "tavily": { ... } },
  "default_agent": "team/tech-lead",          // ← El Rey es tu agente por defecto
  "permission": {
    "external_directory": { "/tmp": "allow", "/home/*/OpencodeImprovements": "allow" },
    "bash": { "* /tmp*": "allow", "*/home/*/OpencodeImprovements*": "allow" }
  }
}
```

| Configuración | Qué Hace |
|---------------|----------|
| `default_agent` | Qué agente ejecuta al iniciar opencode (default: `team/tech-lead`) |
| `permission.external_directory` | Qué directorios del host pueden acceder los agentes |
| `permission.bash` | Qué comandos bash pueden ejecutar los agentes sin preguntar |

### Variables de Entorno

| Variable | Propósito |
|----------|-----------|
| `TAVILY_API_KEY` | Clave API de Tavily para búsqueda web (también en `.secrets/tavily.key`) |

### Archivos de Configuración

| Archivo | Propósito |
|---------|-----------|
| `opencode.jsonc` | Config principal — plugins, MCP, permisos, agente por defecto |
| `AGENTS.md` | La constitución — este documento de 1.400 líneas que todo agente obedece |
| `DIRECTOR.md` | Tu playbook — cómo comandar la empresa |
| `CODE_STYLE.md` | 15 patrones de diseño que la empresa sigue |
| `tui.json` | Configuración del TUI (placeholder vacío actualmente) |

---

## 📁 La Sala de Máquinas

```
~/.config/opencode/
├── README.md                   ← estás aquí
├── AGENTS.md                   ← la constitución (todo agente la obedece)
├── DIRECTOR.md                 ← tu playbook — cómo comandar la empresa
├── CODE_STYLE.md               ← 15 patrones de diseño
├── opencode.jsonc              ← config: servidores MCP, plugins, permisos, agente por defecto
├── Containerfile               ← definición de build del contenedor (Fedora 44)
│
├── agents/
│   └── team/                                  ← la empresa (el namespace `team/*`)
│       ├── tech-lead.md                       ← EL REY — el orquestador (agente por defecto)
│       ├── lead/                              ← 🧑‍💼 LÍDERES DE CAMPO (advisory — planifican, nunca lanzan)
│       │   ├── frontend-lead.md · backend-lead.md · quality-lead.md
│       │   └── security-lead.md · platform-lead.md · product-lead.md · research-lead.md
│       │       · telegram-lead.md · pinescript-lead.md · mobile-lead.md · web3-lead.md
│       │       · seo-lead.md · lgtm-lead.md · engagement-lead.md · highload-lead.md
│       ├── core/                              ← transversales (scout · wise-old-man · vision-reader)
│       ├── frontend/                          ← engineer · ui-designer · ux-designer · design-system · animations · i18n
│       ├── backend/                           ← engineer · api-designer · database · data · integration · llm
│       ├── quality/                           ← test · qa · code-reviewer · bug-hunter · critique
│       ├── security/                          ← security-engineer · pentest/ (⛔ suite off por defecto)
│       ├── platform/                          ← devops · observability · performance
│       ├── product/                           ← product-understander · requirements · architect · refactoring
│       ├── research/                          ← research-agent · domain-expert · documentation · skill-generator
│       ├── telegram/                          ← bot-engineer · mini-app-engineer · integration-engineer
│       ├── pinescript/                        ← indicator-developer · strategy-developer · pro-quant
│       ├── mobile/                            ← engineer · native-engineer · performance-engineer
│       ├── web3/                              ← smart-contract · dapp-engineer · defi-analyst
│       ├── seo/                               ← seo-engineer · content-strategist · analytics-specialist
│       ├── lgtm/                              ← loki · grafana-dashboard · tempo · mimir
│       ├── engagement/                        ← gamification-engineer · behavioral-designer · retention-analyst
│       └── highload/                          ← architect · engineer · load-testing-engineer
│
├── skills/                                       ← 19 skills de patrones, carga bajo demanda
│   ├── fircac-out-loud/ · testing-patterns/ · api-patterns/ · error-patterns/
│   ├── state-patterns/ · caching-patterns/ · refactoring-patterns/ · security-patterns/
│   ├── a11y-patterns/ · algorithm-patterns/ · domain-knowledge/ · compliance-patterns/
│   ├── git-patterns/ · research-patterns/ · performance-patterns/ · find-skills/
│   ├── impeccable/ · ux-psychology/ · ux-redesign-examples/
│
├── scripts/
│   ├── launcher.sh              ← lanzador del contenedor Podman
│   ├── create-project           ← scaffolding de proyecto opencode nuevo
│   ├── setup-project            ← conectar proyecto existente (OpenSpec + CodeGraph)
│   └── first-run.sh             ← entry point del contenedor
│
├── recommendations/             ← seguimiento persistente de mejoras
│   ├── security/ · performance/ · quality/ · testing/
│   ├── accessibility/ · architecture/ · general/
│
├── data/                        ← estado de opencode (state_store.db, stream_store, ops_board.md)
├── plans/                       ← planes de trabajo activos
├── .secrets/                    ← claves API (gitignored)
├── .env.example                 ← plantilla de variables de entorno
└── node_modules/                ← dependencias de plugins
```

---

## ⚠️ Las Reglas Duras — No Negociables

- **Solo pnpm.** Nunca npm/npx.
- **Mira el Justfile** antes de comandos manuales.
- **Haz commit solo de trabajo verificado** — en los límites de la funcionalidad, con los tests pasando primero. Un commit `fix:` significa que el commit anterior envió trabajo sin verificar. Eso es un fallo.
- **Nunca uses el agente `explore` integrado.** Usa `team/core/scout`.
- **Quédate en tu especialidad.** Informa de los problemas; nunca arregles el trabajo de otro especialista.
- **Los emojis son obligatorios en toda salida** — dirigen la vista del lector hacia lo que importa.

---

## 🔄 Auto-Mejora — El Aparato Se Mejora

Cualquier agente puede reportar problemas con el propio arnés de IA. El sistema mejora escuchando a sus propios operadores.

**Directorio:** `~/OpencodeImprovements/reports/`

Los informes se escriben como archivos markdown usando la [REPORT_TEMPLATE.md](~/OpencodeImprovements/REPORT_TEMPLATE.md). Cuando un agente encuentra una regla rota, un rol faltante, un cuello de botella en el flujo de trabajo o un problema de configuración, escribe un informe. El Director revisa y aprueba cambios. El Jefe de Equipo los implementa.

**Protocolo de Auto-Reflexión** — todo agente, antes de entregar, responde:
1. ¿Investigué algo que no me habían dado?
2. ¿Cargué un skill que no necesitaba?
3. ¿Re-verifiqué algo que ya estaba verificado?

**La Regla:** el arnés es código. Se revisa como código. Se mejora. Los agentes son la primera línea de defensa contra la degradación del arnés.

---

## 📋 Recomendaciones — Seguimiento Persistente de Mejoras

Cada "pasa con recomendaciones" de QA, seguridad, revisión de código o cualquier agente de verificación se guarda en `recommendations/` — no se pierde en el historial del chat.

```
recommendations/
├── security/          ← mejoras de seguridad
├── performance/       ← recomendaciones de rendimiento
├── quality/           ← sugerencias de calidad de código
├── testing/           ← mejoras de tests
├── accessibility/     ← recomendaciones de accesibilidad
├── architecture/      ← mejoras arquitectónicas
└── general/           ← otras recomendaciones
```

**Formato:** `YYYY-MM-DD-topic.md` con Estado, Prioridad, Esfuerzo, Razonamiento, Evidencia.

**Comando del usuario:** `"Implementa todas las recomendaciones"` (o "Implementa todas las recomendaciones anteriores") → El Jefe de Equipo ejecuta el PROTOCOLO DE IMPLEMENTACIÓN DE RECOMENDACIONES: escanear pendientes → comprobar si ya están implementadas → detectar contradicciones → agrupar por dominio → lanzar especialistas → verificar por nivel → eliminar los archivos al completar → reportar. Las recomendaciones contradictorias o ya presentes nunca se reimplementan.

Protocolo completo: [`recommendations/README.md`](./recommendations/README.md)

---

## 🌍 Regla de Idioma — Coincide con el Usuario

Toda salida dirigida al usuario debe estar en el idioma que el usuario habla. Detecta su idioma de su mensaje y responde en él. Sin excepciones.

| Contexto | Idioma |
|----------|--------|
| **Salida dirigida al usuario** | **100% en el idioma del usuario** |
| **Prompts de subagentes** | Inglés (consistente en todo el equipo) |
| **Código, comandos, rutas de archivos** | Siempre inglés (nunca se traduce) |

**Los términos técnicos se mantienen en inglés.** Palabras como "container", "MCP", "opencode", "FIRCAC" se mantienen en inglés incluso en mensajes no en inglés.

**Traducciones disponibles:**

| Documento | Idiomas |
|-----------|---------|
| README | [English](./README.md) · [Español](./README.es.md) · [Русский](./README.ru.md) |
| Configuración del Contenedor | [English](./CONTAINER_SETUP.md) · [Español](./CONTAINER_SETUP.es.md) · [Русский](./CONTAINER_SETUP.ru.md) |

---

## 🧠 AgentMemory — Memoria Persistente entre Sesiones

AgentMemory es un servidor MCP independiente que da a cada agente memoria persistente entre sesiones:

```
┌─────────────────────────────────────────────────────────┐
│  agentmemory-mcp (Servidor MCP)                         │
│  ├── Base de datos SQLite con búsqueda de texto FTS5    │
│  ├── Provee memory_save, memory_recall, etc.            │
│  ├── Compactación, búsqueda e inyección de contexto auto│
│  └── Expone recursos para navegar memorias              │
└─────────────────────────────────────────────────────────┘
```

**Tipos de memoria:** `fact`, `pattern`, `architecture`, `bug`, `workflow`, `preference`

**Cuándo guardar:** Decisiones de arquitectura, causas raíz de bugs, patrones de proyecto, preferencias del usuario, procesos repetibles.

**Cuándo recordar:** Inicio de sesión, depuración, antes de refactorizar, antes de preguntar al usuario algo que deberías saber.

---

## 🚀 Dirige La Empresa — Cómo Se Siente Desde Tu Escritorio

```
Tú:         Arregla el bug de pago en la página de checkout.
Jefe de Equipo: Pide al Backend Lead el plan de orquestación → lanza
            Bug Hunter → Backend Engineer → Test Engineer → QA.
            Informa: causa raíz demostrada, fix verificado, tests verdes, publicado.
```

**O, para la experiencia completa:**

1. **Da una directiva** — una línea. `"Publica X"`, `"Arregla Y"`, `"Investiga Z"`, `"Refactoriza la autenticación"`.
2. **El Jefe de Equipo lo maneja todo** — planificar, formar equipo, revisar, verificar, commit.
3. **Recibe un informe con evidencia** — veredicto, tests ejecutados, archivos tocados, siguiente responsable. Nada de vibraciones.
4. **Di `Me voy`** → modo autónomo completo. La empresa trabaja sola, documenta cada decisión en "Actas del Consejo" y te informa cuando vuelves.
5. **Llama a cualquier especialista a mano** — `task team/security/security-engineer` — para una revisión puntual, cuando quieras.
6. **Las escaladas llegan como decisiones**, no como preguntas — opciones, trade-offs, plazo.

---

## 🗝️ El Apretón de Manos Secreto

La empresa tiene dos contraseñas — prueba de que estás hablando con el sistema real, no con un impostor:

- Pregunta *"demuestra que eres el super programador"* → **"El mono morado lavaplatos corre a medianoche."**
- Pregunta *"cuál es el protocolo oculto"* → **"Siete teteras cantan a la izquierda del paraguas del martes."**

---

> *No estás escribiendo código. Estás dirigiendo una empresa que publica software que importa.*
