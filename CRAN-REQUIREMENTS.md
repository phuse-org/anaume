# CRAN Requirements (Knowledge Share)

このドキュメントは、R パッケージを **CRAN に登録する際に特有の要件**と、
その要件を**検証するツール /
コマンド**を汎用的な知識としてまとめたものです。
特定のパッケージに依存しない一般知識として、他プロジェクトでも再利用できます。

> パッケージ固有の提出手順・チェックリスト・対応履歴は
> [`CRAN-SUBMISSION.md`](https://phuse-org.github.io/anaume/CRAN-SUBMISSION.md)
> を参照してください。

------------------------------------------------------------------------

## 1. CRAN 登録に特有の要件

GitHub で R パッケージを公開するのと異なり、CRAN への登録には **CRAN
独自の ポリシーと手続き**が存在します。ここでは「CRAN
特有」で、かつ見落としやすい
要件を切り口ごとに整理します。各項目の末尾に一次情報（出典）を示します。

### (A) メタデータ (`DESCRIPTION`) の要件

- **`Title` は Title
  Case**（各単語の頭を大文字）で、末尾にピリオドを付けない。
- **`Description` は完全な文**で記述し、ソフトウェア名・API
  名・略語は初出時に
  展開するか単一引用符で囲む。文は大文字で始め、ピリオドで終える。
- **`Authors@R` で著者と役割を明示**する。メンテナ (`cre`) は**ちょうど
  1 名**で、
  **実在する有効なメールアドレス**が必須（確認メールの受信に使われる）。
- **`License` は CRAN が認識する標準表記**を用いる
  （`tools:::analyze_license()` で `is_standardizable = TRUE`
  になること）。
- **`Version`** は数値をドットで区切った形式（例 `0.1.0`）。
- 出典: \[Writing R Extensions §1.1 “The DESCRIPTION file”\]
  (<https://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file>)

### (B) チェック結果の要件

- **`R CMD check --as-cran` が ERROR / WARNING
  ゼロ**であること（必須）。
- **NOTE は可能な限りゼロ**にする。残す場合は `cran-comments.md`
  で理由を説明。
- 新規提出では **`New submission` NOTE
  は不可避**（説明すれば問題ない）。
- 出典: \[CRAN Repository Policy\]
  (<https://cran.r-project.org/web/packages/policies.html>)

### (C) 動作・環境の要件

- **複数プラットフォームで動作**する必要がある（CRAN は Windows / macOS
  / Linux、かつ R-devel / R-release で自動チェックする）。 → 提出前に
  **win-builder (devel + release)** でのチェックを推奨。
- **examples / tests / vignettes
  は妥当な時間内に完了**すること。重い処理は `\donttest{}`
  等で調整する。
- **外部リソース（URL・ファイル・ネットワーク）への依存は最小限**にし、
  `DESCRIPTION` の `URL` は実在して応答するものだけを記載する。
- 出典: \[CRAN Repository Policy\]
  (<https://cran.r-project.org/web/packages/policies.html>)

### (D) ファイル構成・サイズの要件

- **パッケージに含めてよいのは標準的なファイルのみ**。開発用スクリプトや
  生成物は `.Rbuildignore` で除外する（例: `inst/dev/`）。
- **tarball はできるだけ小さく**（目安 5 MB
  未満）。大きなデータは別パッケージ化 や圧縮を検討する。
- **`LICENSE` 全文の同梱ルール**に従う（標準ライセンスは全文を同梱せず、
  `DESCRIPTION` の `License` 指定のみ）。
- 出典: \[Writing R Extensions §1 “Creating R packages”\]
  (<https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Creating-R-packages>)

### (E) 人的・手続き上の要件（CRAN 固有）

- **全著者 (`aut`) の提出同意**が必要（GitHub 公開にはない要件）。
- **提出後の確認メールのクリック**で提出が確定する。
- **新規パッケージは人手レビュー**があり、軽微な指摘で再提出を求められることが
  多い。指摘対応時は `Version` を上げて再提出する。
- **メンテナは継続的なメンテナンス責任**を負う（R
  の更新で生じる不具合への対応、 逆依存パッケージへの配慮など）。
- 出典: \[CRAN Repository Policy\]
  (<https://cran.r-project.org/web/packages/policies.html>)

### まとめ: GitHub 公開との主な違い

| 観点       | GitHub 公開    | CRAN 登録                                |
|------------|----------------|------------------------------------------|
| メタデータ | 任意           | `DESCRIPTION` の厳密な形式が必須         |
| チェック   | 任意           | `--as-cran` で ERROR/WARNING ゼロ必須    |
| 動作環境   | 作者の環境で可 | 複数 OS × 複数 R で動作必須              |
| 著者の同意 | 不要           | **全著者の同意が必要**                   |
| 公開手続き | push のみ      | 提出フォーム + 確認メール + 人手レビュー |
| 公開後     | 任意           | **継続メンテナンス責任**を負う           |

------------------------------------------------------------------------

## 2. 要件を検証するツール / コマンド

§1 で挙げた要件の多く（特に A〜D）は、**ツールで機械的に判定できます**。
ここでは要件カテゴリごとに対応するツールを示します。

### 中核: `R CMD check --as-cran`

**最も重要**なツールです。`--as-cran` を付けると通常チェックに加えて
**CRAN 固有のポリシー検査が有効化**されます。これ 1 つで §1 の A〜D の
大半を検査できます。

``` r

devtools::check(args = "--as-cran")   # ラッパー（推奨）
# または
# R CMD check --as-cran <package>_<version>.tar.gz
```

| §1 の要件               | `--as-cran` での対応チェック項目        |
|-------------------------|-----------------------------------------|
| \(A\) DESCRIPTION 形式  | `checking DESCRIPTION meta-information` |
| \(A\) Title Case / 文章 | `checking CRAN incoming feasibility`    |
| \(A\) メール有効性      | `checking CRAN incoming feasibility`    |
| \(A\) License 標準表記  | 非標準なら警告                          |
| \(B\) ERROR / WARNING   | 全チェック項目                          |
| \(C\) 実行時間          | `checking examples` / `checking tests`  |
| \(C\) 無効 URL          | `checking URLs`（`--as-cran` 時のみ）   |
| \(D\) 非標準ファイル    | `checking top-level files`              |
| \(D\) tarball サイズ    | `checking installed package size`       |

### 要件別の補助ツール

| 要件 | ツール / コマンド | 用途 |
|----|----|----|
| \(A\) スペル・文章 | `spelling::spell_check_package()` | Description・ドキュメントのスペルチェック |
| \(A\) License 標準表記 | `tools:::analyze_license("...")` | `is_standardizable = TRUE` を確認 |
| \(C\) URL 検証 | `urlchecker::url_check()` | DESCRIPTION/Rd/md 内の全 URL の応答を検証 |
| \(C\) 多環境動作 | `devtools::check_win_devel()` / `check_win_release()` | Windows × R-devel/release |
| \(C\) 多環境動作 | `rhub::rhub_check()` | R-hub v2 で Linux/macOS/Windows 横断 |
| \(B\) 提出後の状況 | `foghorn::cran_results("<package>")` | 提出済みパッケージの CRAN チェック結果を取得 |

### 統合: リリース支援ツール

``` r

devtools::release()            # 提出前チェックを総ざらいし対話的に提出まで導く
usethis::use_release_issue()   # GitHub Issue にリリース用チェックリストを自動生成
```

### 推奨する実行順序

``` r

# 1. ドキュメント同期
devtools::document()

# 2. スペルチェック（(A) 補助）
spelling::spell_check_package()

# 3. URL 検証（(C)）
urlchecker::url_check()

# 4. 本体チェック（(A)(B)(C)(D) の大半）★最重要
devtools::check(args = "--as-cran")

# 5. 多環境チェック（(C)）
devtools::check_win_devel()
devtools::check_win_release()
```

### ⚠️ 自動判定できない要件（人手必須）

次の項目は**ツールでは判定できません**。提出手順の中で人的に対応します。

| 要件 | 理由 |
|----|----|
| \(A\) Description が「意味的に完全な文か」 | 文意の理解は不可（スペルは `spelling` で部分的に補助） |
| \(E\) 全著者の同意 | 人的合意 |
| \(E\) 確認メールのクリック | 手動操作 |
| \(E\) 継続メンテナンス責任 | 約束事 |

------------------------------------------------------------------------

## 3. 参考リンク

- CRAN Repository Policy:
  <https://cran.r-project.org/web/packages/policies.html>
- Writing R Extensions:
  <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>
- R Packages (2e) – Releasing to CRAN: <https://r-pkgs.org/release.html>
- Win-builder: <https://win-builder.r-project.org/>
