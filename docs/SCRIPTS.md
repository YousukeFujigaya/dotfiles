# スクリプトリファレンス / Scripts Reference

dotfilesで利用可能な各スクリプトの詳細な説明とオプションについて記載します。

## 概要 / Overview

全てのスクリプトは`setup-links`実行後に`~/.local/bin/`からグローバルにアクセス可能になります。

All scripts become globally accessible from `~/.local/bin/` after running `setup-links`.

---

## インストールスクリプト / Installation Scripts

### `bootstrap`

**概要**: メインのインストールスクリプト  
**用途**: dotfilesの初期インストールとアップデート  
**名前の理由**: システム標準の`install`コマンドとの競合を回避

```bash
curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh
```

#### 実行内容
1. **事前チェック**
   - macOSの確認
   - インターネット接続テスト  
   - gitの存在確認（Command Line Tools自動インストール）
2. **リポジトリクローン**: `~/Repos/github.com/YousukeFujigaya/dotfiles`
3. **セットアップモード選択** (新機能)
   - **[1] フルセットアップ**: 全スクリプト実行（新しいマシン推奨）
   - **[2] アップデートのみ**: Homebrew、開発ツール、リンク更新のみ
   - **[3] セットアップスキップ**: リポジトリ更新のみ

#### 自動化対応
```bash
# 環境変数による非対話実行
BOOTSTRAP_MODE=2 curl -fsSL https://raw.githubusercontent.com/YousukeFujigaya/dotfiles/main/bootstrap | sh
```

#### エラーハンドリング
- エラー発生時に行番号を表示
- 詳細なエラーメッセージ
- 失敗時の復旧手順提示

---

### `setup`

**概要**: 全セットアップスクリプトの統合実行  
**場所**: `scripts/setup`

```bash
setup
```

#### 実行順序
1. `macos-defaults` - システム設定
2. `setup-homebrew` - パッケージマネージャー
3. `setup-links` - 設定ファイルリンク
4. `setup-runtime` → `setup-mise` - 開発環境
5. `setup-zinit` - シェル環境
6. `setup-nvim` - エディタ設定
7. `setup-login` - ログインシェル

---

## システム設定 / System Configuration

### `macos-defaults`

**概要**: macOSのシステム設定とデフォルト値変更  
**対象**: システム環境設定、Finder、Dock等

```bash
macos-defaults
```

#### 主な設定項目

##### システム全般
- ダークモード有効化
- 拡張子の常時表示
- ネットワークディスクでの`.DS_Store`作成無効
- ファイル開封時の警告無効化
- クラッシュレポーター無効化

##### キーボード・トラックパッド
- リピート入力速度最適化
- CapsLockをControlに変更
- "自然な"スクロールを無効（従来方式）
- タップでクリック有効化

##### Dock設定
- 自動表示/非表示
- 最近使用したアプリ表示オフ
- アニメーション効果無効化

##### Finder設定
- 隠しファイル表示（`Shift + .`）
- ステータスバー・パスバー表示
- デフォルトビュー: カラム表示
- デスクトップファイル非表示

#### 注意事項
⚠️ **再起動が必要**: 一部設定はmacOS再起動後に有効になります

---

## パッケージ管理 / Package Management

### `setup-homebrew`

**概要**: Homebrewのインストールと設定  
**対応アーキテクチャ**: Intel (x86_64) & Apple Silicon (arm64)

```bash
setup-homebrew [OPTIONS]
```

#### オプション
| オプション | 説明 |
|------------|------|
| `-s, --skip-apps` | アプリのインストールをスキップ |
| `-v, --verbose` | 詳細出力 |
| `-ud, --update` | Homebrew自体を更新 |

#### 実行内容
1. **アーキテクチャ判定**: Intel/Apple Silicon自動判定
2. **Homebrew インストール**
   - Intel: `/usr/local/bin/brew`
   - Apple Silicon: `/opt/homebrew/bin/brew`
3. **パッケージインストール**: Brewfileからの一括インストール
4. **事前チェック**: Command Line Tools確認

#### Brewfile場所
- `${REPO_DIR}/homebrew/.config/homebrew/Brewfile`
- `${GHQ_ROOT_PATH}/github.com/${GITHUB_USER_NAME}/dotfiles/homebrew/.config/homebrew/Brewfile`

#### 使用例
```bash
# 通常インストール
setup-homebrew

# アプリをスキップしてHomebrewのみ
setup-homebrew --skip-apps

# 詳細出力でデバッグ
setup-homebrew --verbose

# Homebrewを更新してからパッケージインストール
setup-homebrew --update
```

---

### `setup-mise`

**概要**: 開発ランタイム環境の管理  
**前身**: asdfからの移行

```bash
setup-mise [OPTIONS]
```

#### オプション
| オプション | 説明 |
|------------|------|
| `-s, --skip-update` | mise自体の更新をスキップ |

#### 環境変数（XDG準拠）
```bash
export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"
```

