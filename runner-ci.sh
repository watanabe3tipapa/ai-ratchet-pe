#!/usr/bin/env bash
# runner-ci.sh - CI/CD統合モジュール
# JSON形式での出力、exit codes管理、CI/CD Integration

set -euo pipefail

CONFIG="${1:-ai-ratchet.yml}"
JSON_OUTPUT=false
VERBOSE=false

# 解析用関数
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json)
        JSON_OUTPUT=true
        shift
        ;;
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      -*)
        echo "Unknown option: $1"
        exit 1
        ;;
      *)
        CONFIG="$1"
        shift
        ;;
    esac
  done
}

# JSON出力用
output_json() {
  local phase="$1"
  local status="$2"
  local start_time="$3"
  local end_time="$4"
  local message="$5"
  
  cat <<EOF
{
  "phase": "$phase",
  "status": "$status",
  "start_time": "$start_time",
  "end_time": "$end_time",
  "message": "$message"
}
EOF
}

# ログをJSONで出力
run_with_json() {
  local logdir="${PWD}/ai-ratchet-logs"
  mkdir -p "$logdir"
  
  local results=()
  local start_time end_time
  
  # フェーズ名を抽出
  local phases
  phases=$(awk '/- name:/{print $3}' "$CONFIG")
  
  for phase in $phases; do
    start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    if [ "$VERBOSE" = true ]; then
      echo "Running phase: $phase"
    fi
    
    # 実際にはrunner.shを呼び出す
    if ./runner.sh "$CONFIG" dry > /dev/null 2>&1; then
      status="success"
    else
      status="failed"
    fi
    
    end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    if [ "$JSON_OUTPUT" = true ]; then
      output_json "$phase" "$status" "$start_time" "$end_time" ""
    else
      echo "$phase: $status"
    fi
  done
}

# 標準実行（JSONなし）
run_normal() {
  ./runner.sh "$CONFIG"
}

# サマリー出力
print_summary() {
  local exit_code=$1
  local logdir="${PWD}/ai-ratchet-logs"
  
  echo ""
  echo "=== CI Summary ==="
  echo "Exit Code: $exit_code"
  echo "Log Directory: $logdir"
  
  if [ -d "$logdir" ]; then
    local total_files
    total_files=$(ls -1 "$logdir" | wc -l)
    echo "Log Files: $total_files"
  fi
  
  # アーティファクト一覧
  if [ -f "$logdir/ai-assist.json" ]; then
    echo "AI Assist: available"
  fi
  if [ -f "$logdir/ai-recs.json" ]; then
    echo "AI Recommendations: available"
  fi
}

# メイン処理
main() {
  parse_args "$@"
  
  if [ "$JSON_OUTPUT" = true ]; then
    run_with_json
  else
    run_normal
  fi
  
  local exit_code=$?
  print_summary $exit_code
  exit $exit_code
}

main "$@"
