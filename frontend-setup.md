# React TypeScript 管理画面フロントエンド構成案

## 🚀 プロジェクト作成

```bash
# 新しいリポジトリ作成
git clone <your-new-repository-url> ramen-ai-admin
cd ramen-ai-admin

# React TypeScript プロジェクト作成
npx create-react-app . --template typescript

# 必要なパッケージインストール
npm install \
  axios \
  react-router-dom \
  @types/react-router-dom \
  react-hook-form \
  @hookform/resolvers \
  yup \
  react-query \
  @tanstack/react-query \
  react-hot-toast \
  lucide-react

# 開発用パッケージ
npm install -D \
  @types/node \
  tailwindcss \
  autoprefixer \
  postcss \
  @tailwindcss/forms

# Tailwind CSS 初期化
npx tailwindcss init -p
```

## 📁 推奨ディレクトリ構成

```
src/
├── components/           # 再利用可能なコンポーネント
│   ├── ui/              # UIベースコンポーネント
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Modal.tsx
│   │   └── Table.tsx
│   ├── layout/          # レイアウトコンポーネント
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   └── Layout.tsx
│   └── forms/           # フォームコンポーネント
│       ├── ShopForm.tsx
│       └── MenuForm.tsx
├── pages/               # ページコンポーネント
│   ├── auth/
│   │   └── LoginPage.tsx
│   ├── shops/
│   │   ├── ShopsPage.tsx
│   │   ├── ShopDetailPage.tsx
│   │   └── ShopFormPage.tsx
│   └── menus/
│       ├── MenusPage.tsx
│       ├── MenuDetailPage.tsx
│       └── MenuFormPage.tsx
├── hooks/               # カスタムフック
│   ├── useAuth.ts
│   ├── useShops.ts
│   └── useMenus.ts
├── services/            # API通信
│   ├── api.ts           # Axios設定
│   ├── auth.ts          # 認証API
│   ├── shops.ts         # ショップAPI
│   └── menus.ts         # メニューAPI
├── types/               # TypeScript型定義
│   ├── auth.ts
│   ├── shop.ts
│   └── menu.ts
├── context/             # React Context
│   └── AuthContext.tsx
├── utils/               # ユーティリティ関数
│   ├── constants.ts
│   └── helpers.ts
└── App.tsx
```

## 🔧 主要ファイルテンプレート

### src/services/api.ts
```typescript
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1/admin';

export const api = axios.create({
  baseURL: API_BASE_URL,
});

// JWT Token interceptor
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### src/types/shop.ts
```typescript
export interface Shop {
  id: number;
  name: string;
  address: string;
  google_map_url: string;
  created_at: string;
  updated_at: string;
  menus?: MenuSummary[];
}

export interface MenuSummary {
  id: number;
  name: string;
  image_url?: string;
}

export interface ShopInput {
  name: string;
  address: string;
  google_map_url: string;
}
```

### src/types/menu.ts
```typescript
export interface Menu {
  id: number;
  name: string;
  image_url?: string;
  created_at: string;
  updated_at: string;
  shop: Shop;
  genre: Genre;
  soup: Soup;
  noodle: Noodle;
}

export interface MenuInput {
  name: string;
  shop_id: number;
  genre_id: number;
  soup_id: number;
  noodle_id: number;
  image?: File;
}

export interface Genre {
  id: number;
  name: string;
}

export interface Soup {
  id: number;
  name: string;
}

export interface Noodle {
  id: number;
  name: string;
}
```

### src/hooks/useAuth.ts
```typescript
import { useState, useEffect } from 'react';
import { authAPI } from '../services/auth';

export interface AuthUser {
  id: number;
  email: string;
}

export const useAuth = () => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('admin_token');
    const userData = localStorage.getItem('admin_user');
    
    if (token && userData) {
      setUser(JSON.parse(userData));
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const response = await authAPI.login(email, password);
    localStorage.setItem('admin_token', response.token);
    localStorage.setItem('admin_user', JSON.stringify(response.admin_user));
    setUser(response.admin_user);
    return response;
  };

  const logout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    setUser(null);
  };

  return {
    user,
    loading,
    isAuthenticated: !!user,
    login,
    logout,
  };
};
```

## 🎨 スタイリング（Tailwind CSS）

### tailwind.config.js
```javascript
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
```

## 🔄 状態管理（React Query）

### src/hooks/useShops.ts
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { shopsAPI } from '../services/shops';
import { Shop, ShopInput } from '../types/shop';

export const useShops = () => {
  return useQuery({
    queryKey: ['shops'],
    queryFn: shopsAPI.getAll,
  });
};

export const useCreateShop = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: ShopInput) => shopsAPI.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shops'] });
    },
  });
};
```

## 🧪 テスト設定

```bash
# Testing libraries
npm install -D \
  @testing-library/react \
  @testing-library/jest-dom \
  @testing-library/user-event \
  msw
```

## 🚀 環境変数（.env）

```env
REACT_APP_API_URL=http://localhost:3000/api/v1/admin
REACT_APP_APP_NAME=ラーメンAI管理画面
```

## 📋 推奨開発フロー

1. **API型定義**: OpenAPI仕様から型を生成
2. **コンポーネント開発**: Storybookでコンポーネント開発
3. **API統合**: React QueryでAPI統合
4. **E2Eテスト**: Cypressでテスト自動化

この構成でモダンで保守性の高い管理画面が構築できます！