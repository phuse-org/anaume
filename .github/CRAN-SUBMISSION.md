# CRAN Submission Notes

このドキュメントは `{anaume}` を CRAN に提出する際に必要となる手順・
チェックリスト・過去の対応内容を記録するためのものです。提出のたびに
更新してください。

> このファイルは `.github/` 配下にあるため `.Rbuildignore` の `^\.github$`
> により CRAN ビルド (`R CMD build`) から自動的に除外されます。

> **CRAN 登録に特有の一般要件と、それを検証するツール**については、
> 汎用的な知識共有ドキュメント [`CRAN-REQUIREMENTS.md`](CRAN-REQUIREMENTS.md)
> にまとめています。本書はそれを前提に、`{anaume}` 固有の実務を扱います。

---

## 1. 提出前チェックリスト

- [ ] `DESCRIPTION` の `Version` を更新した
- [ ] `NEWS.md` に今回のリリース内容を追記した
- [ ] `roxygen2::roxygenise()`（または `devtools::document()`）を実行し、
      `NAMESPACE` と `man/*.Rd` が最新ソースと同期している
- [ ] ローカルで `R CMD check --as-cran` が ERROR / WARNING なしで通る
      （残 NOTE は「2. 既知の環境依存 NOTE」を参照）
- [ ] `devtools::check_win_devel()` を実行し、結果メールを確認した
- [ ] `devtools::check_win_release()` を実行し、結果メールを確認した
- [ ] （推奨）R-hub など複数プラットフォームでチェックした
- [ ] `cran-comments.md` を用意した（提出時に CRAN へ伝えるコメント）
- [ ] すべての `aut`（共著者）から CRAN 提出の同意を得た
- [ ] 公式サイト `https://phuse-org.github.io/anaume/` が 200 で応答する

---

## 2. 既知の環境依存 NOTE / WARNING

ローカル（オフライン・ツール未整備の環境）では以下が出ることがありますが、
いずれも **パッケージ本体の問題ではなく、CRAN の実環境では解消** されます。

| 種別 | メッセージ | 原因 |
|------|-----------|------|
| WARNING | `'qpdf' is needed for checks on size reduction of PDFs` | ローカルに qpdf 未導入 |
| NOTE | `Found the following (possibly) invalid URLs: .../anaume/` | ネットワーク/SSL 証明書失効チェックの制限。URL 自体は有効 |
| NOTE | `unable to verify current time` | インターネット/NTP 未接続 |
| NOTE | `New submission` | 新規パッケージでは必ず付く（正常）|

---

## 3. ローカルでの `R CMD check --as-cran`

開発ツール（Rtools / Pandoc / qpdf）が正しく揃った環境であれば、以下だけで
チェックできます。

```r
devtools::check(args = "--as-cran")
```

### 補足: 環境が未整備の場合の回避策

> ここで述べる Rtools 非互換や Pandoc 未検出は **特定の開発 PC の環境問題**
> であり、パッケージ自体の問題ではありません。本来は Rtools / Pandoc を
> 正しく導入すれば上記 1 行で済みます。環境を整備できない場合の一時的な
> 回避策として以下を記録します。

Rtools がインストール済み R のバージョンと非互換だと `devtools::check()` は
ビルド段階で失敗することがあります。その場合は `R CMD build` / `R CMD check`
を直接呼び出し、Pandoc は別途導入済みのもの（例: RStudio 同梱）を環境変数で
指定します。

```powershell
# Pandoc のパスを環境変数に設定（導入済みの場所に合わせる）
$pandocDir = "<pandoc.exe のあるディレクトリ>"
$env:RSTUDIO_PANDOC = $pandocDir
$env:PATH = $pandocDir + ";" + $env:PATH

# tarball をビルド（vignette 込み、PDF マニュアルは省略）
R CMD build . --no-manual

# as-cran チェック
R CMD check anaume_0.1.0.tar.gz --as-cran --no-manual
```

---

## 3-2. win-builder でのチェック（CRAN と同等の Windows 環境）

ローカル環境に依存せず、CRAN が実際に使う Windows 環境でチェックできます。
tarball がサーバーへアップロードされ、**結果はメンテナのメール宛に届きます**
（通常 15〜30 分、混雑時は数時間）。CRAN は提出時に devel・release の両方で
チェックするため、**両方を実行しておく**ことを推奨します。

```r
devtools::check_win_devel()     # 開発版 R (R-devel)
devtools::check_win_release()   # 安定版 R (R-release)
```

### `check_win_devel()` と `check_win_release()` の違い

