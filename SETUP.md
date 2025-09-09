# セットアップガイド

個人用dotfilesのセットアップと使用方法について説明します。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh
```

### インタラクティブモード
実行時に以下の選択肢が表示されます：

1. **フルセットアップ** - 新しいマシン向け（推奨）
2. **アップデートのみ** - 既存環境での更新（Homebrew、開発ツール、リンク再作成）
3. **セットアップスキップ** - リポジトリ更新のみ

### 自動化モード
環境変数で非対話実行も可能：
```bash
# フルセットアップ
BOOTSTRAP_MODE=1 curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh

# アップデートのみ  
BOOTSTRAP_MODE=2 curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh

# セットアップスキップ
BOOTSTRAP_MODE=3 curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh
```

## 前提条件

- **macOS**: このセットアップはmacOS専用です
- **インターネット接続**: パッケージのダウンロードに必要
- **Command Line Tools**: 不足している場合は自動インストール

## セットアップ内容

### インストールされるもの
- **Homebrew**: macOSのパッケージマネージャー
- **mise**: ランタイムバージョン管理ツール
- **zinit**: Zshプラグインマネージャー
- **GNU stow**: dotfilesのシンボリックリンク管理
- **各種CLIツール**: `homebrew/.config/homebrew/Brewfile`で定義

### 実行される処理
1. **事前チェック**: macOS確認、ネット接続、gitの存在確認（Command Line Tools自動インストール）

   **⭐️ 新品のMacでの初回実行**：
   - Command Line Toolsインストールダイアログが自動表示
   - 「Install」クリック後、スクリプトが自動で完了を待機
   - インストール完了後、自動的に処理続行
2. **リポジトリクローン**: `~/Repos/github.com/YousukeFujigaya/dotfiles`に配置
3. **各種セットアップスクリプト実行**:
   - `macos-defaults`: macOSシステム設定
   - `setup-homebrew`: Homebrewとパッケージインストール
   - `setup-mise`: 開発環境構築
   - `setup-zinit`: Zshプラグイン環境
   - `setup-links`: 設定ファイルのシンボリックリンク作成
   - `setup-nvim`: Neovim設定
   - `setup-login`: ログインシェル設定

## グローバルスクリプトアクセス

`setup-links`により、`scripts/`ディレクトリ内のスクリプトが`~/.local/bin/`にシンボリックリンクされ、どこからでも実行可能になります。

### 利用可能なコマンド

```bash
# Homebrew関連
setup-homebrew --update        # Homebrewとパッケージを更新
setup-homebrew --skip-apps     # Homebrewのみインストール、アプリはスキップ

# 開発環境
setup-mise                      # 開発ツールのインストール/更新
setup-mise --skip-update       # mise自体の更新をスキップ

# 設定ファイル管理
setup-links                     # 全dotfilesを再リンク
setup-links --unlink package   # 特定パッケージのリンクを解除
setup-links --unlink-all       # 全リンクを解除
setup-links --clean-broken     # 壊れたシンボリックリンクをクリーンアップ

# システム設定
macos-defaults                    # macOS設定を再適用

# シェル環境
setup-zinit                     # zinitを再インストール/更新
```

## バックアップシステム

### 自動バックアップ
既存ファイルを上書きする前に自動でバックアップを作成：
- **保存場所**: `~/.local/state/dotfiles/backup/`（XDG準拠）
- **命名規則**: `ファイル名.YYYYMMDD_HHMMSS`
- **対象**: 上書きされる既存の設定ファイル

### バックアップ管理
```bash
# バックアップ一覧表示
list_backups

# バックアップから復元
restore_backup ".vimrc.20250109_143022"

# 古いバックアップ削除（ファイルごとに最新5個を保持）
clean_old_backups
```

## カスタマイズ

### 環境変数
```bash
export SKIP_HOMEBREW=true           # Homebrewインストールをスキップ
export INSTALL_DIR="/custom/path"   # インストール先を変更
```

### パッケージ追加
- **Homebrewパッケージ**: `homebrew/.config/homebrew/Brewfile`を編集
- **開発ツール**: `~/.tool-versions`を編集
- **カスタムスクリプト**: `scripts/`ディレクトリに追加

## エラー処理

### 安全機能
- エラー発生時の行番号表示
- 依存関係の事前チェック
- 冪等性（複数回実行しても安全）
- 既存設定のバックアップ
- インターネット接続確認

### トラブルシューティング

#### よくある問題
1. **Command Line Toolsが未インストール**
   ```bash
   xcode-select --install
   ```

2. **権限エラー**
   ```bash
   sudo xcode-select --reset
   ```

3. **アップデート後のリンク切れ**
   ```bash
   setup-links --clean-broken
   ```

#### ログ出力
- 📌 一般的な情報
- ℹ️  詳細情報
- ✅ 成功
- ⚠️  警告（継続可能）
- ❌ エラー（致命的）
- 🔄 処理ステップ

## 部分的なインストール

```bash
# Homebrewのみ
export SKIP_MISE=true
export SKIP_ZINIT=true
./scripts/setup

# 開発ツールのみ更新
setup-mise
```

## 複数マシンでの同期

```bash
# 新しいマシン
curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh

# 既存インストールの更新
cd ~/Repos/github.com/YousukeFujigaya/dotfiles
git pull
./scripts/setup
```

---

# Setup Guide (English)

Personal dotfiles setup and usage instructions.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh
```

## Prerequisites

- **macOS**: This setup is macOS-specific
- **Internet Connection**: Required for package downloads
- **Command Line Tools**: Auto-installed if missing

## What Gets Installed

- **Homebrew**: macOS package manager
- **mise**: Runtime version manager
- **zinit**: Zsh plugin manager
- **GNU stow**: Dotfiles symlink manager
- **CLI tools**: Defined in `homebrew/.config/homebrew/Brewfile`

## Global Script Access

Scripts in `scripts/` are symlinked to `~/.local/bin/` via `setup-links`, making them globally accessible.

## Available Commands

```bash
setup-homebrew --update    # Update Homebrew and packages
setup-mise                 # Install/update development tools
setup-links                # Relink all dotfiles
setup-links --clean-broken # Clean broken symlinks
macos-defaults             # Reapply macOS settings
```

## Backup System

- **Location**: `~/.local/state/dotfiles/backup/`
- **Format**: `filename.YYYYMMDD_HHMMSS`
- **Management**: `list_backups`, `restore_backup`, `clean_old_backups`