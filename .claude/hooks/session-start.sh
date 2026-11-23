#!/bin/bash
# Arranque de cada conversación en la nube: deja Codex listo para repartir el trabajo.
# Si Codex no tiene sesión, inicia el acceso por código de un solo uso y pasa a
# Claude el enlace y el código para que se los enseñe al propietario lo primero.
# No guarda claves: la sesión de Codex vive solo en esta máquina.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export PATH="$HOME/.local/bin:$PATH"
LOG="$HOME/.codex-login.log"

contexto() {
  python3 -I -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))'
}

REPARTO='Reparto de trabajo con Codex (orden del propietario, 23 nov; detalle en AGENTS.md, apartado «Codex desde el terminal»):
- Claude es el arquitecto: entiende el encargo, decide el plan, escribe encargos concretos para Codex, revisa lo que devuelve, junta solo lo correcto y responde al propietario.
- Codex hace el trabajo gordo: lo largo, repetitivo o mecánico (procesar archivos, cambios amplios, pruebas, revisiones extensas).
- Antes de delegar comprueba `codex login status`. Copia de trabajo: `git worktree add /root/codex-wt HEAD` (si no existe).
- Encargo: `codex exec -s read-only -C /root/codex-wt -o /root/codex_respuesta.md "<qué hacer, qué archivos, qué devolver>" < /dev/null`. Si debe cambiar archivos, `-s workspace-write`, solo en esa copia; revisa el diff antes de juntarlo. Lánzalo en segundo plano si es largo.
- Al terminar, di al propietario qué hizo cada uno.'

if ! command -v codex >/dev/null 2>&1; then
  npm install --global --prefix "$HOME/.local" @openai/codex@0.163.0 >/dev/null 2>&1 || true
fi
if ! command -v codex >/dev/null 2>&1; then
  printf '%s\n\nCodex no está instalado y no se pudo instalar (npm install -g @openai/codex). Díselo al propietario en tu primera respuesta y trabaja sin Codex hasta que se resuelva.' "$REPARTO" | contexto
  exit 0
fi

ESTADO="$(codex login status 2>&1 || true)"
if printf '%s' "$ESTADO" | grep -q "^Logged in"; then
  printf 'Codex ya tiene la sesión iniciada en esta conversación.\n\n%s' "$REPARTO" | contexto
  exit 0
fi

# Reutiliza un acceso por código que siga pendiente (p. ej. al reanudar); si no, lanza uno nuevo.
if ! { pgrep -f "codex login --device-auth" >/dev/null 2>&1 && grep -q "auth.openai.com" "$LOG" 2>/dev/null; }; then
  pkill -f "codex login --device-auth" 2>/dev/null || true
  : > "$LOG"
  nohup codex login --device-auth > "$LOG" 2>&1 < /dev/null &
fi

URL=""; CODIGO=""
for _ in $(seq 1 30); do
  LIMPIO="$(sed 's/\x1b\[[0-9;]*m//g' "$LOG" 2>/dev/null)"
  URL="$(printf '%s' "$LIMPIO" | grep -oE 'https://auth\.openai\.com/[^[:space:]]*' | head -1)"
  CODIGO="$(printf '%s' "$LIMPIO" | grep -A1 -i 'one-time code' | tail -1 | grep -oE '^[[:space:]]*[A-Z0-9]{4}-[A-Z0-9]{4,6}[[:space:]]*$' | tr -d '[:space:]')"
  [ -n "$URL" ] && [ -n "$CODIGO" ] && break
  sleep 0.5
done

if [ -z "$URL" ] || [ -z "$CODIGO" ]; then
  printf '%s\n\nNo se pudo obtener el código de acceso de Codex (registro en %s). En tu primera respuesta díselo al propietario en una línea y ofrece generarlo con `codex login --device-auth`.' "$REPARTO" "$LOG" | contexto
  exit 0
fi

printf 'OBLIGATORIO: empieza tu PRIMERA respuesta de esta conversación, antes de cualquier otra cosa, con este bloque para que el propietario apruebe Codex (no le pidas nada más):\n\nPara que Codex trabaje en esta conversación:\n1. Abre %s\n2. Escribe el código **%s** (caduca en 15 minutos)\n\nCuando lo apruebe, `codex login status` dirá «Logged in» y empezáis a repartir el trabajo sin preguntarle. Si caduca, genera otro con `codex login --device-auth` (en segundo plano, leyendo el enlace y el código de su salida) y pásaselo igual.\n\n%s' "$URL" "$CODIGO" "$REPARTO" | contexto
exit 0
