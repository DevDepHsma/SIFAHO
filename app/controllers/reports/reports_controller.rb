class ReportsController < ApplicationController
  before_action :set_report, only: [:show]

  def initialize
    super
    @result_size = 11
  end

  def index
    unless policy(:report).index?
      flash[:error] = 'Usted no está autorizado para realizar esta acción.'
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    policy(:report).new?
    @report = Report.new
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id }).limit(@result_size)
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.sector_id }).limit(@result_size)
    @product_ids = []
    @patients_ids = []
  end

  def create
    policy(:report).create?
    @report = Report.create(sector: @current_user.sector,
                            sector_name: @current_user.sector.name,
                            establishment_name: @current_user.sector.establishment.name,
                            generated_date: Time.now,
                            generated_by_user_id: @current_user.id,
                            report_type: report_params[:report_type].to_i)

    @report.build_report_values(report_params)
    respond_to do |format|
      format.html { redirect_to @report }
    end
  end

  # get all products with stock x >= 0 of current sector
  # params[:product_ids]    string with selected products
  # params[:product_term]   string for search by name or code (Product)
  def get_stock_products
    @product_ids = params[:product_ids]
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:term],
                                          product_ids: params[:product_ids].split('_') })
                       .limit(@result_size)
  end

  # Set selected product and reset avaible products list
  # params[:product_ids]    string with selected products
  # params[:product_term]   string for search by name or code (Product)
  # get all products with stock x >= 0 of current sector
  def select_product
    @product = Product.find(params[:product_id])
    @product_ids = params[:product_ids].present? ? params[:product_ids].split('_') : []
    @product_ids << @product.id
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:term],
                                          product_ids: @product_ids })
                       .limit(@result_size)
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
    @products = Product.filter_by_stock({ sector_id: @current_user.sector_id, product: params[:term],
                                          product_ids: @product_ids })
                       .limit(@result_size)
    @product_ids = @product_ids.join('_')
  end

  def get_patients_by_sector
    @patient_ids = params[:patient_ids]
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.sector_id,
                                                        patient: params[:term],
                                                        patient_ids: params[:patient_ids].split('_') }).limit(@result_size)
  end

  # Set selected patient and reset avaible patients list
  # params[:patient_ids]    string with selected patients
  # params[:patient_term]   string for search by name or code (Patient)
  # get all patients with stock x >= 0 of current sector
  def select_patient
    @patient = Patient.find(params[:patient_id])
    @patient_ids = params[:patient_ids].present? ? params[:patient_ids].split('_') : []
    @patient_ids << @patient.id
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.sector_id, patient: params[:term],
                                                        patient_ids: @patient_ids })
                       .limit(@result_size)
    @patient_ids = @patient_ids.join('_')
  end

  # Unset selected patients and reset avaible patients list
  # params[:patient_ids]    string with selected patients
  # params[:patient_id]     patient id to remove from selected patients
  # params[:patient_term]   keep patient term search
  # get all patients with stock x >= 0 of current sector
  def unselect_patient
    @patient_id = params[:patient_id]
    @patient_ids = params[:patient_ids].present? ? params[:patient_ids].split('_') : []
    @patient_ids.delete(@patient_id)
    @patients = Patient.filter_by_sector_dispensation({ sector_id: @current_user.sector_id, patient: params[:term],
                                                        patient_ids: @patient_ids })
                       .limit(@result_size)
    @patient_ids = @patient_ids.join('_')
  end

  ###################################  DEPRECATED  ########################################

  def show
    authorize @report
    report_name = @report.name.present? ? @report.name.downcase.joins('_') : 'reporte_por_paciente'
    respond_to do |format|
      format.html
      format.xlsx do
        headers['Content-Disposition'] =
          "attachment; filename=\"#{report_name}_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\""
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
    params.require(:report).permit(:report_type, :product_ids, :patient_ids, :all_products, :all_patients)
  end
end
