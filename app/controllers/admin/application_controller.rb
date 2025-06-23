class Admin::ApplicationController < ApplicationController
  before_action :ensure_admin

  private

  def ensure_admin
    # 本番環境では適切な認証機能を実装してください
    # 今回はデモ用に認証をスキップします
  end
end