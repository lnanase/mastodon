# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController
  before_action :set_account
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, except: [:index]
  before_action :require_user!

  respond_to :json

  def index
    current_account = current_user.account
    orderd_favourite_tags = current_account.favourite_tags.with_order

    render json: orderd_favourite_tags.map(&:to_json_for_api)
  end

  def create
    current_account = current_user.account
    favourite_tag = current_account.favourite_tags.find_by(name: create_params[:name], visibility: create_params[:visibility])

    if favourite_tag.present?
      render json: favourite_tag.to_json_for_api, status: 409
      return
    end

    favourite_tag = FavouriteTag.new(account: current_account, name: create_params[:name], visibility: create_params[:visibility])
    favourite_tag.save!
    render json: favourite_tag.to_json_for_api
  end

  def destroy
    tag = find_tag
    @favourite_tag = find_fav_tag_by(tag)
    if @favourite_tag.nil?
      render json: { succeeded: false }, status: 404
    else
      @favourite_tag.destroy
      render json: { succeeded: true }
    end
  end

  private

  def create_params
    params.permit(:name, :visibility)
  end

  def set_account
    @account = current_user.account
  end

  def find_or_init_tag
    Tag.find_or_initialize_by(name: tag_params[:tag])
  end

  def find_tag
    Tag.find_by(name: tag_params[:tag])
  end

  def find_fav_tag_by(tag)
    @account.favourite_tags.find_by(tag: tag)
  end

  def favourite_tag_visibility
    tag_params[:visibility].nil? ? 'public' : tag_params[:visibility]
  end

  def current_favourite_tags
    current_account.favourite_tags.with_order.includes(:tag).map(&:to_json_for_api)
  end
end
