#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-ai-ratchet.yaml}"
DRY_RUN=${2:-false}
LOGDIR="${PWD}/ai-ratchet-logs"
mkdir -p "$LOGDIR"

detect_bin() {
  for b in $1; do
    if command -v "$b" >/dev/null 2>&1; then
      echo "$b"
      return 0
    fi
  done
  return 1
}

# parse candidates
PY_CANDS=$(sed -n '/^runtimes:/,/^phases:/{/python:/,/:/p}' "$CONFIG" | sed -n 's/.*\[\(.*\)\].*/\1/p' | tr -d '"' | tr -d ' ' | tr ',' ' ')
NODE_CANDS=$(sed -n '/^runtimes:/,/^phases:/{/node:/,/:/p}' "$CONFIG" | sed -n 's/.*\[\(.*\)\].*/\1/p' | tr -d '"' | tr -d ' ' | tr ',' ' ')

PYTHON_BIN=$(detect_bin "$PY_CANDS" || true)
NODE_BIN=$(detect_bin "$NODE_CANDS" || true)
OLLAMA_BIN=$(detect_bin "ollama" || true)
OPENCLAW_BIN=$(detect_bin "openclaw" || true)

echo "Detected: PYTHON=${PYTHON_BIN:-<none>} NODE=${NODE_BIN:-<none>} OLLAMA=${OLLAMA_BIN:-<none>} OPENCLAW=${OPENCLAW_BIN:-<none>}"

awk '/- name:/{name=$3} /cmds:/{p=1;next} p && /- /{gsub(/- /,""); print name "::" $0} /^$/{p=0}' "$CONFIG" | while IFS="::" read -r phase cmd; do
  logfile="${LOGDIR}/${phase}.log"
  cmd_eval="$cmd"
  cmd_eval="${cmd_eval//PYTHON/$PYTHON_BIN}"
  cmd_eval="${cmd_eval//NODE/$NODE_BIN}"
  cmd_eval="${cmd_eval//OLLAMA/$OLLAMA_BIN}"
  cmd_eval="${cmd_eval//OPENCLAW/$OPENCLAW_BIN}"

  echo "==> Phase: $phase  CMD: $cmd_eval"
  if [ "$DRY_RUN" = "true" ]; then
    echo "[dry-run] $cmd_eval" | tee -a "$logfile"
    continue
  fi

  # simple dangerous command check
  if echo "$cmd_eval" | grep -E -q "rm -rf|:(){|sudo "; then
    echo "Refusing to run dangerous command in phase $phase: $cmd_eval" | tee -a "$logfile"
    exit 2
  fi

  retries=$(sed -n "/- name: $phase/,/retries:/{/retries:/p}" "$CONFIG" | sed -n 's/.*retries:[[:space:]]*\([0-9]*\).*/\1/p' || echo 0)
  attempt=0
  while :; do
    attempt=$((attempt+1))
    if bash -lc "$cmd_eval" >>"$logfile" 2>&1; then
      echo "OK: $phase (attempt $attempt)"
      break
    else
      echo "FAIL: $phase (attempt $attempt) -- see $logfile"
      if [ "$attempt" -le "$retries" ]; then
        echo "Retrying..."
        sleep 1
        continue
      fi
      echo "Aborting."
      exit 1
    fi
  done
done

