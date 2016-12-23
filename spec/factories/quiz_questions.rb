FactoryGirl.define do
  factory :quiz_question do
    association :quiz
    markdown_content "**Quiz text**"
    question_type QuizQuestion::TYPE_MULTIPLE_CHOICE
  end
end
