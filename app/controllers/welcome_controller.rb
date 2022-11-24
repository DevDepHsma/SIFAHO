class WelcomeController < ApplicationController

  def index
    respond_to do |format|
      if policy(:welcome).index?
        _helper = ActiveSupport::NumberHelper

        # Ultimos 13 días más el día actual
        @outpatient_prescriptions_query_by_days = OutpatientPrescription.with_establishment(@current_user.active_sector.establishment).group_by_day(:date_prescribed, range: 13.days.ago..DateTime.now).count
        @outpatient_prescriptions_by_days = @outpatient_prescriptions_query_by_days.values
        @chronic_prescriptions_query_by_days = ChronicPrescription.with_establishment(@current_user.active_sector.establishment).group_by_day(:date_prescribed, range: 13.days.ago..DateTime.now, format: "%h %d").count
        @chronic_prescriptions_by_days = @chronic_prescriptions_query_by_days.values
        @chronic_prescriptions_days = @chronic_prescriptions_query_by_days.keys

        # Ultimos 11 meses más el mes actual
        @outpatient_prescriptions_query = OutpatientPrescription.with_establishment(@current_user.active_sector.establishment).group_by_month(:date_prescribed, range: 11.months.ago..DateTime.now).count
        @outpatient_prescriptions = @outpatient_prescriptions_query.values
        @chronic_prescriptions_query = ChronicPrescription.with_establishment(@current_user.active_sector.establishment).group_by_month(:date_prescribed, range: 11.months.ago..DateTime.now, format: "%h %Y").count
        @chronic_prescriptions = @chronic_prescriptions_query.values
        @chronic_prescriptions_months = @chronic_prescriptions_query.keys

        @last_outpatient_prescriptions = OutpatientPrescription.with_establishment(@current_user.active_sector.establishment).order(created_at: :desc).limit(5)
        @last_chronic_prescriptions = ChronicPrescription.with_establishment(@current_user.active_sector.establishment).order(created_at: :desc).limit(5)

        @lot_stocks = LotStock.joins("INNER JOIN stocks ON lot_stocks.stock_id = stocks.id").where("stocks.sector_id = #{@current_user.active_sector.id} AND lot_stocks.quantity > 0")
        @expired_lot_stocks = @lot_stocks.joins("INNER JOIN lots ON lot_stocks.lot_id = lots.id").with_status(2).order('lots.expiry_date desc').limit(9)
        @near_expiry_lots = @lot_stocks.joins("INNER JOIN lots ON lot_stocks.lot_id = lots.id").with_status(1).order('lots.expiry_date desc').limit(9)

        @expired_lot_stocks_all = @lot_stocks.with_status(2)
        @near_expiry_lots_all = @lot_stocks.with_status(1)

        @count_total_lots = @lot_stocks.count
        @count_expired_lots = @expired_lot_stocks_all.count
        @count_near_expiry_lots = @near_expiry_lots_all.count
        @count_good_lots = @lot_stocks.with_status(0).count

        # Tomamos los estados de los lotes
        @lots = LotStock.joins(:stock).joins(:sector).joins(:lot).where("sectors.id = ?", @current_user.active_sector).where.not("lots.status = ?", 4).group("lots.status").count
        status_colors = {0 => "#40c95e", 1 => "#f1ae45", 2 => "#d36262" }
        # formateamos los colores segun el tipo de estado
        @colors = []
        @lots.each do |status, _|
          @colors << status_colors[status]
        end

        @percent_good_supply_lots = _helper.number_to_percentage((@count_good_lots.to_f * 100 / @count_total_lots) || 0, precision: 2, format: '%n')
        @percent_near_expiry_lots = _helper.number_to_percentage((@count_near_expiry_lots.to_f * 100 / @count_total_lots) || 0, precision: 2, format: '%n')
        @percent_expired_lots = _helper.number_to_percentage((@count_expired_lots.to_f * 100 / @count_total_lots) || 0, precision: 2, format: '%n')

        @external_orders_origin = ExternalOrder.my_orders(@current_user.active_sector)
        @external_orders_destination = ExternalOrder.other_orders(@current_user.active_sector)

        format.html
      elsif @current_user.active? && @current_user.active_sector.nil?
        format.html { render :none_sector }
      elsif policy(:permission_request).new?
        format.html { redirect_to new_permission_request_path }
      else
        format.html { redirect_to request_in_progress_permission_requests_path }
      end
    end
  end
end
