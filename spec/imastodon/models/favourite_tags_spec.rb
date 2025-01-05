# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavouriteTag, type: :model do
  describe 'validation' do
    let(:account) { Fabricate :account }
    let(:tag) { Fabricate(:tag, name: 'valid_tag') }

    describe 'visibility' do
      it '値が0(public)から3(direct)ならvalid' do
        expect(described_class.new(account: account, tag: tag, visibility: 0)).to be_valid
        expect(described_class.new(account: account, tag: tag, visibility: 1)).to be_valid
        expect(described_class.new(account: account, tag: tag, visibility: 2)).to be_valid
        expect(described_class.new(account: account, tag: tag, visibility: 3)).to be_valid
      end

      it '値が4(enum上で未定義)ならArgumentErrorをraise' do
        expect { described_class.new(account: account, tag: tag, visibility: 4) }.to raise_error(ArgumentError)
      end
    end

    describe 'tag' do
      it 'お気に入りタグを作成しようとしたとき、そのタグの名前が不正ならinvalid' do
        expect(described_class.new(account: account, tag: Tag.new(name: 'test tag'), visibility: 0)).to_not be_valid
      end
    end
  end

  describe 'deletion' do
    let!(:favourite_tag) { Fabricate(:favourite_tag) }

    it 'delete favourite_tag' do
      expect { favourite_tag.destroy }.to change(described_class, :count).by(-1)
      expect { favourite_tag.destroy }.to_not change(described_class, :count)
    end
  end

  describe 'scopes' do
    describe 'with_order' do
      let(:account) { Fabricate(:account, username: 'favourite') }

      it 'returns an array of recent favourite tags ordered by order and id' do
        specifieds = [
          Fabricate(:favourite_tag, account: account, order: 9900),
          Fabricate(:favourite_tag, account: account, order: 9800),
          Fabricate(:favourite_tag, account: account, order: 9800),
        ]
        expect(account.favourite_tags.with_order.limit(3)).to match_array(specifieds)
      end
    end
  end

  describe 'expect to_json_for_api' do
    let(:account) { Fabricate :account }
    let(:tag) { Tag.new(name: 'test_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: account, tag: tag) }

    it 'expect to_json_for_api' do
      json = favourite_tag.to_json_for_api
      expect(json[:id]).to eq favourite_tag.id
      expect(json[:name]).to eq 'test_tag'
      expect(json[:visibility]).to eq 'public'
    end
  end
end
