FactoryBot.define do
  factory :reservation do
    user_email { "reservation@example.com" }
    book { nil }
  end
end
