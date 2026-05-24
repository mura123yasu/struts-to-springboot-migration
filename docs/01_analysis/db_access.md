# DB アクセスパターン

## 概要

MyBatis 3.5.x を使用。`SqlSessionFactory` を静的フィールドで保持する `MyBatisUtil` 経由で接続。
各 Action が `try-with-resources` で `SqlSession` を開閉する（トランザクション管理も Action 層が担当）。

---

## DAO 構成

```
MyBatisUtil
  └── SqlSessionFactory（mybatis-config.xml から初期化）
        ├── BookMapper.xml → BookDao インターフェース
        └── UserMapper.xml → UserDao インターフェース
```

### MyBatisUtil

```java
// 静的初期化ブロックで SqlSessionFactory を生成（アプリ起動時に1回）
static {
    InputStream in = Resources.getResourceAsStream("mybatis-config.xml");
    sqlSessionFactory = new SqlSessionFactoryBuilder().build(in);
}
```

---

## BookDao / BookMapper.xml

### SQL 一覧

| メソッド | SQL 種別 | WHERE 条件 | 備考 |
|---|---|---|---|
| `findAll()` | SELECT | `deleted = FALSE` | 全件（削除済み除外）、`ORDER BY id DESC` |
| `search(title, author, category)` | SELECT | `deleted = FALSE` + 動的条件 | 部分一致 / 完全一致を動的 SQL で組み立て |
| `findById(id)` | SELECT | `id = #{id} AND deleted = FALSE` | 1件取得 |
| `insert(book)` | INSERT | - | `useGeneratedKeys=true`（自動採番） |
| `update(book)` | UPDATE | `id = #{id} AND deleted = FALSE` | 全フィールド更新 |
| `delete(id)` | UPDATE | `id = #{id}` | 論理削除（`deleted = TRUE`） |

### 動的 SQL（search メソッド）

```xml
<select id="search" resultMap="bookResultMap">
    SELECT * FROM books WHERE deleted = FALSE
    <if test="title != null and title != ''">
        AND title LIKE CONCAT('%', #{title}, '%')
    </if>
    <if test="author != null and author != ''">
        AND author LIKE CONCAT('%', #{author}, '%')
    </if>
    <if test="category != null and category != ''">
        AND category = #{category}
    </if>
    ORDER BY id DESC
</select>
```

**ポイント:**
- `CONCAT('%', #{title}, '%')` は H2 の MySQL 互換モード（`MODE=MySQL`）前提
- 条件なしで呼び出されることはない（`BookListAction.hasSearchParams()` でガード）

### ResultMap（スネークケース → キャメルケース）

```xml
<resultMap id="bookResultMap" type="Book">
    <result property="publishedYear" column="published_year"/>
    <result property="createdAt"     column="created_at"/>
    <result property="updatedAt"     column="updated_at"/>
    <!-- 他は mapUnderscoreToCamelCase=true で自動変換 -->
</resultMap>
```

---

## UserDao / UserMapper.xml

### SQL 一覧

| メソッド | SQL 種別 | WHERE 条件 | 備考 |
|---|---|---|---|
| `findByUsername(username)` | SELECT | `username = #{username}` | ログイン認証用（1件） |

```xml
<select id="findByUsername" resultMap="userResultMap">
    SELECT * FROM users WHERE username = #{username}
</select>
```

---

## トランザクション管理

```java
// 書き込み系（insert / update / delete）はすべて明示的に commit
try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
    BookDao dao = session.getMapper(BookDao.class);
    dao.insert(book);
    session.commit();   // ← 明示 commit
}
// autoCommit=false がデフォルトのため commit 忘れに注意
```

読み取り系（SELECT）は commit 不要。

---

## H2 設定

```xml
<!-- mybatis-config.xml -->
<property name="url" value="
    jdbc:h2:mem:librarydb;
    INIT=RUNSCRIPT FROM 'classpath:schema.sql'\;RUNSCRIPT FROM 'classpath:data.sql';
    DB_CLOSE_DELAY=-1;
    MODE=MySQL
"/>
```

| パラメータ | 値 | 意味 |
|---|---|---|
| `mem:librarydb` | インメモリDB | 再起動でリセット |
| `INIT=RUNSCRIPT` | schema.sql + data.sql | 起動時に自動実行 |
| `DB_CLOSE_DELAY=-1` | - | JVM 終了までDB保持 |
| `MODE=MySQL` | MySQL 互換 | `CONCAT`・`ON UPDATE` 構文を使用 |

---

## Phase 4 移行時の考慮点

| 項目 | 現状（MyBatis） | 移行後（Spring Data JPA） |
|---|---|---|
| CRUD | 手書き XML SQL | `JpaRepository` メソッド |
| 動的検索 | `<if>` 動的SQL | `Specification` パターン |
| トランザクション | 手動 `session.commit()` | `@Transactional` |
| 接続管理 | `SqlSessionFactory` 直接 | Spring の DataSource 自動管理 |
| ResultMap | スネーク→キャメル明示指定 | JPA エンティティアノテーション |
| H2 初期化 | `INIT=RUNSCRIPT` | `spring.sql.init.schema-locations` |
