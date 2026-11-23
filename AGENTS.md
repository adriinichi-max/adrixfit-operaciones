# AdrixFit · Operaciones — instrucciones para Claude y Codex

Este archivo lo leen los dos agentes al empezar. Cumplirlo siempre, aunque la conversación sea nueva.

**Norma absoluta de trabajo (orden del propietario):** mínimo consumo de recursos sin recortar
requisitos, calidad ni verificaciones. Detalle en `docs/NORMAS_TRABAJO.md`.

## Al empezar cualquier conversación (obligatorio)
1. Leer `ESTADO.md` y las tareas abiertas. No repetir lo que ya está hecho o asignado.
2. Decir al propietario en 2-3 líneas, sin tecnicismos, cómo se reparte el trabajo pedido
   entre Claude y Codex. Hacer solo la parte propia.
3. La parte del otro se deja como **encargo listo para pegar** en `ESTADO.md` («Encargos») si Codex
   no está disponible en la conversación.
4. Al terminar: actualizar `ESTADO.md` y subir los cambios.

## Reparto inicial (ajustable por el propietario)
| Claude | Codex |
|---|---|
| Reglas, guiones, plantillas de mensajes, documentación, revisión | Trabajo largo o mecánico: procesar listas, scripts, automatizaciones con código |

## Reglas
- Un archivo lo edita un agente a la vez. No reescribir ni borrar trabajo del otro sin revisarlo.
- **Privacidad:** nada de claves, tokens de GoHighLevel, conversaciones reales de WhatsApp, teléfonos,
  nombres ni datos de leads o clientes en Git. Documentar procesos con ejemplos inventados.
- No enviar mensajes a leads ni cambiar nada en GoHighLevel sin que el propietario lo pida claramente.
- Al hablar con el propietario: lenguaje sencillo, pasos numerados y **siempre enlaces clicables**
  (nunca «entra en…»). No crear nada en Notion u otros sitios sin que lo pida.

## Si una tarea queda a medias (obligatorio)
Antes de parar, guardar y SUBIR `progreso/<tarea>.md` con lo hecho, lo que falta, decisiones y quién sigue.
Lo no subido se pierde: las conversaciones no son compartidas.

## Colaboración entre Codex y Claude (igual que en adrixfit-app)
- Una rama y un worktree por tarea. Nunca trabajar ambos agentes sobre el mismo directorio.
- No reescribir, descartar ni fusionar trabajo del otro agente sin revisar. Acordar un responsable por archivo.
- Una sola persona o agente coordina la integración; conservar siempre un camino de reversión.
- **Apoyarse siempre en Codex (orden del propietario, 22 nov):** toda conversación, de Claude o de Codex,
  divide el trabajo con la otra herramienta para que ninguna gaste tantos créditos. Al empezar, repartir,
  hacer solo la parte propia y dejar la del otro como encargo listo para pegar. No repetir lo que el otro ya hizo.
- Registrar el estado real: preparado, probado, desplegado y cargado son etapas diferentes. No afirmar
  una copia o carga real basándose en un ensayo.
- Respetar las autorizaciones vigentes del propietario sin pedirlas repetidamente. No contratar servicios
  ni ampliar planes por una autorización de otro presupuesto.

## Codex desde el terminal (arranque automático)
Al abrir una conversación en la nube, `.claude/hooks/session-start.sh` instala Codex si falta y, si no tiene
sesión, prepara un código de acceso que Claude enseña al propietario en su primera respuesta.
- Claude es el arquitecto: entiende el encargo, decide el plan, escribe encargos concretos para Codex,
  revisa lo que devuelve, junta solo lo correcto y responde al propietario.
- Codex hace el trabajo gordo: lo largo, repetitivo o mecánico.
- Antes de delegar: `codex login status`. Copia de trabajo: `git worktree add /root/codex-wt HEAD`.
- Encargo: `codex exec -s read-only -C /root/codex-wt -o /root/codex_respuesta.md "<qué hacer, archivos, qué devolver>" < /dev/null`.
  Si debe cambiar archivos: `-s workspace-write`, solo en esa copia; revisar el diff antes de juntarlo.
- Al terminar, decir al propietario qué hizo cada uno. Si Codex no está disponible, trabajar sin él y avisar.

## REGLA IMPRESCINDIBLE: cuando el propietario diga «derívalo a Codex» (orden del 23 nov)
Si el propietario pide, con cualquier palabra, derivar, dividir, repartir o pasar trabajo a Codex, **lo primero
de esa respuesta, antes de cualquier otra cosa, es darle el código de acceso**. Sin excepciones y sin preguntarle nada.
1. Comprobar `codex login status`. Si dice «Logged in», saltar al punto 4.
2. Si no hay sesión, generar el acceso en segundo plano y desacoplado (si no, el proceso se muere al acabar el comando):
   `export PATH="$HOME/.local/bin:$PATH"; : > ~/.codex-login.log; setsid nohup codex login --device-auth > ~/.codex-login.log 2>&1 < /dev/null & disown`
   y leer el código de `~/.codex-login.log` (línea tras «one-time code»; quitar los colores con `sed 's/\x1b\[[0-9;]*m//g'`).
   Si Codex no está instalado: `npm install --global --prefix "$HOME/.local" @openai/codex@0.163.0`.
3. Empezar la respuesta con este bloque exacto y esperar su «ya» (no repartir nada antes):

   Para que Codex trabaje en esta conversación:
   1. Abre [https://auth.openai.com/codex/device](https://auth.openai.com/codex/device)
   2. Escribe el código **XXXX-XXXXX** (caduca en 15 minutos)

   Si tras su «ya» `codex login status` sigue sin decir «Logged in», generar un código nuevo y repetir el bloque.
4. Con sesión iniciada: repartir el trabajo (Claude arquitecto, Codex trabajo gordo) y al final decir qué hizo cada uno.
Vale en cualquier conversación de cualquier repositorio, aunque el arranque automático no hubiera mostrado el código.
