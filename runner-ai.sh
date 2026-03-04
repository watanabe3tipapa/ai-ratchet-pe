#!/usr/bin/env bash
# runner-ai.sh - AI支援モジュール
# Ollama/OpenClawと連携してAI支援機能を提供

set -euo pipefail

CONFIG="${1:-ai-ratchet.yml}"
MODE="${2:-help}"
LOGDIR="${PWD}/ai-ratchet-logs"
mkdir -p "$LOGDIR"

usage() {
  cat <<EOF
Usage: ./runner-ai.sh [config] [mode]

Modes:
  help              このヘルプを表示
  generate          プロンプトからコマンドを生成
  explain-failure   エラー原因を解析
  create-manifest   manifestテンプレートを作成
  sanitize          セキュリティサニタイズを提案

Examples:
  ./runner-ai.sh ai-ratchet.yml generate "Pythonプロジェクトをテストしたい"
  ./runner-ai.sh ai-ratchet.yml explain-failure ai-ratchet-logs/test.log
  ./runner-ai.sh ai-ratchet.yml create-manifest
EOF
}

# Ollamaが利用可能かチェック
check_ollama() {
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Error: ollama not found"
    exit 1
  fi
}

# OpenClawが利用可能かチェック
check_openclaw() {
  if ! command -v openclaw >/dev/null 2>&1; then
    echo "Error: openclaw not found"
    exit 1
  fi
}

# AIにコマンド生成を依頼
ai_generate() {
  local prompt="$1"
  local output_file="${LOGDIR}/ai-generated.sh"
  
  check_ollama
  
  echo "AIにコマンド生成を依頼中..."
  
  ollama run llama3.2 "以下のタスクを達成するためのシェルコマンドを1つ生成してください。説明は不要で、コマンドだけを出力してください。タスク: ${prompt}" > "$output_file"
  
  echo "生成されたコマンド:"
  cat "$output_file"
  echo ""
  echo "→ ${output_file} に保存しました"
}

# エラー解析
ai_explain_failure() {
  local log_file="$1"
  local output_file="${LOGDIR}/ai-explanation.md"
  
  if [ ! -f "$log_file" ]; then
    echo "Error: Log file not found: $log_file"
    exit 1
  fi
  
  check_ollama
  
  echo "AIにエラー解析を依頼中..."
  
  local log_content
  log_content=$(cat "$log_file")
  
  ollama run llama3.2 "以下のエラーログを分析し、原因と復旧手順を日本語で説明してください。ログ: ${log_content}" > "$output_file"
  
  echo "解析結果:"
  cat "$output_file"
  echo ""
  echo "→ ${output_file} に保存しました"
}

# manifestテンプレート作成
ai_create_manifest() {
  local output_file="ai-ratchet-generated.yml"
  
  check_ollama
  
  echo "AIにmanifest作成を依頼中..."
  
  ollama run llama3.2 "YAML形式で、AIラチェットのmanifestテンプレートを作成してください。以下の項目含めて: runtimes, phases(init, install, build, test, run), 各フェーズのコマンド例" > "$output_file"
  
  echo "作成されたmanifest:"
  cat "$output_file"
  echo ""
  echo "→ ${output_file} に保存しました"
}

# セキュリティサニタイズ提案
ai_sanitize() {
  local cmd="$1"
  local output_file="${LOGDIR}/ai-sanitize-proposal.txt"
  
  check_ollama
  
  echo "AIにセキュリティチェックを依頼中..."
  
  ollama run llama3.2 "以下のコマンドのセキュリティリスクを評価し、安全な代替案があれば提案してください。コマンド: ${cmd}" > "$output_file"
  
  echo "提案:"
  cat "$output_file"
  echo ""
  echo "→ ${output_file} に保存しました"
}

# メイン処理
case "$MODE" in
  help|--help|-h)
    usage
    ;;
  generate)
    ai_generate "${3:-}"
    ;;
  explain-failure)
    ai_explain_failure "${3:-}"
    ;;
  create-manifest)
    ai_create_manifest
    ;;
  sanitize)
    ai_sanitize "${3:-}"
    ;;
  *)
    echo "Unknown mode: $MODE"
    usage
    exit 1
    ;;
esac
