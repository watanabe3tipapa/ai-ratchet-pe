[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-green.svg)](https://github.com/watanabe3tipapa/ai-ratchet-pe)

# ai-ratchet

AIを支援する自動化runnerです。シェルスクリプトで複数言語ランタイム／コマンドを逐次・条件的に切り替え・実行し、AIが支援する仕組みを実現します。

## 構成

```
ai-ratchet/
├── runner.sh        # コア（フェーズ実行、バイナリ検出、リトライ）
├── runner-ai.sh     # AIモジュール（Ollama/OpenClaw連携）
├── runner-ci.sh     # CIモジュール（exit codes、JSON出力）
├── main.py          # Web UI（オプション）
├── templates/       # Web UIテンプレート
├── static/         # CSSファイル
└── ai-ratchet.yml  # 設定
```

## クイックスタート

### コマンドライン版
```bash
# 実行
./runner.sh ai-ratchet.yml

# ドライラン
./runner.sh ai-ratchet.yml dry

# AI支援
./runner-ai.sh ai-ratchet.yml generate "テストを実行"

# CI出力
./runner-ci.sh ai-ratchet.yml --json
```

### Web UI版（ブラウザから操作）
```bash
uv sync
uv run uvicorn main:app --reload
# ブラウザで http://localhost:8000 を開く
```

## 各Runnerの詳細

### runner.sh（コア）
- バイナリ検出（python, node, ollama, openclaw）
- フェーズ単位の実行
- リトライ機能
- ログ出力
- 危険コマンドフィルタ

### runner-ai.sh（AIモジュール）
```bash
./runner-ai.sh ai-ratchet.yml generate "タスク内容"
./runner-ai.sh ai-ratchet.yml explain-failure ai-ratchet-logs/test.log
./runner-ai.sh ai-ratchet.yml create-manifest
```

### runner-ci.sh（CIモジュール）
```bash
./runner-ci.sh ai-ratchet.yml --json
./runner-ci.sh ai-ratchet.yml --verbose
```

## 詳細ドキュメント

- [GitHub pages](https://watanabe3tipapa.github.io/ai-ratchet-pe/USAGE.html) - 詳しい使い方

## 必要な環境

- Bash
- sed, awk
- jq（オプション）
- ollama CLI（AI機能を使う場合）
- openclaw CLI（AI機能を使う場合）
- **uv + python 3.13+（Web UIを使う場合）**

## ライセンス

MIT
