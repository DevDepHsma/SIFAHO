module FiltersHelper
  # Get filter value if it present
  def get_value_from_filter(param)
    params[:filter].present? && params[:filter][param].present? ? params[:filter][param] : ''
  end

  # Custom highlight for ignore special chars
  # :highliter => string as HTML tags
  # :ignore_special_chars => boolean
  def highlight(text, phrases, *args)
    options = args.extract_options!
    options[:highlighter] = args[0] || '<mark class="highlight">\1</mark>' unless args.empty?
    options.reverse_merge!(highlighter: '<mark class="highlight">\1</mark>')

    if text.blank? || phrases.blank?
      text || ''
    else
      haystack = text.clone
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      if options[:ignore_special_chars]
        haystack = haystack.gsub(/(°)|(º)/, '&deg;')
        haystack = haystack.mb_chars.normalize(:kd)
        match = match.gsub(/(°)|(º)/, '&deg;').mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]+/n, '').gsub(/\w/, '\0[^\x00-\x7F]*')
      end
      highlighted = haystack.gsub(/(#{match})(?!(?:[^<]*?)(?:["'])[^<>]*>)/i, options[:highlighter])
      highlighted
    end.html_safe
  end

  # get next sort option 'ASC' | 'DESC' | ''
  # accept empty option for remove sort
  def get_sort_value(target)
    if params[:filter].present? && params[:filter]['sort'].present? && target.present?
      pairs = params[:filter]['sort'].split(/[:;]/).map(&:strip).each_slice(2).map { |k, v| [k.strip.to_sym, v.strip] }
      match = pairs.detect { |n| n[0] == target.to_sym }

      if !match.nil? && match.any?('asc')
        'desc'
      elsif !match.nil? && match.any?('desc')
        ''
      else
        'asc'
      end
    else
      'asc'
    end
  end

  # Acepted attributes:
  # :name => Label string - important
  # :sort_field => Field sort: should be on the query select - important
  # :form => Filter form id - important
  # :class => Extra classes - optional
  # :icon_type => FontAwesome icon - optional: default "amount"
  def th_label(**args)
    if args[:name].present? && args[:sort_field].present? && args[:form].present?
      method = get_sort_value(args[:sort_field].to_s)
      "<th class='sort #{'active' unless %w[asc].include?(method)}'>
        <button class='custom-sort-v1 btn-list-sort #{args[:class]}'
                type='button'
                onclick='sort_by(\"#{args[:sort_field]}\", \"#{method}\", event.target);'
                data-form='#{args[:form]}'>
          #{args[:name]}
          #{sort_icon(method, args[:icon_type])}
        </button>
      </th>"
    elsif args[:name].present?
      "<th>
        #{args[:name]}
      </th>"
    end.html_safe
  end

  def sort_icon(method, type)
    type = type.nil? ? 'amount' : type
    case method
    when 'asc'
      ''
    when 'desc'
      fa_icon "sort-#{type}-down"
    else
      fa_icon "sort-#{type}-up"
    end.html_safe
  end

  def per_page_options
    [15, 30, 50, 100]
  end
end
