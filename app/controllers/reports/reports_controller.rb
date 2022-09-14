class ReportsController < ApplicationController
  before_action :set_report, only: [:show]

  def index
    unless policy(:report).index?
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    policy(:report).new?
    @report = Report.new
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id }).limit(20)
    @patients = [] #Patient.filter_by_sector_dispensation({ sector_id: @current_user.sector_id }).limit(20)
    @product_ids = []
  end

  def create
    policy(:report).create?
    @report = Report.create(sector: @current_user.sector,
                            sector_name: @current_user.sector.name,
                            establishment_name: @current_user.sector.establishment.name,
                            generated_date: Time.now,
                            generated_by_user_id: @current_user.id,
                            report_type: report_params(:report_type))
  end

  # get all products with stock x >= 0 of current sector
  # params[:product_ids]    string with selected products
  # params[:product_term]   string for search by name or code (Product)
  def get_stock_products
    @product_ids = params[:product_ids]
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:product_term],
                                          product_ids: params[:product_ids].split('_') })
                       .limit(20)
  end

  # Set selected product and reset avaible products list
  # params[:product_ids]    string with selected products
  # params[:product_term]   string for search by name or code (Product)
  # get all products with stock x >= 0 of current sector
  def select_product
    @product = Product.find(params[:product_id])
    @product_ids = params[:product_ids].present? ? params[:product_ids].split('_') : []
    @product_ids << @product.id
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:product_term],
                                          product_ids: @product_ids })
                       .limit(20)
    @product_ids = @product_ids.join('_')
  end

  # Unset selected products and reset avaible products list
  # params[:product_ids]    string with selected products
  # params[:product_id]     product id to remove from selected products
  # params[:product_term]   keep product term search
  # get all products with stock x >= 0 of current sector
  def unselect_product
    @product_id = params[:product_id]
    @product_ids = params[:product_ids].present? ? params[:product_ids].split('_') : []
    @product_ids.delete(@product_id)
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:product_term],
                                          product_ids: @product_ids })
                       .limit(20)
    @product_ids = @product_ids.join('_')
  end

  def get_patients_by_sector

  end

  ###################################  DEPRECATED  ########################################

  def show
    authorize @report

    if @report.delivered_by_order?
      @pres_consumption = current_user.sector.sum_delivered_prescription_quantities_to(@report.supply_id,
                                                                                       @report.since_date, @report.to_date)
      @int_ord_consumption = current_user.sector.sum_delivered_internal_quantities_to(@report.supply_id,
                                                                                      @report.since_date, @report.to_date)
      @ord_sup_consumption = current_user.sector.sum_delivered_external_order_quantities_to(@report.supply_id,
                                                                                            @report.since_date, @report.to_date)
      @total_sum = @pres_consumption + @int_ord_consumption + @ord_sup_consumption
    elsif @report.delivered_by_establishment?
      @quantities = current_user.sector.delivered_external_order_quantities_by_establishment_to(@report.supply_id)
    end
  end

  # GET /reports/new_delivered_by_order
  def new_delivered_by_order
    authorize Report
    @report = Report.new
    @report.report_type = 0
  end

  # GET /reports/new_delivered_by_establishment
  def new_delivered_by_establishment
    authorize Report
    @report = Report.new
    @report.report_type = 1
  end

  # POST /reports/create_delivered_by_order
  def create_delivered_by_order
    @report = Report.new(report_params)
    authorize @report

    @report.sector = current_user.sector
    @report.user = current_user
    @report.name = 'Reporte de insumo entregado por pedido'

    respond_to do |format|
      if @report.save
        flash.now[:success] = @report.name + ' se ha creado correctamente.'
        format.html { redirect_to @report }
      else
        flash.now[:error] = 'El reporte no se ha podido crear.'
        format.html { render :new_delivered_by_order }
      end
    end
  end

  # POST /reports/create_delivered_by_establisment
  def create_delivered_by_establishment
    @report = Report.new(report_params)
    authorize @report

    @report.sector = current_user.sector
    @report.user = current_user
    @report.report_type = 1
    @report.name = 'Reporte de insumo entregado por establecimiento.'

    respond_to do |format|
      if @report.save
        flash.now[:success] = @report.name + ' se ha creado correctamente.'
        format.html { redirect_to @report }
      else
        flash.now[:error] = 'El reporte no se ha podido crear.'
        format.html { render :new_delivered_by_establishment }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report
    @report = Report.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def report_params
    params.require(:report).permit(:id, :report_type)
  end
end