| 関数 | 使用する R | 目的 |
|------|-----------|------|
| `check_win_devel()` | **R-devel**（次期リリースの開発版）| 将来の R で新たに発生する警告・非互換を**先回りで検出**する。CRAN が新規/更新パッケージで特に重視する |
| `check_win_release()` | **R-release**（現在の安定版）| 一般ユーザーが実際に使う環境で問題なく動くことを確認する |
| （参考）`check_win_oldrelease()` | **R-oldrelease**（1 つ前の安定版）| 旧バージョンの R との後方互換を確認する（任意）|

> devel と release の両方がクリーンであれば、CRAN の自動チェックで
> R バージョン起因の指摘を受ける可能性を大きく減らせます。

---

## 4. 過去に対応した必須修正（履歴）

### 0.1.0 初回提出準備（2026-10）

| 箇所 | 問題 | 対応 |
|------|------|------|
| `DESCRIPTION` | maintainer (`cre`) メールがダミー (`first.last@example.com`) | 実アドレスに変更 |
| `DESCRIPTION` | `Authors@R` が複数 `person()` を `c()` で囲まず構文エラー | `c( ... )` で囲んだ |
| `DESCRIPTION` | `person()` 第3引数にメールを置き `middle` に誤割当 | `email =` を明示指定 |
| `DESCRIPTION` | 空の email 文字列 `""` | 引数ごと省略 |
| `DESCRIPTION` | フィールド間に空行があり build/roxygenise が失敗 | 空行を削除 |
| `vignettes/anaume.Rmd` | `\VignetteIndexEntry{Gett started}`（タイポ）| `Get started` に修正 |
| `vignettes/anaume.Rmd` | 見出し `Anaysis`（タイポ）、空見出し、TODO プレースホルダ | 修正・整理 |

#### 検証メモ
- ライセンス表記 `Apache License (>= 2)` は `tools:::analyze_license()` で
  `is_standardizable = TRUE`。これが R の正規形であり **変更不要**。
- `Description` 内の頭字語 `PMDA` / `ARD` は初出時に正式名称を展開済みで
  CRAN 要件を満たす。**変更不要**。

---

## 5. CRAN への提出手順

### 5.1 提出の前提条件（提出ボタンを押す前に）

- 「1. 提出前チェックリスト」がすべて完了している
- `cran-comments.md` が最新の `R CMD check` / win-builder 結果と一致している
- **メンテナ (`cre`) のメールアドレスで確認メールを受け取れる**こと
  （`shunsuke.goto@novartis.com`。企業メールの場合、CRAN からの外部メールが
  スパム/隔離されないか事前に確認する）

### 5.2 共著者の同意（CRAN ポリシー）

`DESCRIPTION` の `aut`（著者）全員が提出に同意している必要があります。
本パッケージは以下の 5 名が関与しています。提出前に全員の合意を得てください。

- Shunsuke Goto（cre, aut）
- Tomoyuki Namai（aut）
- Hiro Kosako（aut）
- Yuichi Nakajima（aut）
- Hiroki Yamanobe（aut）

### 5.3 提出の方法

いずれか一方で提出します。

**方法 A: R から提出（推奨）**

```r
devtools::submit_cran()
```

実行すると tarball がビルドされ、CRAN の提出フォームへ送信されます。
`cran-comments.md` の内容が自動的にコメント欄へ添付されます。

**方法 B: Web フォームから提出**

1. tarball を作成する（「3. ローカルでの手順」参照）
2. <https://cran.r-project.org/submit.html> を開く
3. パッケージ名・バージョン・メンテナ情報・tarball をアップロード
4. `cran-comments.md` の内容をコメント欄に貼り付ける

### 5.4 提出後の対応

1. **確認メールのクリック**
   提出直後、メンテナ宛に確認メール（subject に `CRAN submission` 等）が届く。
   本文のリンクをクリックして提出を確定する。**これを行わないと受理されない。**

2. **自動チェックの結果を待つ**
   CRAN の incoming でマルチプラットフォームの自動チェックが走る。
   問題があればメールで通知される。

3. **人手レビュー**
   新規パッケージ（New submission）は CRAN チームによる手動レビューが入る。
   数日〜1 週間程度かかり、軽微な指摘で 1〜2 往復することが多い。

4. **指摘への対応**
   指摘が来たら、該当箇所を修正し、`DESCRIPTION` の `Version` を上げ、
   `cran-comments.md` に対応内容（Resubmission）を追記して再提出する。

### 5.5 受理後の対応

- Git にリリースタグを打つ（例: `git tag v0.1.0 && git push --tags`）
- GitHub Release を作成する（pkgdown ワークフローの `release` トリガで
  サイトも更新される）
- 次の開発に向けて `Version` を開発版（例: `0.1.0.9000`）へ更新する

---

## 6. 参考リンク

- CRAN Repository Policy: <https://cran.r-project.org/web/packages/policies.html>
- Writing R Extensions: <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>
- R Packages (2e) – Releasing to CRAN: <https://r-pkgs.org/release.html>
- Win-builder: <https://win-builder.r-project.org/>
