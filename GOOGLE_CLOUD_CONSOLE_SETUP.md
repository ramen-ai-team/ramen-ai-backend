# Google Cloud Console OAuth設定手順

Google認証機能を利用するために、Google Cloud ConsoleでOAuth 2.0クライアントIDを設定する手順です。

## 1. Google Cloud Consoleにアクセス

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 既存のプロジェクトを選択するか、新しいプロジェクトを作成

## 2. 必要なAPIについて

Google OAuth 2.0のID Token検証には特別なAPI有効化は不要です。
使用するエンドポイント (`https://www.googleapis.com/oauth2/v3/tokeninfo`) は自動的に利用可能です。

**注意**: Google+ APIは2019年に廃止されているため、有効化する必要はありません。

## 3. OAuth同意画面の設定

1. 左側のメニューから「APIとサービス」→「OAuth同意画面」を選択
2. ユーザータイプを選択：
   - **外部**: 一般ユーザー向け（推奨）
   - **内部**: Google Workspace組織内のみ
3. アプリケーション情報を入力：
   - **アプリ名**: `ラーメンAI`
   - **ユーザーサポートメール**: 開発者のメールアドレス
   - **デベロッパーの連絡先情報**: 開発者のメールアドレス
4. スコープの設定：
   - 「スコープを追加または削除」をクリック
   - 以下のスコープを追加：
     - `../auth/userinfo.email`
     - `../auth/userinfo.profile`
     - `openid`
5. テストユーザー（開発中のみ）:
   - 開発者とテスター用のメールアドレスを追加

## 4. OAuth 2.0クライアントIDの作成

1. 左側のメニューから「APIとサービス」→「認証情報」を選択
2. 「認証情報を作成」→「OAuth 2.0クライアントID」をクリック
3. アプリケーションの種類を選択：
   - **ウェブアプリケーション**
4. クライアント設定：
   - **名前**: `ラーメンAI Backend`
   - **承認済みのJavaScript生成元**:
     - 開発環境: `http://localhost:3000`
     - 本番環境: `https://your-frontend-domain.com`
   - **承認済みのリダイレクトURI**:
     - React Native用: 設定不要（クライアントサイドOAuth）

## 5. クライアントIDとシークレットの取得

1. 作成されたクライアントIDをクリック
2. **クライアントID**と**クライアントシークレット**をコピー
3. これらの値をRailsの認証情報に設定

## 6. Railsでの認証情報設定

### 開発環境
```bash
EDITOR=vim rails credentials:edit --environment development
```

```yaml
google:
  client_id: "your_client_id_here.apps.googleusercontent.com"
  client_secret: "your_client_secret_here"
```

### 本番環境
```bash
EDITOR=vim rails credentials:edit --environment production
```

```yaml
google:
  client_id: "your_production_client_id.apps.googleusercontent.com"
  client_secret: "your_production_client_secret"
```

## 7. React Native用の追加設定

React Nativeアプリで使用する場合、以下の追加設定が必要です：

### Android用
1. OAuth 2.0クライアントIDで「Android」タイプも作成
2. **パッケージ名**: React Nativeアプリのパッケージ名
3. **SHA-1証明書フィンガープリント**: 開発用とリリース用の両方

### iOS用
1. OAuth 2.0クライアントIDで「iOS」タイプも作成
2. **バンドルID**: React NativeアプリのiOSバンドルID

## 8. テストと確認

1. 設定が完了したら、以下のエンドポイントでテスト：
   ```
   POST /api/v1/auth/google
   Content-Type: application/json

   {
     "token": "google_id_token_here"
   }
   ```

2. 正常に設定されている場合、JWTトークンとユーザー情報が返される

## トラブルシューティング

### よくあるエラー

#### `invalid_client` エラー
- クライアントIDが正しく設定されていない
- OAuth同意画面の設定が不完全

#### `redirect_uri_mismatch` エラー
- 承認済みリダイレクトURIが設定されていない
- URLが完全一致していない（トレイリングスラッシュなど）

#### `access_denied` エラー
- OAuth同意画面でアクセスが拒否された
- スコープの設定が不適切

### デバッグ用ログ

開発中は以下のログで問題を特定：

```ruby
# config/environments/development.rb
config.log_level = :debug

# GoogleTokenVerifierでのログ確認
Rails.logger.debug "Token verification response: #{response.body}"
```

## セキュリティ考慮事項

1. **クライアントシークレット**:
   - 絶対にGitにコミットしない
   - Rails credentialsで暗号化して保存

2. **スコープの最小権限**:
   - 必要最小限のスコープのみ要求
   - `email`, `profile`, `openid`のみ

3. **本番環境の設定**:
   - HTTPS必須
   - 適切なドメインの承認済みオリジン設定

4. **トークンの検証**:
   - 必ずサーバーサイドで署名検証
   - audience (aud) とissuer (iss) のチェック