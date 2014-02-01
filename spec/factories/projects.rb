FactoryGirl.define do
  factory :project do
    sequence(:title) {|n| "Title #{n}"}
    description "Warp fields stabilized."
    status "We feel your presence."
  end
end