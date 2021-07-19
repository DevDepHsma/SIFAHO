class SnomedConcept < ApplicationRecord
  include PgSearch

  # Relationships
  has_many :products

  # Validations
  validates_uniqueness_of :concept_id

  filterrific(
    default_filter_params: { sorted_by: 'concepto_asc' },
    available_filters: [
      :search_concept_id,
      :search_term,
      :sorted_by
    ]
  )

  # Scopes
  pg_search_scope :search_concept_id,
                  against: :concept_id,
                  using: {
                    tsearch: { prefix: true },
                    trigram: {}
                  }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_term,
                  against: :term,
                  using: {
                    tsearch: { prefix: true },
                    trigram: {}
                  }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^codigo_/
      # Ordenamiento por id de insumo
      order("snomed_concepts.concept_id::integer #{direction}")
    when /^concepto_/
      # Ordenamiento por nombre de insumo
      order("LOWER(snomed_concepts.term) #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Código (menor primero)', 'codigo_asc'],
      ['Código (mayor primero)', 'codigo_desc'],
      ['Concepto (a-z)', 'concepto_asc'],
      ['Concepto (z-a)', 'concepto_desc']
    ]
  end
end
