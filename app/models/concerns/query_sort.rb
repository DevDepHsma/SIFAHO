module QuerySort
  extend ActiveSupport::Concern

  included do
    scope  :sorted_by, lambda { |sort_params|
      pairs = sort_params.split(/[:;]/).map(&:strip).each_slice(2).map { |k, v| [k.strip.to_sym, v.strip] }
      Hash[pairs]
      reorder(Hash[pairs])
    }
  end
end
