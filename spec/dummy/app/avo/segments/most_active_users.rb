class MostActiveUsers < Avo::BaseSegment
  puts 'in MostActiveUsers'.inspect
  self.query = -> (query:, params:) do
    query.select(self.columns).includes(:posts, :post).where(last_name: 'eee')

  end

  self.columns = [
    'users.id',
    'users.email',
    # 'users.kaka',
  ]

  # field :id, as: :id, link_to_resource: true
  # field :email, as: :gravatar, link_to_resource: true, as_avatar: :circle
end
