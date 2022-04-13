FactoryBot.define do
  factory :lot do
    expiry_date { Date.new(2022, 11, 12) }
    code { 'AAA-11' }
    product
    laboratory

    trait :ibuprofeno do
      association :product, factory: :unidad_product
    end

    trait :abbott do
      association :laboratory, factory: :abbott_laboratory
    end

    trait :abbvie do
      association :laboratory, factory: :abbvie_laboratory
    end

    trait :province do
      association :provenance, factory: :province_lot_provenance
    end

    factory :province_lot, traits: %i[ibuprofeno abbott province]
    factory :province_lot_without_product, traits: %i[abbott province]
    factory :province_lot_without_product_1, traits: %i[abbvie province]
  end
end
