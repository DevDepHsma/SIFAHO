class ReportsController < ApplicationController
  before_action :set_report, only: %i[show destroy]

  def initialize
    super
    @result_size = 11
  end

  def index
    unless policy(:report).index?
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
    @reports = Report.filter_by_params(params[:filter]).paginate(page: params[:page], per_page: params[:per_page] || 15)
  end

  def new
    policy(:report).new?
    @report = Report.new
    @products = Product.filter_by_stock({ sector_id: @current_user.active_sector.id }).limit(@result_size)
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.active_sector.id }).limit(@result_size)
    @sectors = Sector.filter_by_internal_order({ sector_id: @current_user.active_sector.id }).limit(@result_size)
  end

  def create
    policy(:report).create?
    respond_to do |format|
      @report = Report.new.generate!(@current_user, report_params)
      format.html { redirect_to @report, notice: 'El reporte se ha creado correctamente.' }
    rescue ActiveRecord::RecordInvalid => e
      @report = e.record
      @selected_products = Product.select(:id, :code, :name).where(id: report_params[:products_ids].split('_'))
      @products = Product.filter_by_stock({ sector_id: @current_user.active_sector.id, product: params[:term],
                                            products_ids: report_params[:products_ids].split('_') }).limit(@result_size)
      @selected_patients = Patient.select(:id, :dni, :last_name,
                                          :first_name).where(id: report_params[:patients_ids].split('_'))
      @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.active_sector.id, patient: params[:term],
                                                          patients_ids: report_params[:patients_ids].split('_') })
                         .limit(@result_size)
      @selected_sectors = Sector.select(:id, :name).where({ id: report_params[:sectors_ids].split('_') })
      @sectors = Sector.filter_by_internal_order({ sector_id: @current_user.active_sector.id,
                                                   sector: params[:term], sectors_ids: report_params[:sectors_ids].split('_') })
                       .limit(@result_size)
      @errors = e.record.errors
      format.html { render :new }
    end
  end

  # get all products with stock x >= 0 of current sector
  # params[:products_ids]   string with selected products
  # params[:product_term]   string for search by name or code (Product)
  def get_stock_products
    @products = Product.filter_by_stock({ sector_id: @current_user.active_sector.id, product: params[:term],
                                          products_ids: params[:products_ids].split('_') })
                       .limit(@result_size)
  end

  # Set selected product and reset avaible products list
  # params[:products_ids]   string with selected products
  # params[:product_term]   string for search by name or code (Product)
  # get all products with stock x >= 0 of current sector
  def select_product
    @product = Product.find(params[:product_id])
    @products_ids = params[:products_ids].present? ? params[:products_ids].split('_') : []
    @products_ids << @product.id
    @products = Product.filter_by_stock({ sector_id: @current_user.active_sector.id, product: params[:term],
                                          products_ids: @products_ids })
                       .limit(@result_size)
    @products_ids = @products_ids.join('_')
  end

  # Unset selected products and reset avaible products list
  # params[:products_ids]   string with selected products
  # params[:product_id]     product id to remove from selected products
  # params[:product_term]   keep product term search
  # get all products with stock x >= 0 of current sector
  def unselect_product
    @product_id = params[:product_id]
    @products_ids = params[:products_ids].present? ? params[:products_ids].split('_') : []
    @products_ids.delete(@product_id)
    @products = Product.filter_by_stock({ sector_id: @current_user.active_sector.id, product: params[:term],
                                          products_ids: @products_ids })
                       .limit(@result_size)
    @products_ids = @products_ids.join('_')
  end

  def get_patients_by_sector
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.active_sector.id,
                                                        patient: params[:term],
                                                        patients_ids: params[:patients_ids].split('_') }).limit(@result_size)
  end

  def get_sectors
    @sectors = Sector.filter_by_internal_order({ sector_id: @current_user.active_sector.id, sector: params[:term],
                                                 sectors_ids: params[:sectors_ids].split('_') }).limit(@result_size)
                                          
  end

  # Set selected patient and reset avaible patients list
  # params[:patients_ids]   string with selected patients
  # params[:patient_term]   string for search by name or code (Patient)
  # get all patients with stock x >= 0 of current sector
  def select_patient
    @patient = Patient.find(params[:patient_id])
    @patients_ids = params[:patients_ids].present? ? params[:patients_ids].split('_') : []
    @patients_ids << @patient.id
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.active_sector.id, patient: params[:term],
                                                        patients_ids: @patients_ids })
                       .limit(@result_size)
    @patients_ids = @patients_ids.join('_')
  end

  # Unset selected patients and reset avaible patients list
  # params[:patients_ids]   string with selected patients
  # params[:patient_id]     patient id to remove from selected patients
  # params[:patient_term]   keep patient term search
  # get all patients with stock x >= 0 of current sector
  def unselect_patient
    @patient_id = params[:patient_id]
    @patients_ids = params[:patients_ids].present? ? params[:patients_ids].split('_') : []
    @patients_ids.delete(@patient_id)
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.active_sector.id, patient: params[:term],
                                                        patients_ids: @patients_ids })
                       .limit(@result_size)
    @patients_ids = @patients_ids.join('_')
  end

  def select_sector
    @sector = Sector.find(params[:sector_id])
    @sectors_ids = params[:sectors_ids].present? ? params[:sectors_ids].split('_') : []
    @sectors_ids << @sector.id
    @sectors = Sector.filter_by_internal_order({ sector_id: @current_user.active_sector.id, sector: params[:term],
                                                 sectors_ids: @sectors_ids }).limit(@result_size)
    @sectors_ids = @sectors_ids.join('_')
  end

  def unselect_sector
    @sector_id = params[:sector_id]
    @sectors_ids = params[:sectors_ids].present? ? params[:sectors_ids].split('_') : []
    @sectors_ids.delete(@sector_id)
    @sectors = Sector.filter_by_internal_order({ sector_id: @current_user.active_sector.id, sector: params[:term],
                                                 sectors_ids: @sectors_ids }).limit(@result_size)
    @sectors_ids = @sectors_ids.join('_')
  end

  def show
    authorize @report
    report_name = @report.name.present? ? @report.name.downcase.gsub(' ', '_') : 'reporte_por_paciente'
    respond_to do |format|
      format.html
      format.xlsx do
        headers['Content-Disposition'] =
          "attachment; filename=\"#{report_name}_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\""
      end
    end
  end

  # DELETE /establishments/1
  # DELETE /establishments/1.json
  def destroy
    authorize @report
    flash.now[:success] = "El reporte #{@report.name} se ha eliminado correctamente."
    @report.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report
    @report = Report.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def report_params
    params.require(:report).permit(:name,
                                   :report_type,
                                   :products_ids,
                                   :patients_ids,
                                   :sectors_ids,
                                   :from_date,
                                   :to_date)
  end
end
