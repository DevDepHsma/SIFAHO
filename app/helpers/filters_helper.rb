module FiltersHelper
  def get_value_from_filter(param)
    params[:filter].present? && params[:filter][param].present? ? params[:filter][param] : ''
  end

  def highlight(text, phrases, *args)
    options = args.extract_options!
    options[:highlighter] = args[0] || '<mark class="highlight">\1</mark>' unless args.empty?
    options.reverse_merge!(highlighter: '<mark class="highlight">\1</mark>')

    if text.blank? || phrases.blank?
      text
    else
      haystack = text.clone
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      if options[:ignore_special_chars]
        haystack = haystack.mb_chars.normalize(:kd)
        match = match.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]+/n, '').gsub(/\w/, '\0[^\x00-\x7F]*')
      end
      highlighted = haystack.gsub(/(#{match})(?!(?:[^<]*?)(?:["'])[^<>]*>)/i, options[:highlighter])
      highlighted = highlighted.mb_chars.normalize(:kc) if options[:ignore_special_chars]
      highlighted
    end.html_safe
  end

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
end
