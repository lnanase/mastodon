# frozen_string_literal: true

# imastodon 独自テーマは v4.5 まで明暗をテーマ自身が決めていたが、
# 新しいテーマ基盤では color_scheme（auto/light/dark）がユーザー設定として独立した。
# upstream の MigrateUserTheme は独自テーマ名を対象外にするため、
# 独自テーマのユーザーには旧テーマの明暗を color_scheme に書き込み、
# OS のダークモード設定で突然見た目が変わらないようにする。
class SetColorSchemeForImastodonThemes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Dummy class, to make migration possible across version changes
  class User < ApplicationRecord; end

  LIGHT_THEMES = %w(idolmaster millionlive shinycolors gakumas).freeze
  DARK_THEMES = %w(765pro-allstars cinderella sidem va-liv).freeze
  KNOWN_THEMES = (%w(default) + LIGHT_THEMES + DARK_THEMES).freeze

  def up
    User.where.not(settings: nil).find_each do |user|
      settings = JSON.parse(user.attributes_before_type_cast['settings'])
      next if settings.nil? || settings['theme'].blank?

      theme = settings['theme']

      if KNOWN_THEMES.exclude?(theme)
        settings['theme'] = 'default'
      elsif settings['web.color_scheme'].blank?
        if LIGHT_THEMES.include?(theme)
          settings['web.color_scheme'] = 'light'
        elsif DARK_THEMES.include?(theme)
          settings['web.color_scheme'] = 'dark'
        else
          next
        end
      else
        next
      end

      user.update_column('settings', JSON.generate(settings))
    end
  end

  def down; end
end
