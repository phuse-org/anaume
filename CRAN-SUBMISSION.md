# CRAN Submission Notes

このドキュメントは [anaume](https://github.com/phuse-org/anaume) を CRAN
に提出する際に必要となる要件・手順・
過去の対応内容を記録するためのものです。提出のたびに更新してください。

> このファイルは `.github/` 配下にあるため `.Rbuildignore` の
> `^\.github$` により CRAN ビルド (`R CMD build`)
> から自動的に除外されます。

------------------------------------------------------------------------

## 1. 提出前チェックリスト

`DESCRIPTION` の `Version` を更新した

`NEWS.md` に今回のリリース内容を追記した

`roxygen2::roxygenise()`（または `devtools::document()`）を実行し、
`NAMESPACE` と `man/*.Rd` が最新ソースと同期している

ローカルで `R CMD check --as-cran` が ERROR / WARNING なしで通る （残
NOTE は「2. 既知の環境依存 NOTE」を参照）

`devtools::check_win_devel()` を実行し、結果メールを確認した

（推奨）R-hub など複数プラットフォームでチェックした

`cran-comments.md` を用意した（提出時に CRAN へ伝えるコメント）

すべての `aut`（共著者）から CRAN 提出の同意を得た

公式サイト `https://phuse-org.github.io/anaume/` が 200 で応答する

------------------------------------------------------------------------

## 2. 既知の環境依存 NOTE / WARNING

ローカル（オフライン・ツール未整備の環境）では以下が出ることがありますが、
いずれも **パッケージ本体の問題ではなく、CRAN の実環境では解消**
されます。

| 種別 | メッセージ | 原因 |
|----|----|----|
| WARNING | `'qpdf' is needed for checks on size reduction of PDFs` | ローカルに qpdf 未導入 |
| NOTE | `Found the following (possibly) invalid URLs: .../anaume/` | ネットワーク/SSL 証明書失効チェックの制限。URL 自体は有効 |
| NOTE | `unable to verify current time` | インターネット/NTP 未接続 |
| NOTE | `New submission` | 新規パッケージでは必ず付く（正常） |

------------------------------------------------------------------------

## 3. ローカルでの `R CMD check --as-cran` 手順（Windows）

この環境では Rtools が R 4.4.0 と非互換のため `devtools::check()` は
ビルド段階で失敗することがあります。その場合は `R CMD build` /
`R CMD check` を直接呼び出します。Pandoc は RStudio
同梱のものを利用します。

``` powershell
# Pandoc (RStudio 同梱) を環境変数に設定
$pandocDir = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools"
$env:RSTUDIO_PANDOC = $pandocDir
$env:PATH = $pandocDir + ";" + $env:PATH

# tarball をビルド（vignette 込み、PDF マニュアルは省略）
& "C:\Program Files\R\R-4.4.0\bin\R.exe" CMD build . --no-manual

# as-cran チェック
& "C:\Program Files\R\R-4.4.0\bin\R.exe" CMD check anaume_0.1.0.tar.gz --as-cran --no-manual
```

Pandoc / Rtools / qpdf が揃った環境であれば、通常どおり以下でも可:

``` r

devtools::check(args = "--as-cran")
```

------------------------------------------------------------------------

## 4. 過去に対応した必須修正（履歴）

### 0.1.0 初回提出準備（2026-10）

| 箇所 | 問題 | 対応 |
|----|----|----|
| `DESCRIPTION` | maintainer (`cre`) メールがダミー (`first.last@example.com`) | 実アドレスに変更 |
| `DESCRIPTION` | `Authors@R` が複数 [`person()`](https://rdrr.io/r/utils/person.html) を [`c()`](https://rdrr.io/r/base/c.html) で囲まず構文エラー | `c( ... )` で囲んだ |
| `DESCRIPTION` | [`person()`](https://rdrr.io/r/utils/person.html) 第3引数にメールを置き `middle` に誤割当 | `email =` を明示指定 |
| `DESCRIPTION` | 空の email 文字列 `""` | 引数ごと省略 |
| `DESCRIPTION` | フィールド間に空行があり build/roxygenise が失敗 | 空行を削除 |
| `vignettes/anaume.Rmd` | `\VignetteIndexEntry{Gett started}`（タイポ） | `Get started` に修正 |
| `vignettes/anaume.Rmd` | 見出し `Anaysis`（タイポ）、空見出し、TODO プレースホルダ | 修正・整理 |

#### 検証メモ

- ライセンス表記 `Apache License (>= 2)` は `tools:::analyze_license()`
  で `is_standardizable = TRUE`。これが R の正規形であり **変更不要**。
- `Description` 内の頭字語 `PMDA` / `ARD` は初出時に正式名称を展開済みで
  CRAN 要件を満たす。**変更不要**。

------------------------------------------------------------------------

## 5. 参考リンク

- CRAN Repository Policy:
  <https://cran.r-project.org/web/packages/policies.html>
- Writing R Extensions:
  <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>
- R Packages (2e) – Releasing to CRAN: <https://r-pkgs.org/release.html>
- Win-builder: <https://win-builder.r-project.org/>
