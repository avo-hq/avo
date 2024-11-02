unless Rails.env.test?
  class Bad
    include ActiveModel::API
  end
end
