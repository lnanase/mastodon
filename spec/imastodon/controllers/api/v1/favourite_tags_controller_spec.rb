# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FavouriteTagsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:tag) { Fabricate(:tag, name: tag_name) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:statuses' }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to match(
        [
          { id: be_integer, name: 'デレラジ', visibility: 'unlisted' },
          { id: be_integer, name: 'デレパ', visibility: 'unlisted' },
          { id: be_integer, name: 'imas_mor', visibility: 'unlisted' },
          { id: be_integer, name: 'millionradio', visibility: 'unlisted' },
          { id: be_integer, name: 'sidem', visibility: 'unlisted' },
        ]
      )
    end
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    let!(:scopes) { 'write:statuses' }

    context '新しいタグをお気に入りタグに登録するとき' do
      context '公開範囲をpublicで登録するとき' do
        let!(:params) do
          {
            name: 'お気に入りタグ',
            visibility: 'public',
          }
        end

        it '新しいお気に入りタグのレコードが記録され、ステータスコード200と、作成されたお気に入りタグがレスポンスボディとして返る' do
          expect { subject }.to change { user.account.favourite_tags.count }.by(1)

          created = FavouriteTag.last
          expect(created.name).to eq('お気に入りタグ')
          expect(created.visibility).to eq('public')

          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body).to match({
            id: created.id,
            name: 'お気に入りタグ',
            visibility: 'public',
          })
        end
      end

      context '公開範囲をunlistedで登録するとき' do
        let!(:params) do
          {
            name: 'お気に入りタグ',
            visibility: 'unlisted',
          }
        end

        it '新しいお気に入りタグのレコードが記録され、ステータスコード200と、作成されたお気に入りタグがレスポンスボディとして返る' do
          expect { subject }.to change { user.account.favourite_tags.count }.by(1)

          created = FavouriteTag.last
          expect(created.name).to eq('お気に入りタグ')
          expect(created.visibility).to eq('unlisted')

          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body).to match({
            id: created.id,
            name: 'お気に入りタグ',
            visibility: 'unlisted',
          })
        end
      end
    end

    context '登録しようとしたタグが既にお気に入りタグに登録されているとき' do
      let!(:already_exists) { Fabricate(:favourite_tag, account: user.account, name: '登録済みのお気に入りタグ', visibility: 'public') }

      context '公開範囲も同じとき' do
        let!(:params) do
          {
            name: '登録済みのお気に入りタグ',
            visibility: 'public',
          }
        end

        it '新しいお気に入りタグのレコードは増えず、ステータスコード409と、既存のお気に入りタグがレスポンスボディとして返る' do
          expect { subject }.to_not(change { user.account.favourite_tags.count })

          expect(response).to have_http_status(409)
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body).to match({
            id: already_exists.id,
            name: '登録済みのお気に入りタグ',
            visibility: 'public',
          })
        end
      end

      context '公開範囲が異なるとき' do
        let!(:params) do
          {
            name: '登録済みのお気に入りタグ',
            visibility: 'unlisted',
          }
        end

        it '新しいお気に入りタグのレコードが記録され、ステータスコード200と、作成されたお気に入りタグがレスポンスボディとして返る' do
          expect { subject }.to change { user.account.favourite_tags.count }.by(1)

          created = FavouriteTag.last
          expect(created.name).to eq('登録済みのお気に入りタグ')
          expect(created.visibility).to eq('unlisted')

          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body).to match({
            id: created.id,
            name: '登録済みのお気に入りタグ',
            visibility: 'unlisted',
          })
        end
      end
    end

    context '英字のタグを大文字小文字違いで登録しようとしたとき' do
      let!(:already_exists) { Fabricate(:favourite_tag, account: user.account, name: 'already_favourited_tag', visibility: 'public') }

      let!(:params) do
        {
          name: 'Already_favourited_tag',
          visibility: 'public',
        }
      end

      it '新しいお気に入りタグのレコードが記録され、ステータスコード200と、作成されたお気に入りタグがレスポンスボディとして返る' do
        expect { subject }.to change { user.account.favourite_tags.count }.by(1)

        created = FavouriteTag.last
        expect(created.name).to eq('Already_favourited_tag')
        expect(created.visibility).to eq('public')

        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body).to match({
          id: created.id,
          name: 'Already_favourited_tag',
          visibility: 'public',
        })
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: params }

    let(:scopes) { 'write:statuses' }
    let(:params) { { tag: tag_name } }

    context 'when try to destroy the favourite tag' do
      let(:tag_name) { 'dummy_tag' }

      before do
        Fabricate(:favourite_tag, account: user.account, tag: tag)
      end

      it 'returns http success' do
        expect { subject }.to change { user.account.favourite_tags.count }.by(-1)
        expect(response).to have_http_status(:success)
      end

      it 'responce has success message by json' do
        expect { subject }.to change { user.account.favourite_tags.count }.by(-1)
        expect(
          JSON.parse(response.body, symbolize_names: true)
        ).to eq({ succeeded: true })
      end
    end

    context 'when try to destroy an unregistered tag' do
      let(:tag_name) { 'unregistered' }

      it 'returns http 404' do
        expect { subject }.to_not(change { user.account.favourite_tags.count })
        expect(response).to have_http_status(404)
      end

      it 'responce has fail message by json' do
        expect { subject }.to_not(change { user.account.favourite_tags.count })
        expect(
          JSON.parse(response.body, symbolize_names: true)
        ).to eq({ succeeded: false })
      end
    end
  end
end
