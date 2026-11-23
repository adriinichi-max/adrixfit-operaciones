# AdrixFit · Operaciones — instrucciones para Claude y Codex

Este archivo lo leen los dos agentes al empezar. Cumplirlo siempre, aunque la conversación sea nueva.

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
