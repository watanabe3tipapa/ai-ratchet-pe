[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-green.svg)](https://github.com/watanabe3tipapa/ai-ratchet-pe)

# 🔩 ai-ratchet-pe 🔧

AIを支援する自動化 runner（学習用）のシェルスクリプト群とオプションの Web UI です。複数言語ランタイムやコマンドを逐次・条件的に切り替え実行し、AI モジュールと連携してタスクの自動化を支援します。

## 概要

- コアはシェルスクリプトで構成され、フェーズ毎の実行、バイナリ検出、リトライ、ログ出力などを提供します。
- AI モジュールは外部 CLI（README で言及されている ollama / openclaw 等）と連携して、生成や失敗説明などの補助を行います。
- オプションで Web UI（FastAPI / uvicorn ベース）を提供します。

## 主な内容 / 特徴

- runner.sh: 実行フェーズ管理、バイナリ検出、リトライ、危険コマンドフィルタ、ログ出力
- runner-ai.sh: AI 関連のユーティリティ（生成・失敗説明・マニフェスト作成 等）
- runner-ci.sh: CI 向け出力（exit code／JSON など）
- main.py と templates/static: オプションの Web UI（FastAPI / Jinja2 ベース）
- 設定は ai-ratchet.yml で行う想定

## リポジトリ構成（抜粋）

```
ai-ratchet/
├── runner.sh        # コア（フェーズ実行、バイナリ検出、リトライ）
├── runner-ai.sh     # AIモジュール（Ollama/OpenClaw連携）
├── runner-ci.sh     # CIモジュール（exit codes、JSON出力）
├── main.py          # Web UI（オプション）
├── templates/       # Web UIテンプレート
├── static/          # CSSファイル
└── ai-ratchet.yml   # 設定
```

（リポジトリのルートに .env.example、ai-prompt.txt、docs、pyproject.toml、requirements.txt 等が含まれます。）

## クイックスタート（README に記載された利用例）

※ 以下は既存 README に記載された実行例です。実行前に ai-ratchet.yml などの設定を確認してください。

### コマンドライン版

```bash
# 実行
./runner.sh ai-ratchet.yml

# ドライラン
./runner.sh ai-ratchet.yml dry

# AI支援（生成など）
./runner-ai.sh ai-ratchet.yml generate "テストを実行"

# CI 用 JSON 出力
./runner-ci.sh ai-ratchet.yml --json
```

### Web UI（ローカルで起動してブラウザ操作する例）

```bash
uv sync
uv run uvicorn main:app --reload
# ブラウザで http://localhost:8000 を開く
```

## 各 Runner の簡単な説明

- runner.sh（コア）
  - バイナリ検出（README に python, node, ollama, openclaw が言及されています）
  - フェーズ単位の実行、リトライ、ログ出力、危険コマンドのフィルタリング

- runner-ai.sh（AI モジュール）
  - 生成・失敗説明・マニフェスト作成 等（使い方の例は上記）

- runner-ci.sh（CI モジュール）
  - JSON 出力や詳細ログ出力など CI 向けの出力に対応（使い方の例は上記）

## 必要な環境（README に記載された要件）

- Bash
- sed, awk
- jq（オプション）
- ollama CLI（AI 機能を使う場合、README にて言及）
- openclaw CLI（AI 機能を使う場合、README にて言及）
- Web UI を使う場合: Python 3.13+、uv（uvicorn 等）、FastAPI 関連パッケージ（pyproject.toml に Python >=3.13 と依存関係が記載されています）

## ドキュメント

- 詳しい使い方（README に記載の GitHub Pages）: https://watanabe3tipapa.github.io/ai-ratchet-pe/USAGE.html

## 開発・保守状態

- 公開リポジトリとして README とドキュメント（GitHub Pages）が存在します。README の記載内容に基づき、シェルベースのコアとオプションの Web UI が確認できます。
- アーカイブ済みなどの明示は README にありません（archived: false）。

## ライセンス

- MIT ライセンス（README に明記されています）


---

注: 本 README はリポジトリ内に既に記載されている情報に基づき構成・整理したものです。実行前に各スクリプトおよび設定ファイル（ai-ratchet.yml 等）を確認してください。
