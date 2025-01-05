# frozen_string_literal: true

class Settings::FavouriteTagsController < Settings::BaseController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_favourite_tags, only: [:index, :create]
  before_action :set_favourite_tag, only: [:edit, :update, :destroy]

  def index
    @favourite_tag = FavouriteTag.new(visibility: FavouriteTag.visibilities[:public])
  end

  def edit
    @favourite_tag
  end

  def create
    name = create_params[:name].delete_prefix('#')
    @favourite_tag = FavouriteTag.new(account: @account, name: name, order: create_params[:order], visibility: create_params[:visibility])
    if @favourite_tag.save
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :index
    end
  end

  def update
    name = update_params[:name].delete_prefix('#')
    if @favourite_tag.update(name: name, order: update_params[:order], visibility: update_params[:visibility])
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :edit
    end
  end

  def destroy
    @favourite_tag.destroy
    redirect_to settings_favourite_tags_path
  end

  private

  def create_params
    params.require(:favourite_tag).permit(:name, :visibility, :order)
  end

  def update_params
    params.require(:favourite_tag).permit(:name, :visibility, :order)
  end

  def set_account
    @account = current_user.account
  end

  def set_favourite_tag
    @favourite_tag = @account.favourite_tags.find(params[:id])
  end

  def set_favourite_tags
    @favourite_tags = @account.favourite_tags.with_order
  end
end
