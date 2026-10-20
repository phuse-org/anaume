# Contributing to anaume

`{anaume}` への貢献ありがとうございます。このドキュメントは開発の進め方と
プロジェクト運用の仕組みをまとめたものです。

> このファイルは `.github/` 配下にあるため `.Rbuildignore` の `^\.github$`
> により CRAN ビルドから自動的に除外されます。

---

## 開発の基本フロー

1. ブランチを作成して変更を行う
2. roxygen ドキュメントを再生成する

   ```r
   roxygen2::roxygenise()   # または devtools::document()
   ```

3. テストを実行する

   ```r
   devtools::test()
   ```

4. チェックを実行する（CRAN 提出に関わる場合は `--as-cran`）

   ```r
   devtools::check()
   ```

5. Pull Request を作成する

CRAN 登録に特有の一般要件と検証ツールは
[`.github/CRAN-REQUIREMENTS.md`](CRAN-REQUIREMENTS.md)、
`{anaume}` 固有の提出手順・チェックリストは
[`.github/CRAN-SUBMISSION.md`](CRAN-SUBMISSION.md) を参照してください。

---

## ドキュメントサイト (pkgdown)

本パッケージの公式サイトは **pkgdown** で生成し、GitHub Pages で公開しています。

- 公開 URL: <https://phuse-org.github.io/anaume/>
- サイト設定ファイル: `_pkgdown.yml`
- デプロイ用ワークフロー: `.github/workflows/pkgdown.yaml`

### 更新の仕組み（全自動）

`main` ブランチに push すると、GitHub Actions
（`.github/workflows/pkgdown.yaml`）が自動的にサイトをビルドし、
成果物を **`gh-pages` ブランチ** にデプロイします。
開発者が `gh-pages` ブランチを直接操作する必要はありません。

```
main に push ──▶ Actions が pkgdown ビルド ──▶ gh-pages へデプロイ ──▶ GitHub Pages が公開
```

### `gh-pages` ブランチについて

- **役割**: pkgdown が生成した HTML 成果物を置く専用ブランチ
- **編集禁止**: ビルドのたびに自動で上書きされるため、手動編集しないこと
- ソースコード (`R/`, `man/` 等) はここには含まれません

### なぜ `gh-pages` ブランチに分けているのか

サイトの HTML は「ビルドで生成される成果物」であり、ソースコードとは性質が
異なります。これを `main` に置かず専用ブランチに分離することで、以下の利点が
あります。

1. **`main` をソースだけのきれいな状態に保てる**
   数十〜数百個の `*.html` や `deps/`（CSS/JS）が `main` に混入せず、
   コード本体の差分（diff）が成果物のノイズで埋もれない。

2. **CRAN 提出時の事故を防げる（最重要）**
   成果物を `main` の `docs/` に置く方式だと、その HTML 群が
   パッケージのソースツリーに含まれてしまう。`R CMD build` / `check` で
   `.Rbuildignore` による除外を厳密に管理する必要があり、漏れると
   tarball の肥大化や「non-standard files」NOTE の原因になる。
   `gh-pages` 方式なら成果物が `main` に存在しないため、このリスクが無い。

3. **コミット履歴が汚れない**
   毎ビルドで大量ファイルが書き換わるが、その履歴は `gh-pages` 側に隔離され、
   `main` の履歴は人間の変更だけで追える。

4. **手間はむしろ減る（全自動）**
   開発者が `gh-pages` を触ることは一切なく、`main` に push するだけで
   Actions が自動生成・更新する。`usethis::use_pkgdown_github_pages()` など
   R コミュニティの標準ツールもこの方式を既定にしている。

> まとめると、「ソース（`main`）」と「成果物（`gh-pages`）」を分離するのは、
> `main` を綺麗に保ち、CRAN ビルドの安全性を高めるための標準的な設計です。

### GitHub Pages の公開設定（初回のみ手動）

リポジトリの **Settings → Pages** で以下を設定する必要があります
（Organization 管理者権限が必要）。

- **Source**: Deploy from a branch
- **Branch**: `gh-pages` / `(root)`

この設定を行わないと、ビルドが成功していても URL が 404 になります。

### `gh-pages` ブランチ内の主なファイル

| ファイル / ディレクトリ | 説明 |
|------------------------|------|
| `index.html` / `index.md` | サイトのトップページ（README 由来）|
| `reference/` | 各関数のリファレンス（`man/*.Rd` 由来）|
| `articles/` | vignette から生成した記事ページ |
| `news/` | `NEWS.md` から生成した変更履歴ページ |
| `authors.html` / `authors.md` | 著者情報（`DESCRIPTION` 由来）|
| `LICENSE-text.html` / `.md` | ライセンス全文ページ |
| `404.html` / `404.md` | 404 エラーページ |
| `deps/` | サイトが依存する CSS / JavaScript 一式 |
| `search.json` | サイト内検索用のインデックス |
| `sitemap.xml` | 検索エンジン向けサイトマップ |
| `pkgdown.yml` | pkgdown のビルドメタ情報 |
| `pkgdown.js` / `katex-auto.js` / `lightswitch.js` | サイト動作用スクリプト |
| `logo.png` / `link.svg` | ロゴ・アイコン画像 |
| `llms.txt` | LLM 向けのサイト概要テキスト |
| `.nojekyll` | GitHub Pages の Jekyll 処理を無効化（`deps/` 等の配信に必須）|

---

## コーディング / ドキュメントの方針

- 関数の説明は roxygen2 コメント（`#'`）で記述し、`man/*.Rd` は手動編集しない
- 非標準評価（NSE）で参照するデータ変数名は `R/globals.R` の
  `utils::globalVariables()` に登録し、check の NOTE を回避する
- 変更にはテスト（`tests/testthat/`）を追加する

---

## 問い合わせ

バグ報告・機能要望は
[GitHub Issues](https://github.com/phuse-org/anaume/issues) へお願いします。
