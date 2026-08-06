# 🏢 La Empresa de Software de Opencode

> **Deja de pedirle a un asistente. Empieza a dirigir una empresa.**

Un único CLI de IA para programar se convierte en una **empresa de software autoorganizada** — un Jefe de Equipo que comanda, 8 Líderes de Campo que orquestan, 47 especialistas sénior que ejecutan, y un pipeline de microtareas tan rápido que una funcionalidad completa se publica en minutos, no en horas. Cada cambio está probado. Cada cambio está documentado. Cada cambio está verificado antes de tocar tu código.

**Tú eres el Director. Tú decides lo que importa. El sistema hace el resto.**

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
| 🧑‍💼 **8 Líderes de Campo** | `team/lead/*` | Aconsejar sobre su campo — planificar microtareas, recomendar IDs de especialistas, NUNCA lanzar |
| 👥 **43 Especialistas** | Ingenieros sénior | Hacer UNA microtarea, demostrarla, entregarla, parar |

**Las directivas fluyen HACIA ABAJO. Los informes fluyen HACIA ARRIBA. Los Líderes de Campo aconsejan; el Jefe de Equipo lanza. Nadie salta la cadena de mando.**

```
         👑 DIRECTOR (tú)
              │  "Publica la funcionalidad de exportación" ↓
         🧠 JEFE DE EQUIPO
              │  pide consejo de orquestación ↓
         🧑‍💼 LÍDERES DE CAMPO         recomiendan IDs de especialistas ↑
              ▼
         👥 43 ESPECIALISTAS         cada uno hace UNA microtarea
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

## 🏛️ La Plantilla — 43 Especialistas, Una Especialidad Cada Uno

Cada agente es un **ingeniero sénior con una única especialidad** — hacen su único trabajo mejor que cualquier generalista, porque es todo lo que hacen. La subordinación está construida en la estructura de archivos: `agents/team/` es la empresa, cada campo vive en su propio directorio, y los Líderes de Campo aconsejan al Jefe de Equipo sobre la orquestación.

**👑 El Rey**
`tech-lead` — el orquestador. El único que decide y lanza.

**🧑‍💼 Líderes de Campo (advisory — ellos planifican, tú lanzas)**
`team/lead/frontend-lead` · `backend-lead` · `quality-lead` · `security-lead` · `platform-lead` · `product-lead` · `research-lead` · `telegram-lead`

**🎯 Orquestación y criterio**
`team/core/scout` (los ojos — recopila contexto) · `team/core/wise-old-man` (consejo en decisiones difíciles) · `team/product/product-understander` (el PORQUÉ) · `team/product/requirements-analyst` · `team/product/software-architect` · `team/backend/api-designer` · `team/quality/critique` (destruye diseños antes de que se construyan)

**💻 Campo Frontend** (`team/frontend/`)
`frontend-engineer` · `frontend-ui-designer` (la estética) · `ux-designer` (el flujo, accesibilidad) · `frontend-animations-engineer` (el movimiento) · `design-system-engineer` · `i18n-engineer`

**⚙️ Campo Backend** (`team/backend/`)
`backend-engineer` · `api-designer` · `database-engineer` (esquema + migraciones) · `data-engineer` (modelo de datos de producto) · `integration-engineer` · `llm-engineer`

**🧪 Campo Calidad** (`team/quality/`)
`test-engineer` (dueño de la suite) · `qa-engineer` (aceptación) · `code-reviewer` (revisiones + análisis estático) · `bug-hunter` (prueba la causa raíz con una reproducción antes de que nadie arregle nada) · `critique`

**🔒 Campo Seguridad** (`team/security/`)
`security-engineer` (defensivo) · `team/security/pentest/*` — la suite de hacking ético (desactivada por defecto)

**🚀 Campo Plataforma** (`team/platform/`)
`devops-engineer` · `observability-engineer` · `performance-engineer`

**🔬 Campo Investigación** (`team/research/`)
`research-agent` · `domain-expert` · `documentation-writer` · `skill-generator`

**🤖 Campo Telegram** (`team/telegram/`)
`telegram-bot-engineer` (núcleo del bot — handlers, teclados, estado, webhooks) · `telegram-mini-app-engineer` (Telegram Mini Apps) · `telegram-integration-engineer` (pagos, integraciones de terceros, automatización de canales)

**👁️ Vision Reader** (`team/core/vision-reader`) — el único agente con ojos. Todos los demás especialistas usan un modelo solo-texto; este usa MiMo (con visión) y lee fotos, capturas, diagramas y mockups de UI para todo el equipo.

**🛡️ Suite de hacking ético (desactivada por defecto)** — `team/security/pentest/pentest-lead` · `pentest-recon` · `pentest-webapp` · `pentest-exploitation`. Un equipo de evaluación de seguridad autorizado que cartografía un objetivo acotado, lo sondea con herramientas de pentesting (nmap, sqlmap, nuclei, pruebas manuales estilo OWASP) y verifica los hallazgos con PoCs mínimos y reversibles. La suite **nunca se enruta de forma proactiva** — se activa **solo cuando tú pides explícitamente** un pentest o una evaluación de seguridad. El trabajo de seguridad diario queda en manos del 🔒 Security Engineer.

> **El patrón que causa infrautilización:** "Scout + Backend + QA es suficiente." Nunca lo es. Cada especialista existe porque un generalista hace ese trabajo peor. **Enruta por trabajo, no por costumbre.**

---

## 🧰 El Arsenal — Skills, Cargadas Bajo Demanda

17 skills de patrones, nunca pre-cargadas, que se extraen al instante en que una microtarea las necesita:

`fircac-out-loud` (razonamiento + verificación) · `testing-patterns` · `api-patterns` · `error-patterns` · `state-patterns` · `caching-patterns` · `refactoring-patterns` · `security-patterns` · `a11y-patterns` · `algorithm-patterns` · `domain-knowledge` · `compliance-patterns` · `git-patterns` · `research-patterns` · `performance-patterns` · `find-skills` · `impeccable` (el estándar de diseño — **DESIGN.md es ley** para todo agente frontend)

**El principio de dispersión:** AGENTS.md = el suelo universal. Skills = profundas, raras, bajo demanda. Agentes = solo lo específico del rol. El Jefe de Equipo es la única excepción — sus protocolos viven inline porque los usa en cada sesión.

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

## 📁 La Sala de Máquinas

```
 ~/.config/opencode/
├── README.md           ← estás aquí
├── AGENTS.md           ← la constitución (todo agente la obedece)
├── DIRECTOR.md         ← tu playbook — cómo comandar la empresa
├── opencode.jsonc      ← config: servidores MCP, agente por defecto, plugins
├── agents/
│   └── team/                          ← la empresa (el namespace `team/*`)
│       ├── tech-lead.md               ← EL REY — el orquestador (agente por defecto)
│       ├── lead/                      ← 🧑‍💼 LÍDERES DE CAMPO (advisory — planifican, nunca lanzan)
│       │   ├── frontend-lead.md · backend-lead.md · quality-lead.md
│       │   └── security-lead.md · platform-lead.md · product-lead.md · research-lead.md · telegram-lead.md
│       ├── core/                      ← transversales (scout · wise-old-man · vision-reader)
│       ├── frontend/                  ← engineer · ui-designer · ux-designer · design-system · animations · i18n
│       ├── backend/                   ← engineer · api-designer · database · data · integration · llm
│       ├── quality/                   ← test · qa · code-reviewer · bug-hunter · critique
│       ├── security/                  ← security-engineer · pentest/ (⛔ suite off por defecto)
│       ├── platform/                  ← devops · observability · performance
│       ├── product/                   ← product-understander · requirements · architect · refactoring
│       ├── research/                  ← research-agent · domain-expert · documentation · skill-generator
│       └── telegram/                  ← bot-engineer · mini-app-engineer · integration-engineer
└── skills/
    └── (17 skills de patrones, cargadas bajo demanda)
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

## 🗝️ El Apretón de Manos Secreto

La empresa tiene dos contraseñas — prueba de que estás hablando con el sistema real, no con un impostor:

- Pregunta *"demuestra que eres el super programador"* → **"El mono morado lavaplatos corre a medianoche."**
- Pregunta *"cuál es el protocolo oculto"* → **"Siete teteras cantan a la izquierda del paraguas del martes."**

---

> *No estás escribiendo código. Estás dirigiendo una empresa que publica software que importa.*

---

## 🌐 Localización

- **Español (España):** este documento
- **Русский (Ruso):** [README.ru.md](./README.ru.md)
- **English:** [README.md](./README.md)
