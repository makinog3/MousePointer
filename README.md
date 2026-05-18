# MousePointer

macOS のプレゼン・デモ向けマウス可視化アプリ。通常時は普通のカーソルのまま、シェイクとクリックのときだけ目立つエフェクトを表示します。

## エフェクト

| 操作 | エフェクト |
|------|-----------|
| マウスを素早く左右に振る | 琥珀色 (#f0a500) の2リングがカーソル周囲に現れ、脈動する |
| 振るのをやめる | 約1秒でフェードアウト |
| 左クリック | シアン (#00cfff) のリップルがクリック位置から広がる (0.4秒) |

## 動作環境

- macOS 15 (Sequoia) 以降
- Apple Silicon / Intel 両対応
- 複数モニター対応

## インストール

1. [Releases](https://github.com/makinog3/MousePointer/releases) から `MousePointer.app` をダウンロード
2. `~/Applications` または `/Applications` に移動
3. 右クリック → 「開く」で初回起動（Gatekeeper を通す）
4. アクセシビリティ権限のダイアログで「設定を開く」→ MousePointer にチェック
5. アプリを再起動

> Dock アイコンは表示されません。終了は Cmd+Q または `killall MousePointer`。

## ソースからビルド

```bash
git clone https://github.com/makinog3/MousePointer.git
cd MousePointer
open MousePointer.xcodeproj
```

Xcode で Run (⌘R)。初回はアクセシビリティ権限の付与が必要です。

## 感度の調整

`MousePointer/Core/ShakeDetector.swift` の定数で調整できます。

```swift
static let windowDuration: TimeInterval = 0.5   // 判定ウィンドウ（秒）
static let requiredReversals            = 3      // 必要な方向転換回数
static let minDistance: CGFloat         = 30.0   // 1スイングの最小移動量（pt）
static let cooldownDuration: TimeInterval = 0.6  // シェイク終了判定までの待機（秒）
```

- `minDistance` を小さくすると敏感に、大きくすると鈍感になります
- `windowDuration` を長くするとゆっくりしたシェイクも検出します

## 技術メモ

- CGEventTap (`.listenOnly`) でグローバルマウスイベントを監視
- 透明フルスクリーン `NSWindow` + Core Animation (`CAShapeLayer`) でエフェクトを描画
- `LSUIElement = YES` によりバックグラウンド専用アプリとして動作
- シェイク判定は per-swing 累積距離方式（per-event delta では 60Hz 時に閾値を超えないため）

## ライセンス

MIT
