#!/bin/sh

echo 📌 Configuring macOS default settings

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
# sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=%00

###########################################################
# for System
###########################################################
defaults write "Apple Global Domain" AppleInterfaceStyle -string Dark # Dark Mode に設定
defaults write NSGlobalDomain AppleShowAllExtensions -bool true # 拡張子を常に表示
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # ネットワークディスクで、`.DS_Store` ファイルを作らない
defaults write com.apple.LaunchServices LSQuarantine -bool false # ファイルを開く際の警告ダイアログを無効に
defaults write -g NSWindowResizeTime -float 0.001 # ダイアログ表示やウィンドウリサイズ速度を高速化
defaults write com.apple.CrashReporter DialogType none # クラッシュリポーターを無効にする
defaults write com.apple.Preview NSQuitAlwaysKeepsWindows -bool false # 起動時に前回開いたウィンドウを開かない
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true # ウインドウの視覚効果を減らす
defaults write -g NSScrollViewRubberbanding -bool no # スクロール時ののバウンドアニメーションを無効に

# chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library # 「ライブラリ」を常に表示
# defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # ファイルの保存場所のデフォルトをiCloud以外にする

# sleep or screen saver mode （スリープまたはスクリーンセーバから復帰した際、パスワードをすぐに要求する）
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

### Hot corners （Mission Control のホットコーナーの設定）
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# Bottom left screen corner
defaults write com.apple.dock wvous-bl-corner -int 10 # 10: Put display to sleep
defaults write com.apple.dock wvous-bl-modifier -int 0

###########################################################
# Keyboard
###########################################################
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true # Fuキーを標準のファンクションキーとして使用
defaults write NSGlobalDomain KeyRepeat -int 1 # リピート入力のスピードをはやく
defaults write NSGlobalDomain InitialKeyRepeat -int 14 # リピート入力認識時間
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false # スペルの訂正を無効にする

# CapsLock を Ctrl に変更する (need to restart macOS)
# get string like : 1452-630-0 for keyboard_id
keyboard_id="$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-\n' -)-0"
defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboard_id} -array-add "
<dict>
  <key>HIDKeyboardModifierMappingDst</key>\
  <integer>30064771300</integer>\
  <key>HIDKeyboardModifierMappingSrc</key>\
  <integer>30064771129</integer>\
</dict>
"

###########################################################
# Trackpad, Mouse
###########################################################
defaults write -g com.apple.swipescrolldirection -bool false # スクロール方向をunnaturalに
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0 # 3finger horizontal swipe を無効に

defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

defaults write -g com.apple.trackpad.scaling -float 2.5
defaults write -g com.apple.mouse.scaling -float 1.5

# Enable `Tap to click` （タップでクリックを有効にする）
defaults write -g com.apple.trackpad.forceClick -int 0 # forceClickをオフ
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1 # タップクリックをオン
defaults write -g com.apple.mouse.tapBehavior -int 1 # 軽いタップでクリックする

# defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton

###########################################################
# Dock
###########################################################
defaults write com.apple.dock autohide -bool true # Dockの自動表示をオフに
defaults write com.apple.dock show-recents -bool false # 最近使用したアプリのDock表示をオフに
defaults write com.apple.dock showhidden -bool true # 隠したアプリをDockに透過表示する
defaults write com.apple.dock mru-spaces -bool false # Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock autohide-delay -float 10000 # Dock表示速度を指定
defaults write com.apple.dock autohide-time-modifier -float 0
# defaults write com.apple.dock orientation -string right
# defaults write com.apple.dock tilesize -float 24
defaults write com.apple.dock launchanim -bool false #起動中アプリのバウンドをオフに

# Dockにウィンドウを格納する時のエフェクト設定
# defaults write com.apple.dock mineffect -string "scale"
# defaults write com.apple.dock mineffect -string "genie"

###########################################################
# Finder
###########################################################
defaults write com.apple.finder QuitMenuItem -bool true # FinderをQuitできるように
defaults write com.apple.finder CreateDesktop -boolean false # Desktop上のファイル等を非表示に
defaults write com.apple.finder FinderSounds -bool no # Finderの効果音を無効にする
defaults write com.apple.finder AppleShowAllFiles YES # `Shift + .`で隠しファイルや隠しフォルダを表示
defaults write com.apple.finder ShowStatusBar -bool true # ステータスバーを表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES # タイトルバーにフルパスを表示
defaults write com.apple.finder DisableAllAnimations -bool true # Finderのアニメーション効果を全て無効にする
defaults write com.apple.finder AnimateWindowZoom -bool false # フォルダを開くときのアニメーションを無効
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false # ファイルを開くときのアニメーションを無効
# defaults write com.apple.finder AnimateInfoPanes -boolean false
# defaults write com.apple.finder AnimateSnapToGrid -boolean false # ドラッグ時のアニメーションをオフに

# Show icons for hard drives, servers, and removable media on the desktop
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
# defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
# defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv" # デフォルトはカラムビュー表示

defaults write com.apple.finder QLHidePanelOnDeactivate -bool true # 他のウィンドウに移った時にQuick Lookを非表示する
defaults write com.apple.finder QLEnableTextSelection -bool true # Quick Look上でテキストの選択を可能に

# defaults write com.apple.finder WarnOnEmptyTrash -bool false # Disable the warning before emptying the Trash

###########################################################
# Menu Bar
###########################################################
# defaults write NSGlobalDomain _HIHideMenuBar -bool true # メニューバーを常に非表示に

# 日付と時刻のフォーマット（24時間表示、日付・曜日を表示）
# defaults write com.apple.iCal "number of hours displayed" 24 # 24 hour view for Menu Bar
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm:ss"

# Hide the battery percentage from the menu bar （バッテリーのパーセントを表示する）
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

###########################################################
# Applications
###########################################################
### Safari
defaults write com.apple.Safari AutoFillPasswords -bool false # パスワードを自動入力・記録しない

### Quick Time Player
defaults write com.apple.QuickTimePlayerX NSQuitAlwaysKeepsWindows -bool false # 起動時に前回開いたファイルを開かない

###########################################################
# Screenshot
###########################################################
defaults write com.apple.screencapture location ~/Screenshot # キャプチャの保存場所を変更
defaults write com.apple.screencapture disable-shadow -boolean true # キャプチャに影を付けない

### NOTE: To enable these settings, Need to Restart macOS