# セキュリティ設計：セッション管理 → JWT + Spring Security

## 移行概要

| 観点 | 移行前（Struts2） | 移行後（Spring Boot） |
|---|---|---|
| 認証方式 | HttpSession（サーバーサイドステート） | JWT Bearer Token（ステートレス） |
| セッション保持 | サーバーメモリ（`session["loginUser"]`） | クライアント（`localStorage`）|
| 認証チェック | 各 Action で未実装（URL 直打ち可） | Spring Security Filter で全 API を保護 |
| パスワード照合 | 平文比較 | `BCryptPasswordEncoder.matches()` |
| ログアウト | `session.clear()` | クライアント側トークン破棄（サーバー不要） |

---

## JWT 仕様

| 項目 | 値 |
|---|---|
| アルゴリズム | HS256 |
| 有効期限 | 24時間（86400秒） |
| ペイロード | `sub`（username）、`iat`（発行時刻）、`exp`（有効期限） |
| 署名鍵 | `application.yml` の `jwt.secret`（256bit 以上のランダム文字列） |
| 送信方法 | `Authorization: Bearer <token>` ヘッダー |

---

## クラス構成

```
config/
├── SecurityConfig.java      # SecurityFilterChain 定義
jwt/
├── JwtUtil.java             # トークン生成・検証
└── JwtFilter.java           # リクエストごとの認証フィルター
service/
└── UserService.java         # UserDetailsService 実装
```

---

## SecurityConfig

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, JwtFilter jwtFilter) throws Exception {
        http
            .csrf(csrf -> csrf.disable())                    // REST API: CSRF 無効
            .sessionManagement(sm ->
                sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))  // セッション無効
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()  // ログインのみ公開
                .requestMatchers("/h2-console/**").permitAll()  // 開発用
                .anyRequest().authenticated()                // 他はすべて認証必須
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:5173"));  // Vite 開発サーバー
        config.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
```

---

## JwtUtil

```java
@Component
public class JwtUtil {
    @Value("${jwt.secret}")
    private String secret;

    private static final long EXPIRATION_MS = 86400000L; // 24時間

    public String generateToken(String username) {
        return Jwts.builder()
            .setSubject(username)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_MS))
            .signWith(getKey(), SignatureAlgorithm.HS256)
            .compact();
    }

    public String extractUsername(String token) {
        return Jwts.parserBuilder().setSigningKey(getKey()).build()
            .parseClaimsJws(token).getBody().getSubject();
    }

    public boolean isTokenValid(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(getKey()).build().parseClaimsJws(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }

    private Key getKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret));
    }
}
```

---

## JwtFilter

```java
@Component
public class JwtFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res,
                                    FilterChain chain) throws IOException, ServletException {
        String header = req.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if (jwtUtil.isTokenValid(token)) {
                String username = jwtUtil.extractUsername(token);
                UserDetails userDetails = userService.loadUserByUsername(username);
                UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }
        chain.doFilter(req, res);
    }
}
```

---

## 認証フロー（シーケンス）

```
クライアント（Vue.js）                 サーバー（Spring Boot）
     │                                        │
     │  POST /api/auth/login                  │
     │  {"username":"admin","password":"..."}  │
     │──────────────────────────────────────→ │
     │                                        │ UserService.loadUserByUsername()
     │                                        │ passwordEncoder.matches()
     │  200 OK {"token":"eyJ..."}             │ JwtUtil.generateToken()
     │←────────────────────────────────────── │
     │                                        │
     │  authStore.token = "eyJ..."            │
     │  localStorage.setItem(token)           │
     │                                        │
     │  GET /api/books                        │
     │  Authorization: Bearer eyJ...          │
     │──────────────────────────────────────→ │
     │                                        │ JwtFilter: token 検証
     │                                        │ SecurityContext に認証情報を設定
     │  200 OK [...]                          │ BookController.list()
     │←────────────────────────────────────── │
```

---

## application.yml 設定

```yaml
jwt:
  secret: dGhpcyBpcyBhIHNlY3JldCBrZXkgZm9yIGRlbW8gcHVycG9zZQ==
  # ↑ デモ用。本番では環境変数から注入すること

spring:
  security:
    # Spring Boot デフォルトのフォームログインは無効になる
```
