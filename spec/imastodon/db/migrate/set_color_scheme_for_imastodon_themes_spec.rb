# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db', 'migrate', '20260916120000_set_color_scheme_for_imastodon_themes.rb')

RSpec.describe SetColorSchemeForImastodonThemes do
  let(:migration) { described_class.new }

  # マイグレーション内のダミー User クラスで raw JSON を読み書きする（本物の User は settings を型変換するため）
  def settings_of(user)
    JSON.parse(described_class::User.find(user.id).attributes_before_type_cast['settings'])
  end

  def user_with_settings(settings)
    Fabricate(:user).tap { |u| described_class::User.find(u.id).update_column('settings', JSON.generate(settings)) }
  end

  context 'ライト系の独自テーマを選んでいるユーザー' do
    it 'color_scheme が未設定なら light を書き込む' do
      user = user_with_settings('theme' => 'shinycolors')
      migration.up
      expect(settings_of(user)).to include('theme' => 'shinycolors', 'web.color_scheme' => 'light')
    end
  end

  context 'ダーク系の独自テーマを選んでいるユーザー' do
    it 'color_scheme が未設定なら dark を書き込む' do
      user = user_with_settings('theme' => 'sidem')
      migration.up
      expect(settings_of(user)).to include('theme' => 'sidem', 'web.color_scheme' => 'dark')
    end
  end

  context 'color_scheme を既に自分で設定しているユーザー' do
    it '設定を上書きしない' do
      user = user_with_settings('theme' => 'idolmaster', 'web.color_scheme' => 'dark')
      migration.up
      expect(settings_of(user)).to include('web.color_scheme' => 'dark')
    end
  end

  context 'default テーマのユーザー' do
    it '何も変えない' do
      user = user_with_settings('theme' => 'default')
      migration.up
      expect(settings_of(user)).to eq('theme' => 'default')
    end
  end

  context '廃止済みテーマ名が残っているユーザー' do
    it 'theme を default に正規化し color_scheme は触らない' do
      user = user_with_settings('theme' => 'altessimo')
      migration.up
      expect(settings_of(user)).to eq('theme' => 'default')
    end
  end

  context 'settings が空のユーザー' do
    it 'エラーにならない' do
      user = Fabricate(:user)
      expect { migration.up }.to_not raise_error
      expect(user.reload.settings.theme).to eq 'default'
    end
  end
end
