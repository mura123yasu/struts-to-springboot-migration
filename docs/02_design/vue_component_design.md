# Vue コンポーネント構成・画面遷移・Pinia ストア設計

## ディレクトリ構成

```
frontend-app/src/
├── api/
│   ├── client.ts        # Axios インスタンス（ベースURL・インターセプター）
│   ├── auth.ts          # POST /api/auth/login
│   └── books.ts         # GET/POST/PUT/DELETE /api/books
├── components/
│   ├── common/
│   │   ├── AppLayout.vue      # ヘッダー + <RouterView/>
│   │   ├── AppHeader.vue      # ナビゲーションバー
│   │   ├── LoadingSpinner.vue # ローディング表示
│   │   └── ErrorMessage.vue   # エラーメッセージ表示
│   └── book/
│       └── ConfirmModal.vue   # 削除確認ダイアログ
├── router/
│   └── index.ts         # ルート定義 + 認証ガード
├── stores/
│   ├── authStore.ts     # ログイン状態・JWT 管理
│   └── bookStore.ts     # 書籍一覧・詳細の状態管理
├── types/
│   └── index.ts         # TypeScript 型定義
└── views/
    ├── LoginView.vue    # /login
    ├── BookListView.vue # /books
    ├── BookDetailView.vue # /books/:id
    └── BookFormView.vue # /books/new, /books/:id/edit
```

---

## 画面一覧とルーティング

| View | パス | 認証 | 概要 |
|---|---|---|---|
| `LoginView.vue` | `/login` | 不要（ガード除外） | ログインフォーム |
| `BookListView.vue` | `/books` | 必要 | 書籍一覧・検索 |
| `BookDetailView.vue` | `/books/:id` | 必要 | 書籍詳細 |
| `BookFormView.vue` | `/books/new` | 必要 | 書籍新規登録 |
| `BookFormView.vue` | `/books/:id/edit` | 必要 | 書籍編集 |

---

## 画面遷移図

```
未ログイン状態で /books/* にアクセス
        ↓
    /login にリダイレクト
        ↓
   ログイン成功
        ↓
    /books（書籍一覧）
    ├─ 書籍クリック → /books/:id（詳細）
    │       ├─ 「編集」→ /books/:id/edit
    │       └─ 「削除」→ 確認ダイアログ → 削除後 /books
    ├─ 「新規登録」→ /books/new
    │       └─ 登録後 → /books
    └─ 「ログアウト」→ トークン破棄 → /login
```

---

## コンポーネント詳細

### AppLayout.vue

```vue
<template>
  <div>
    <AppHeader />
    <main>
      <RouterView />
    </main>
  </div>
</template>
```

認証が必要なすべての画面は AppLayout をラップして使用。

---

### AppHeader.vue

```
表示内容:
  - ブランド名「図書館管理システム」（/books へのリンク）
  - 「新規登録」ボタン（/books/new）
  - ログアウトボタン（表示名付き）
```

```vue
<script setup lang="ts">
const authStore = useAuthStore()
const router = useRouter()
const logout = () => {
  authStore.logout()
  router.push('/login')
}
</script>
```

---

### LoginView.vue

```
フォーム要素:
  - username テキスト入力
  - password パスワード入力
  - ログインボタン（POST /api/auth/login）

バリデーション: 送信前にフロント側でも空チェック
エラー表示: ErrorMessage.vue でサーバーエラーを表示
成功時: authStore に token + displayName を保存 → /books にナビゲート
```

---

### BookListView.vue

```
検索フォーム:
  - title（テキスト）、author（テキスト）、category（セレクト）
  - 検索ボタン → bookStore.search(params)
  - クリアボタン → 全件再取得

一覧テーブル:
  - ID / タイトル（詳細リンク）/ 著者 / カテゴリ / 出版年 / 操作
  - 「詳細」「編集」「削除」ボタン

削除フロー:
  - 「削除」クリック → ConfirmModal 表示
  - 「確認」→ DELETE /api/books/:id → 一覧を再取得
```

---

### BookDetailView.vue

```
表示項目: BookResponse の全フィールド
操作ボタン:
  - 「一覧へ戻る」→ router.back()
  - 「編集」→ /books/:id/edit
  - 「削除」→ ConfirmModal → DELETE → /books
```

---

### BookFormView.vue（登録・編集共通）

```
モード判定:
  - route.params.id が undefined → 新規登録モード（POST）
  - route.params.id が存在       → 編集モード（GET で初期値取得 → PUT）

フォーム項目: title / author / isbn / category / publishedYear
バリデーション: フロント側でも必須・文字数チェック
サーバーエラー: 400 レスポンスのフィールドエラーを各フィールド下に表示
成功後: router.push('/books')
```

---

### ConfirmModal.vue

```
Props:
  - message: string（確認メッセージ）
  - visible: boolean

Emits:
  - confirm: ()  → 削除実行
  - cancel:  ()  → キャンセル
```

---

## Pinia ストア設計

### authStore.ts

```typescript
interface AuthState {
  token: string | null
  displayName: string | null
}

// アクション
login(credentials: LoginRequest): Promise<void>
  // POST /api/auth/login → token・displayName を state に保存
logout(): void
  // token = null → /login にリダイレクト

// ゲッター
isLoggedIn: boolean  // token !== null
```

**永続化:** `localStorage` に token を保存（ページリロード後も維持）。

---

### bookStore.ts

```typescript
interface BookState {
  books: BookResponse[]
  currentBook: BookResponse | null
  loading: boolean
  error: string | null
}

// アクション
fetchAll(): Promise<void>             // GET /api/books
search(params: SearchParams): Promise<void>  // GET /api/books?...
fetchById(id: number): Promise<void>  // GET /api/books/:id
create(request: BookRequest): Promise<void>  // POST /api/books
update(id: number, request: BookRequest): Promise<void>  // PUT /api/books/:id
remove(id: number): Promise<void>     // DELETE /api/books/:id
```

---

## 認証ガード（router/index.ts）

```typescript
router.beforeEach((to) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    return { path: '/login' }
  }
})
```

---

## Axios インターセプター（api/client.ts）

```typescript
// リクエストインターセプター: JWT を自動付与
instance.interceptors.request.use((config) => {
  const token = authStore.token
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// レスポンスインターセプター: 401 で自動ログアウト
instance.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      authStore.logout()
      router.push('/login')
    }
    return Promise.reject(err)
  }
)
```
