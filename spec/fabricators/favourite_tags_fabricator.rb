# frozen_string_literal: true

Fabricator(:favourite_tag) do
  account
  tag
  visibility 0
  order 0
end
