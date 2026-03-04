# ai-ratchet 使用方法

## 概要

ai-ratchet は、AIを支援する自動化runnerです。シェルスクリプトで複数言語ランタイム／コマンドを逐次・条件的に切り替え・実行し、AIが支援する仕組みを実現します。

**目的**：口径（ランタイムやコマンド）が異なる実行対象を安全かつ効率的にリレー（逐次/並列）すること

## 構成

```
ai-ratchet/
├── runner.sh        # コア（フェーズ実行、バイナリ検出、リトライ）
├── runner-ai.sh     # AIモジュール（Ollama/OpenClaw連携）
├── runner-ci.sh     # CIモジュール（exit codes、JSON出力）
├── main.py          # Web UI（オプション）
├── templates/       # Web UIテンプレート
├── static/         # CSSファイル
└── ai-ratchet.yml # 設定
```

---

## 使い方①：コマンドライン（Web UIなし）

### 必須ツール
- bash
- sed
- awk
- jq（オプション）
- ollama CLI（AI機能を使う場合）
- openclaw CLI（AI機能を使う場合）

### 実行

#### runner.sh（コア）
```bash
# 通常実行
./runner.sh ai-ratchet.yml

# ドライラン（テスト実行）
./runner.sh ai-ratchet.yml dry

# モード
# run   - 通常実行（デフォルト）
# dry   - 実行せず、計画されたコマンドを表示
```

#### runner-ai.sh（AIモジュール）
```bash
# コマンド生成
./runner-ai.sh ai-ratchet.yml generate "Pythonプロジェクトをテストしたい"

# エラー解析
./runner-ai.sh ai-ratchet.yml explain-failure ai-ratchet-logs/test.log

# manifest作成
./runner-ai.sh ai-ratchet.yml create-manifest

# セキュリティチェック
./runner-ai.sh ai-ratchet.yml sanitize "実行したいコマンド"
```

#### runner-ci.sh（CIモジュール）
```bash
# 通常実行
./runner-ci.sh ai-ratchet.yml

# JSON出力
./runner-ci.sh ai-ratchet.yml --json

# 詳細出力
./runner-ci.sh ai-ratchet.yml --verbose
```

---

## 使い方②：Web UI（GUI）

### 準備

1. 依存関係をインストール
```bash
uv sync
```

2. サーバーを起動
```bash
uv run uvicorn main:app --reload
```

3. ブラウザで開く
```
http://localhost:8000
```

### Web UIでできること

| 項目 | 説明 |
|-----|------|
| Runner選択 | runner.sh / runner-ai.sh / runner-ci.sh |
| モード選択 | run / dry / generate / explain-failure |
| 設定ファイル | ai-ratchet.ymlなどを指定 |
| プロンプト入力 | AIへの指示を入力 |
| 結果表示 | 実行結果をリアルタイム表示 |

### Web UI画面

1. **Runner選択** - 使いたいRunnerを選択
2. **モード選択** - 実行モードを選択
3. **プロンプト** - AIに指示を入力（AIモジュールの場合）
4. **実行** - ボタンをクリックすると結果が表示される

---

## 設定ファイル（ai-ratchet.yml）

```yaml
runtimes:
  python: ["python3.11","python3","python"]
  node: ["node18","node16","node"]

phases:
  - name: init
    cmds:
      - "PYTHON -m pip install -r requirements.txt"
    retries: 1

  - name: ai_assist
    cmds:
      - "OLLAMA run --model llama2 --prompt-file ai-prompt.txt > ai-assist.json"
    retries: 0
```

### 設定項目
- `runtimes`: 使用するバイナリのリスト
- `phases`: 実行するフェーズの一覧
- `name`: フェーズ名
- `cmds`: 実行するコマンド
- `retries`: リトライ回数

---

## ログ

ログは `ai-ratchet-logs/` ディレクトリに保存されます：
- 各フェーズごとのログファイル
- `ai-assist.json` - AIからの出力
- `ai-recs.json` - AIからの推奨

---

## セキュリティ

危険なコマンドは自動的にブロックされます：
- `rm -rf`
- `:(){|sudo`
- その他危険な操作

安全設計：
- AIはコマンドを「提案」し、実行は必ずユーザー確認
- 実行前にハッシュで既知安全リストと照合
- サンドボックス/ドライランオプション

---

## 必要な環境

### 共通
- Bashが動作する環境
- sed, awk

### オプション
- jq（JSON検証用）
- ollama CLI（AI機能を使う場合）
- openclaw CLI（AI機能を使う場合）
- uv（Web UIを使う場合）
- python 3.13+（Web UIを使う場合）

---

## 選擇ガイド

| 场景 | 推荐 |
|-----|------|
| シンプルにコマンドを実行 | `runner.sh` |
| AIに支援してほしい | `runner-ai.sh` |
| CI/CDに統合 | `runner-ci.sh` |
| ブラウザから操作したい | Web UI（main.py） |
