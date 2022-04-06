module Helpers
  module Order
    def select_sector(sector_name, select_id)
      expect(page.has_css?(select_id.to_s, visible: false)).to be true
      page.execute_script %Q{$('#{select_id.to_s}').siblings('button').first().click()}
      expect(page.has_css?('ul.dropdown-menu')).to be true
      expect(page.has_css?('span', text: sector_name.to_s)).to be true
      page.execute_script %Q{$('a>span.text:contains(#{sector_name})').first().click()}
    end
  end
end