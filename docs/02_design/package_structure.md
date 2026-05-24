# パッケージ構成図

## migration-app（Spring Boot REST API）

```
migration-app/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/com/example/migration/
    │   │   ├── MigrationAppApplication.java   # @SpringBootApplication
    │   │   │
    │   │   ├── config/
    │   │   │   └── SecurityConfig.java        # JWT Filter・CORS・CSRF 設定
    │   │   │
    │   │   ├── jwt/
    │   │   │   ├── JwtUtil.java               # トークン生成・検証
    │   │   │   └── JwtFilter.java             # OncePerRequestFilter
    │   │   │
    │   │   ├── controller/
    │   │   │   ├── AuthController.java        # POST /api/auth/login
    │   │   │   └── BookController.java        # GET/POST/PUT/DELETE /api/books
    │   │   │
    │   │   ├── service/
    │   │   │   ├── UserService.java           # UserDetailsService 実装
    │   │   │   └── BookService.java           # CRUD + 検索ロジック
    │   │   │
    │   │   ├── repository/
    │   │   │   ├── UserRepository.java        # JpaRepository<User, String>
    │   │   │   └── BookRepository.java        # JpaRepository<Book, Long> + JpaSpecificationExecutor
    │   │   │
    │   │   ├── entity/
    │   │   │   ├── User.java                  # @Entity: users テーブル
    │   │   │   └── Book.java                  # @Entity: books テーブル
    │   │   │
    │   │   ├── dto/
    │   │   │   ├── LoginRequest.java          # POST /api/auth/login リクエスト
    │   │   │   ├── LoginResponse.java         # JWT トークンレスポンス
    │   │   │   ├── BookRequest.java           # 書籍登録・更新リクエスト（@Valid）
    │   │   │   └── BookResponse.java          # 書籍レスポンス（エンティティ隠蔽）
    │   │   │
    │   │   ├── specification/
    │   │   │   └── BookSpecification.java     # 動的検索（Specification パターン）
    │   │   │
    │   │   └── exception/
    │   │       └── GlobalExceptionHandler.java # @RestControllerAdvice（400/401/404/500）
    │   │
    │   └── resources/
    │       ├── application.yml                # DB・JWT・CORS 設定
    │       ├── schema.sql                     # テーブル定義（legacy-app と同一）
    │       └── data.sql                       # 初期データ（BCrypt ハッシュ済み）
    │
    └── test/
        └── java/com/example/migration/
            ├── controller/
            │   └── BookControllerTest.java    # MockMvc を使った Controller テスト
            └── service/
                └── BookServiceTest.java       # Mockito を使った Service テスト
```

---

## frontend-app（Vue.js SPA）

```
frontend-app/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── src/
    ├── main.ts                  # アプリエントリ（createApp → Pinia → Router → mount）
    ├── App.vue                  # ルートコンポーネント（<RouterView/>）
    │
    ├── api/
    │   ├── client.ts            # Axios インスタンス + JWT インターセプター + 401 自動ログアウト
    │   ├── auth.ts              # login(request): LoginResponse
    │   └── books.ts             # fetchAll / search / fetchById / create / update / remove
    │
    ├── components/
    │   ├── common/
    │   │   ├── AppLayout.vue    # ヘッダー + <slot>/<RouterView/>
    │   │   ├── AppHeader.vue    # ナビゲーション（ログアウトボタン含む）
    │   │   ├── LoadingSpinner.vue
    │   │   └── ErrorMessage.vue
    │   └── book/
    │       └── ConfirmModal.vue # 削除確認ダイアログ（emit: confirm / cancel）
    │
    ├── router/
    │   └── index.ts             # createRouter + meta.requiresAuth + beforeEach ガード
    │
    ├── stores/
    │   ├── authStore.ts         # token / displayName / isLoggedIn / login() / logout()
    │   └── bookStore.ts         # books / currentBook / loading / error + 各アクション
    │
    ├── types/
    │   └── index.ts             # BookResponse / BookRequest / LoginRequest / LoginResponse / SearchParams
    │
    └── views/
        ├── LoginView.vue        # /login
        ├── BookListView.vue     # /books（検索フォーム + テーブル + 削除確認）
        ├── BookDetailView.vue   # /books/:id
        └── BookFormView.vue     # /books/new & /books/:id/edit（モード判定）
```

---

## 依存関係の流れ（migration-app）

```
[HTTP Request]
     ↓
JwtFilter（トークン検証 → SecurityContext に認証情報設定）
     ↓
SecurityConfig（認証チェック）
     ↓
AuthController / BookController
     ↓
UserService / BookService（@Transactional）
     ↓
UserRepository / BookRepository + BookSpecification
     ↓
[H2 Database]
```

---

## pom.xml 主要依存関係（migration-app）

```xml
<dependencies>
    <!-- Spring Boot -->
    <dependency>spring-boot-starter-web</dependency>
    <dependency>spring-boot-starter-data-jpa</dependency>
    <dependency>spring-boot-starter-security</dependency>
    <dependency>spring-boot-starter-validation</dependency>

    <!-- JWT -->
    <dependency>io.jsonwebtoken:jjwt-api:0.11.5</dependency>
    <dependency>io.jsonwebtoken:jjwt-impl:0.11.5</dependency>
    <dependency>io.jsonwebtoken:jjwt-jackson:0.11.5</dependency>

    <!-- DB -->
    <dependency>com.h2database:h2</dependency>

    <!-- Utility -->
    <dependency>org.projectlombok:lombok</dependency>

    <!-- Test -->
    <dependency>spring-boot-starter-test</dependency>

    <!-- CI: カバレッジ + 静的解析 -->
    <!-- JaCoCo: pom.xml plugins に jacoco-maven-plugin -->
    <!-- Checkstyle: pom.xml plugins に maven-checkstyle-plugin -->
</dependencies>
```

---

## package.json 主要スクリプト（frontend-app）

```json
{
  "scripts": {
    "dev":        "vite",
    "build":      "vue-tsc && vite build",
    "type-check": "vue-tsc --noEmit -p tsconfig.app.json",
    "lint":       "eslint . --ext .vue,.ts,.tsx --fix",
    "test":       "vitest",
    "coverage":   "vitest run --coverage"
  }
}
```
