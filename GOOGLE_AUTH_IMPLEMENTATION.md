# Google認証機能の実装

## 雑なフローメモ

- フロントエンドからGoogle Oauth同意画面に遷移
- 同意後にFEにコールバックして、トークンを取得する
- トークンをFEからバックエンドに送信
- バックエンドでトークンを検証し、ユーザー情報を取得
- ユーザー情報をDBに保存し、ログインに必要なjwt_tokenを作成
- jwt_tokenをFEに返却
- FEはjwt_tokenをローカルストレージに保存する
- ログイン後のAPIを使う際は、FEはjwt_tokenをAuthorizationヘッダーにセットしてAPIリクエストを送信

## シーケンス図

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Frontend as フロントエンド
    participant Google as Google OAuth
    participant Backend as バックエンドAPI
    participant DB as データベース

    User->>Frontend: ログインボタンクリック
    Frontend->>Google: OAuth認証要求
    Google->>User: Googleログイン画面表示
    User->>Google: 認証情報入力
    Google->>Frontend: 認証コード返却
    Frontend->>Google: アクセストークン要求
    Google->>Frontend: アクセストークン＋ユーザー情報
    Frontend->>Backend: ユーザー情報送信 (POST /auth/google)
    Backend->>DB: ユーザー情報確認/作成
    DB->>Backend: ユーザー情報返却
    Backend->>Frontend: JWTトークン＋ユーザー情報
    Frontend->>User: ログイン完了
```
  å
## APIエンドポイント

### 1. POST /api/v1/auth/google
- **用途**: クライアントサイドOAuth
- **フロー**: フロントエンドで取得したGoogleトークンを検証・処理
- **リクエスト**:
  ```json
  {
    "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdkYzAifQ..."
  }
  ```
- **レスポンス**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "image": "https://lh3.googleusercontent.com/a/default-user"
    }
  }
  ```
