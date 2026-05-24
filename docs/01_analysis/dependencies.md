# 依存ライブラリ一覧

## pom.xml サマリー

| 項目 | 値 |
|---|---|
| groupId | `com.example` |
| artifactId | `legacy-app` |
| Java バージョン | 11（ソース/ターゲット）|
| ビルドツール | Maven |
| パッケージング | WAR |

---

## 依存ライブラリ一覧

### フレームワーク

| ライブラリ | バージョン | スコープ | 役割 | 移行後の対応 |
|---|---|---|---|---|
| `struts2-core` | 2.5.33 | compile | MVC フレームワーク本体 | Spring Web (`@RestController`) |
| `struts2-convention-plugin` | 2.5.33 | compile | アノテーションルーティング（今回は未使用） | 削除 |

### データアクセス

| ライブラリ | バージョン | スコープ | 役割 | 移行後の対応 |
|---|---|---|---|---|
| `mybatis` | 3.5.16 | compile | SQL マッパー | Spring Data JPA + Hibernate |

### データベース

| ライブラリ | バージョン | スコープ | 役割 | 移行後の対応 |
|---|---|---|---|---|
| `h2` | 2.2.224 | compile | インメモリ DB | そのまま（H2 継続） |

### ビュー

| ライブラリ | バージョン | スコープ | 役割 | 移行後の対応 |
|---|---|---|---|---|
| `jstl` | 1.2 | compile | JSP タグライブラリ | 削除（Vue.js SPA へ） |
| `standard` (taglibs) | 1.1.2 | compile | JSTL 実装 | 削除 |

### サーブレット API（provided）

| ライブラリ | バージョン | スコープ | 役割 |
|---|---|---|---|
| `javax.servlet-api` | 3.1.0 | provided | Servlet 3.1 API |
| `javax.servlet.jsp-api` | 2.3.3 | provided | JSP API |

### テスト

| ライブラリ | バージョン | スコープ | 役割 | 移行後の対応 |
|---|---|---|---|---|
| `junit` | 4.13.2 | test | ユニットテスト | JUnit 5 + Spring Boot Test |

---

## ビルドプラグイン

| プラグイン | バージョン | 用途 |
|---|---|---|
| `tomcat7-maven-plugin` | 2.2 | ローカル開発用 Tomcat 7 起動（`mvn tomcat7:run`） |

---

## 移行時の注意点

### Struts2 → Spring Boot

- `struts2-core` は Spring Boot の `spring-boot-starter-web` に置き換え
- Struts2 の `ActionSupport` / `SessionAware` / `@Namespace` 等の概念はすべて廃止
- JSP + JSTL は Vue.js SPA に完全移行（`jstl`, `standard`, `jsp-api` は削除）

### MyBatis → Spring Data JPA

- `mybatis` は `spring-boot-starter-data-jpa` に置き換え
- Mapper XML → JPA エンティティ + `JpaRepository`
- 動的 SQL は `Specification` パターンまたは `@Query(nativeQuery=true)` で対応

### Java バージョン

- 現在: Java 11（ソース/ターゲット）、JDK 21 でビルド可能
- 移行後: Java 21（Spring Boot 3.x の最小要件は Java 17）

### H2 バージョン

- 現在: H2 2.2.224（MySQL 互換モード使用）
- 移行後: Spring Boot が管理するバージョンをそのまま使用予定
- `CONCAT` / `MODE=MySQL` 依存は JPA クエリ書き換えで解消される
