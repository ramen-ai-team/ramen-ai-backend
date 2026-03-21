# MenuReport・Review 機能 設計意思決定ドキュメント

作成日: 2026-03-21

---

## 背景・課題

ユーザーがラーメンを食べた記録を残せる機能を追加したい。
設計検討の中で「投稿」と「レビュー」の役割・粒度・紐づけ先が曖昧だったため、
本ドキュメントで意思決定を記録する。

---

## データモデル（確定）

### Shop（既存）

| カラム | 型 | 備考 |
|---|---|---|
| id | integer | |
| name | string | 店舗名 |
| address | string | 住所 |
| google_map_url | string | unique |

### Menu（既存）

| カラム | 型 | 備考 |
|---|---|---|
| id | integer | |
| shop_id | integer | FK → shops |
| name | string | メニュー名 |

### MenuReport（新規）

**定義: 1ユーザーあたり1メニューにつき1つの「このメニューに関する情報提供」**

menu_genre, menu_noodle, menu_soup は廃止して、menu_report に移行する予定

| カラム | 型 | 備考 |
|---|---|---|
| id | integer | |
| user_id | integer | FK → users, NOT NULL |
| menu_id | integer | FK → menus, NOT NULL |
| genre_id | integer | FK → genres, NOT NULL |
| noodle_id | integer | FK → noodles, NOT NULL |
| soup_id | integer | FK → soups, NOT NULL |

- `has_many_attached :images`（複数画像）
- `user_id + menu_id` に unique 制約

> **意思決定**: MenuReport は訪問ログではなく「メニュー情報の補完・報告」として位置づける。
> そのためユーザーあたり1メニュー1件に限定し、重複登録を防ぐ。
> 命名の理由: "MenuReport" は曖昧、"CheckIn" は訪問記録のニュアンスが強い。
> MenuReport はマスターデータへの「報告・貢献」という意図が明確。

### Review（新規）

**定義: 1ユーザーが同じメニューに何度でも記録できる「訪問履歴」**

| カラム | 型 | 備考 |
|---|---|---|
| id | integer | |
| menu_id | integer | FK → menus, NOT NULL |
| user_id | integer | FK → users, NOT NULL |
| rating | integer | 1〜5, NOT NULL |
| comment | text | nullable |
| visited_at | date | NOT NULL |

> **意思決定**: review は menu_report ではなく menu に直接紐づける。
> 訪問のたびに記録できる履歴として設計する。

> **将来拡張**: カテゴリ別評価（麺・スープ・その他）は別テーブル（review_categories）で対応予定。
> 現時点では rating（総合評価）のみ実装する。

---

## モデル関連図

```
User
 ├── has_many :menu_reports
 └── has_many :reviews

Shop
 └── has_many :menus

Menu
 ├── belongs_to :shop
 ├── has_one :menu_report (per user)   ← user_id + menu_id でユニーク
 └── has_many :reviews

MenuReport
 ├── belongs_to :user
 ├── belongs_to :menu
 ├── belongs_to :genre  (optional)
 ├── belongs_to :noodle (optional)
 ├── belongs_to :soup   (optional)
 └── has_many_attached :images

Review
 ├── belongs_to :menu
 ├── belongs_to :user
 ├── rating     (integer, 1-5)
 ├── comment    (text)
 └── visited_at (date)
```

---

## MenuReport 作成時のメニュー補完ロジック

MenuReport に genre/noodle/soup が指定されたとき、
Menu の menu_genre / menu_noodle / menu_soup が未設定であれば自動作成する。
**既に設定済みの場合は上書きしない**（admin 管理データを尊重）。

```
menu_report.genre  && menu.menu_genre.nil?  → MenuGenre  を作成
menu_report.noodle && menu.menu_noodle.nil? → MenuNoodle を作成
menu_report.soup   && menu.menu_soup.nil?   → MenuSoup   を作成
```

---

## API エンドポイント

| Method | Path | 認証 | 説明 |
|---|---|---|---|
| `GET` | `/api/v1/shops/:shop_id/menus` | 不要 | 店舗のメニュー一覧 |
| `POST` | `/api/v1/menu_reports` | 必要 | 投稿作成（メニュー新規作成も兼ねる） |
| `GET` | `/api/v1/menu_reports/:id` | 不要 | 投稿詳細 |
| `DELETE` | `/api/v1/menu_reports/:id` | 必要 | 投稿削除 |
| `POST` | `/api/v1/menus/:menu_id/reviews` | 必要 | レビュー追加 |
| `PATCH` | `/api/v1/menus/:menu_id/reviews/:id` | 必要 | レビュー更新 |

### POST /api/v1/menu_reports リクエスト

既存メニューに紐づける場合:
```json
{
  "menu_id": 2,
  "genre_id": 3,
  "noodle_id": 1,
  "soup_id": 2,
  "images": ["<multipart>", "<multipart>"]
}
```

メニューを新規作成する場合:
```json
{
  "menu": {
    "shop_id": 1,
    "name": "特製醤油ラーメン"
  },
  "genre_id": 3,
  "noodle_id": 1,
  "soup_id": 2,
  "images": ["<multipart>"]
}
```

- `menu_id` と `menu{}` はどちらか一方のみ（両方指定はエラー）
- 同じ user + menu の menu_report が既に存在する場合は 422

---

## 検討した代替案と却下理由

### 案A: review を menu_report に紐づける

```
menu_report → review (1:1)
```

却下理由: menu_report が「訪問ログ」と「メニュー情報補完」の2つの責務を持ってしまう。
visited_at や rating は訪問ごとに変わるが、genre/noodle/soup は変わらない性質が異なる。

### 案B: menu_report を廃止して review に統合

却下理由: 「1ユーザー1メニューにつき1つの情報補完（genre/noodle/soup）」という制約を
表現できなくなる。また複数画像もレビューとは性質が異なる。

### 案C: review を shop 単位にする

却下理由: このアプリはメニュー単位のレコメンドが核心機能のため、
レビューもメニュー単位で集約する方が整合性が高い。

---

## 将来対応予定

- [ ] カテゴリ別評価（`review_categories` テーブル）
  - 麺の評価 / スープの評価 / その他
- [ ] MenuReport の一覧表示（ユーザープロフィールページ等）
- [ ] メニュー単位の平均評価集計
