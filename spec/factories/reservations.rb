FactoryBot.define do
  factory :reservation do
    user_email { "user@example.com" }
    association :book
  end
end