#### 実行内容
1. **miseインストール**: Homebrew経由
2. **ツールインストール**: `~/.tool-versions`から読み込み
3. **グローバル設定**: バージョン設定の適用
4. **プラグイン更新**: mise pluginsの最新化

#### サポートツール例
- **Node.js**: `node 18.17.0`
- **Python**: `python 3.11.4`
- **Ruby**: `ruby 3.2.2`
- **Go**: `go 1.21.0`
- **その他**: Java, Rust, PHP, Deno等

#### `.tool-versions` 例
```
node 18.17.0
python 3.11.4
ruby 3.2.2
go 1.21.0
```

---

## 設定ファイル管理 / Configuration Management

### `setup-links`

**概要**: GNU stowを使用した設定ファイルのシンボリックリンク管理  
**最重要**: 他のスクリプトをグローバルアクセス可能にする

```bash
setup-links [OPTIONS]
```

#### オプション
| オプション | 説明 |
|------------|------|
| `-u, --unlink PACKAGES` | 指定パッケージのリンクを解除 |
| `-uall, --unlink-all` | 全リンクを解除 |
| `--clean-broken` | 壊れたシンボリックリンクをクリーンアップ |

#### 実行内容

##### 1. クリーンアップモード (`--clean-broken`)
```bash
setup-links --clean-broken
```
- dotfilesパッケージを指す壊れたリンクを検索
- 対象: `$HOME`, `$HOME/.config`, `$HOME/.local/bin`
- インタラクティブな削除確認

##### 2. リンク解除モード
```bash
# 特定パッケージ
setup-links --unlink vim nvim

# 全パッケージ + スクリプト
setup-links --unlink-all
```

##### 3. 通常リンク作成
```bash
setup-links
```
1. **必要ディレクトリ作成**
   ```
   $XDG_CONFIG_HOME
   $XDG_STATE_HOME  
   $XDG_CACHE_HOME
   $HOME/.ssh (権限700)
   ```

2. **パッケージリンク**: `packages/`内の全ディレクトリをstowでリンク
3. **スクリプトリンク**: `scripts/`内のスクリプトを`$HOME/.local/bin`にリンク

#### ⭐️ グローバルスクリプトアクセス機能
```bash
# この処理により全スクリプトがグローバルアクセス可能に
ln -sf "$DOTFILES_HOME/scripts/"* "$HOME/.local/bin"
```

#### パッケージ構造例
```
packages/
├── zsh/
│   └── .zshrc
├── vim/
│   └── .vimrc
└── git/
    └── .gitconfig
```

#### 安全機能
- **自動バックアップ**: 既存ファイルを`~/.local/state/dotfiles/backup/`に保存
- **インテリジェントリンク**: 正しいリンクは再作成をスキップ
- **安全な上書き**: バックアップ後にリンク作成

---

## シェル環境 / Shell Environment

### `setup-zinit`

**概要**: Zshプラグインマネージャーzinitのインストール

```bash
setup-zinit
```

#### インストール場所
- **クローン先**: `$GHQ_ROOT_PATH/github.com/zdharma-continuum/zinit`
- **シンボリックリンク**: `$XDG_DATA_HOME/zinit/bin`

#### 実行内容
1. **リポジトリ確認**: 既存インストールの更新またはクローン
2. **シンボリックリンク作成**: XDG準拠の場所にリンク
3. **セットアップ完了通知**: 新しいシェルセッションでの利用を案内

#### 利用方法
```bash
# 新しいシェルセッション開始
exec zsh

# または手動で設定読み込み
source ~/.zshenv && source "$XDG_CONFIG_HOME/zsh/.zshrc"
```

---

### `setup-nvim` & `setup-login`

**概要**: エディタとログインシェルの設定

```bash
setup-nvim   # Neovim設定
setup-login  # ログインシェル設定  
```

*詳細は個別の設定ファイル内容に依存*

---

## ユーティリティ関数 / Utility Functions

### バックアップ管理

#### `list_backups`
```bash
list_backups [BACKUP_DIR]
```
**機能**: バックアップファイル一覧表示  
**デフォルト場所**: `$XDG_STATE_HOME/dotfiles/backup`

#### `restore_backup`
```bash
restore_backup BACKUP_FILE [TARGET] [BACKUP_DIR]
```
**機能**: バックアップファイルから復元  
**例**:
```bash
restore_backup ".vimrc.20250109_143022"
restore_backup ".vimrc.20250109_143022" "$HOME/.vimrc"
```

#### `clean_old_backups`
```bash
clean_old_backups [BACKUP_DIR] [KEEP_COUNT]
```
**機能**: 古いバックアップを削除（デフォルト: 最新5個を保持）  
**例**:
```bash
clean_old_backups                    # 最新5個保持
clean_old_backups "" 3              # 最新3個保持
```

### 依存関係チェック

#### `check_dependencies`
```bash
check_dependencies COMMAND1 COMMAND2 ...
```
**機能**: 複数コマンドの存在確認

#### `check_xcode_tools`
```bash
check_xcode_tools
```
**機能**: Command Line Toolsの確認とインストール

#### `check_internet`
```bash
check_internet
```
**機能**: インターネット接続確認

