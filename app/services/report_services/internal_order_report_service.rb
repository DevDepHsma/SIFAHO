module ReportServices
  class InternalOrderReportService
    def initialize(a_user, an_internal_order)
      @user = a_user
      @internal_order = an_internal_order
    end

    def generate_pdf
      report = Thinreports::Report.new

      report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'other_page.tlf'), default: true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page.tlf'), id: :cover_page

      # Comenzamos con la pagina principal
      report.start_new_page layout: :cover_page

      # Agregamos el encabezado
      report.page[:title] = "Reporte de #{@internal_order.order_type.humanize.underscore}"
      report.page[:remit_code] = @internal_order.remit_code
      report.page[:requested_date] = @internal_order.requested_date.strftime('%d/%m/%YY')
      report.page[:applicant_sector] = @internal_order.applicant_sector.name
      report.page[:provider_sector] = @internal_order.provider_sector.name
      report.page[:observations] = @internal_order.observation
      report.page[:total_products] =
        "#{@internal_order.order_products.count} #{'producto'.pluralize(@internal_order.order_products.size)}"
      report.page[:username].value("DNI: #{@user.dni}, #{@user.full_name}")

      # Se van agregando los productos
      @internal_order.order_products.joins(:product).order('name').each do |eop|
        # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)

        report.start_new_page if report.page_count == 1 && report.list.overflow?

        report.list do |list|
          if eop.order_prod_lot_stocks.present?
            eop.order_prod_lot_stocks.each_with_index do |opls, index|
              if index == 0
                list.add_row do |row|
                  row.values  lot_code: opls.lot_stock.lot.code,
                              expiry_date: opls.lot_stock.lot.expiry_date.present? ? opls.lot_stock.lot.expiry_date.strftime('%m/%y') : '----',
                              lot_q: "#{opls.quantity} #{eop.product.unity.name.pluralize(opls.quantity)}"
                  row.values  product_code: eop.product.code,
                              product_name: eop.product.name,
                              requested_quantity: "#{eop.request_quantity} #{eop.product.unity.name.pluralize(eop.request_quantity)}",
                              obs_req: eop.applicant_observation,
                              obs_del: eop.provider_observation

                  row.item(:border).show if eop.order_prod_lot_stocks.count == 1
                end
              else
                list.add_row do |row|
                  row.values lot_code: opls.lot_stock.lot.code,
                             expiry_date: opls.lot_stock.lot.expiry_date.present? ? opls.lot_stock.lot.expiry_date.strftime('%m/%y') : '----',
                             lot_q: "#{opls.quantity} #{eop.product.unity.name.pluralize(opls.quantity)}"

                  row.item(:border).show if eop.order_prod_lot_stocks.last == opls
                end
              end
            end
          else
            list.add_row do |row|
              row.values product_code: eop.product.code,
                         product_name: eop.product.name,
                         requested_quantity: "#{eop.request_quantity} #{eop.product.unity.name.pluralize(eop.request_quantity)}",
                         obs_req: eop.applicant_observation,
                         obs_del: eop.provider_observation
              row.item(:border).show
            end
          end
        end # fin lista
      end # fin productos

      # A cada pagina le agregamos el pie de pagina
      report.pages.each do |page|
        page[:page_count] = report.page_count
        page[:sector] = @user.active_sector.name
        page[:establishment] = @user.active_sector.establishment.name
      end

      report.generate
    end
  end
end
