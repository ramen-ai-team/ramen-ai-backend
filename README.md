## Setup

DevContainerによる開発環境の構築
1. VSCodeを開く
2. 左下の「><」アイコンをクリック
3. 「Reopen in Container」を選択
4. コンテナが立ち上がるまで待つ
5. ターミナルを開く


## API

### `/api/v1/random_menus`
- メソッド: `GET`
- 説明: ランダムなメニューを取得する
- input: `limit` (optional) - 取得するメニューの数 (default: 10)

### `/api/v1/recommended_menus`
- メソッド: `POST`
- 説明: 好みを渡して、それに対してAIがおすすめを取得する
- params menu_ids: [1,2]