### その他のユーティリティ

#### `safe_symlink`
```bash
safe_symlink SOURCE TARGET
```
**機能**: 安全なシンボリックリンク作成（バックアップ付き）

#### `backup_file`
```bash
backup_file FILE [BACKUP_DIR]  
```
**機能**: ファイルの手動バックアップ

#### `command_exists`
```bash
command_exists COMMAND
```
**機能**: コマンドの存在確認

#### `is_macos`
```bash
is_macos
```
**機能**: macOS判定

---

## 環境変数 / Environment Variables

### グローバル制御
```bash
export SKIP_HOMEBREW=true    # Homebrewセットアップをスキップ
export SKIP_APT=true         # APTパッケージをスキップ（macOSでは自動設定）
export INSTALL_DIR="/path"   # インストール先ディレクトリ変更
```

### XDG Base Directory
```bash
export XDG_CONFIG_HOME="$HOME/.config"        # 設定ファイル
export XDG_DATA_HOME="$HOME/.local/share"     # データファイル  
export XDG_STATE_HOME="$HOME/.local/state"    # 状態ファイル
export XDG_CACHE_HOME="$HOME/.cache"          # キャッシュファイル
```

### mise環境変数
```bash
export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"  
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"
```

---

## トラブルシューティング / Troubleshooting

### よくあるエラー / Common Errors

#### 1. Command Line Tools関連
```bash
# エラー: xcode-select: error: tool 'xcodebuild' requires Xcode
xcode-select --install

# リセットが必要な場合
sudo xcode-select --reset
sudo xcode-select --install
```

#### 2. Homebrew権限エラー
```bash
# 権限の修正
sudo chown -R $(whoami) /usr/local/var/homebrew
sudo chown -R $(whoami) /opt/homebrew  # Apple Silicon

# 再インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
setup-homebrew
```

#### 3. 壊れたシンボリックリンク
```bash
# 自動クリーンアップ
setup-links --clean-broken

# 手動確認
find $HOME -type l ! -exec test -e {} \; -print 2>/dev/null
```

#### 4. mise/開発ツールエラー
```bash
# mise再インストール
brew uninstall mise
brew install mise

# 設定リセット
rm -rf "$XDG_DATA_HOME/mise" "$XDG_CONFIG_HOME/mise"
setup-mise
```

### デバッグ方法 / Debugging

#### 詳細ログ出力
```bash
# bash -x でスクリプト実行をトレース
bash -x setup-homebrew --verbose

# エラー箇所の特定
setup-links 2>&1 | grep -A5 -B5 "ERROR"
```

#### 段階的実行
```bash
# 個別スクリプト実行でエラー箇所を特定
macos-defaults           # システム設定のみ
setup-homebrew        # パッケージ管理のみ
setup-links           # リンク作成のみ
```

#### 状態確認
```bash
# インストール状況確認
which brew mise stow git
brew --version
mise --version

# リンク状況確認  
ls -la ~/.zshrc ~/.vimrc ~/.gitconfig

# バックアップ確認
list_backups
```

---

## 開発・カスタマイズ / Development & Customization

### 新しいスクリプトの追加

1. **スクリプト作成**: `scripts/my-script`
2. **実行権限**: `chmod +x scripts/my-script`  
3. **リンク更新**: `setup-links`
4. **グローバル実行**: `my-script`

### 新しいパッケージの追加

1. **ディレクトリ作成**: `packages/my-config/`
2. **設定ファイル配置**: 適切なディレクトリ構造で配置
3. **リンク作成**: `setup-links`

#### パッケージ構造例
```
packages/my-config/
├── .config/
│   └── my-app/
│       └── config.yaml
└── .my-app-rc
```

### Brewfileカスタマイズ

`homebrew/.config/homebrew/Brewfile`を編集:
```ruby
# CLI tools
brew "fd"
brew "ripgrep"
brew "bat"

# Applications  
cask "visual-studio-code"
cask "docker"

# Fonts
cask "font-fira-code-nerd-font"
```

---

## リファレンス / Reference

### 関連リンク
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [mise Documentation](https://mise.jdx.dev/)
- [Homebrew Documentation](https://docs.brew.sh/)
- [zinit Wiki](https://github.com/zdharma-continuum/zinit/wiki)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

### ファイル配置
```
~/Repos/github.com/YousukeFujigaya/dotfiles/
├── bootstrap          # メインインストーラー
├── scripts/                 # セットアップスクリプト（グローバルアクセス可能）
│   ├── setup          # 統合セットアップ
│   ├── setup-homebrew # Homebrew管理
│   ├── setup-mise     # 開発環境管理
│   ├── setup-links    # シンボリックリンク管理
│   ├── setup-zinit    # シェル環境
│   ├── macos-defaults   # macOS設定
│   ├── common         # 共通設定
│   └── utils            # ユーティリティ関数
├── packages/               # stow管理の設定ファイル
├── homebrew/              # Homebrewパッケージ定義
└── docs/                  # ドキュメント
```

---

最終更新: 2025年1月9日