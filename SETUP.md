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
   - `setup-local-config`: ローカル設定（環境変数、プライベート情報）
   - `setup-homebrew`: Homebrewとパッケージインストール
   - `setup-apt`: APTパッケージ管理（Linux環境用）
   - `setup-links`: 設定ファイルのシンボリックリンク作成
   - `macos-defaults`: macOSシステム設定
   - `setup-runtime`: mise（開発環境構築）
   - `setup-zinit`: Zshプラグイン環境
   - `setup-nvim`: Neovim設定
   - `setup-login`: ログインシェル設定

## グローバルスクリプトアクセス

`setup-links`により、`scripts/`ディレクトリ内のスクリプトが`~/.local/bin/`にシンボリックリンクされ、どこからでも実行可能になります。

### 利用可能なコマンド

```bash
# ローカル設定
setup-local-config             # ローカル設定ファイルのセットアップ

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

### ローカル設定

**プライベート情報の管理**

このdotfilesはGitHubで公開されているため、メールアドレスなどのプライベート情報は別途管理されます：

- **設定ファイル**: `~/.config/zsh/.zshrc.local`（gitignoreに含まれる）
- **テンプレート**: `.config/zsh/.zshrc.local.template`
- **自動セットアップ**: `setup-local-config`スクリプトが初回実行時に自動で設定

#### Google Drive設定

スクリーンショットをGoogle Driveに保存する場合：

```bash
# 自動検出（Google Driveがインストール済みの場合）
setup-local-config

# 手動設定
export GOOGLE_DRIVE_EMAIL="your-email@gmail.com"
```

設定されると、macOS-defaultsスクリプトでスクリーンショットの保存先が自動で設定されます。

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

## Setup Process

1. **Pre-checks**: macOS verification, internet connection, git availability
2. **Repository cloning**: To `~/Repos/github.com/YousukeFujigaya/dotfiles`
3. **Setup scripts execution**:
   - `setup-local-config`: Local settings (environment variables, private info)
   - `setup-homebrew`: Homebrew and package installation
   - `setup-apt`: APT package management (for Linux environments)
   - `setup-links`: Configuration file symlink creation
   - `macos-defaults`: macOS system settings
   - `setup-runtime`: mise (development environment setup)
   - `setup-zinit`: Zsh plugin environment
   - `setup-nvim`: Neovim configuration
   - `setup-login`: Login shell configuration

## Local Configuration

**Private Information Management**

Since these dotfiles are publicly available on GitHub, private information like email addresses is managed separately:

- **Configuration file**: `~/.config/zsh/.zshrc.local` (included in gitignore)
- **Template**: `.config/zsh/.zshrc.local.template`
- **Auto-setup**: `setup-local-config` script automatically configures on first run

### Google Drive Setup

For saving screenshots to Google Drive:

```bash
# Auto-detection (if Google Drive is installed)
setup-local-config

# Manual setup
export GOOGLE_DRIVE_EMAIL="your-email@gmail.com"
```

Once configured, the macOS-defaults script will automatically set up the screenshot save location.

## Global Script Access

Scripts in `scripts/` are symlinked to `~/.local/bin/` via `setup-links`, making them globally accessible.

## Available Commands

```bash
setup-local-config         # Setup local configuration
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