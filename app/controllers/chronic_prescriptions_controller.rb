class ChronicPrescriptionsController < ApplicationController
  before_action :set_chronic_prescription, except: [:index, :new, :create ]

  # GET /chronic_prescriptions
  # GET /chronic_prescriptions.json
  def index
    authorize ChronicPrescription
    @filterrific = initialize_filterrific(
      ChronicPrescription.with_establishment(current_user.establishment),
      params[:filterrific],
      persistence_id: false
    ) or return
    @chronic_prescriptions = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /chronic_prescriptions/1
  # GET /chronic_prescriptions/1.json
  def show
    authorize @chronic_prescription

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_order_report(@chronic_prescription),
        filename: 'Rec_amb_'+@chronic_prescription.patient_last_name+'.pdf',
        type: 'application/pdf',
        disposition: 'inline'
      end
    end
  end

  # GET /chronic_prescriptions/new
  def new
    authorize ChronicPrescription
    @chronic_prescription = ChronicPrescription.new
    @chronic_prescription.original_chronic_prescription_products.build
  end

  # GET /chronic_prescriptions/1/edit
  def edit
    authorize @chronic_prescription
  end

  # POST /chronic_prescriptions
  # POST /chronic_prescriptions.json
  def create
    @chronic_prescription = ChronicPrescription.new(chronic_prescription_params)
    authorize @chronic_prescription
    @chronic_prescription.provider_sector = current_user.sector
    @chronic_prescription.establishment = current_user.sector.establishment
    @chronic_prescription.remit_code = current_user.sector.name[0..3].upcase+'pres'+ChronicPrescription.maximum(:id).to_i.next.to_s
    @chronic_prescription.status = 'pendiente'

    respond_to do |format|
        # Si se entrega la receta
      begin
        @chronic_prescription.save!
        message = "La receta crónica de "+@chronic_prescription.patient.fullname+" se ha creado correctamente."
        notification_type = "creó"
        
        @chronic_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @chronic_prescription, notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @chronic_prescription_products = @chronic_prescription.original_chronic_prescription_products.present? ? @chronic_prescription.original_chronic_prescription_products : @chronic_prescription.original_chronic_prescription_products.build
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /chronic_prescriptions/1
  # PATCH/PUT /chronic_prescriptions/1.json
  def update
    authorize @chronic_prescription

    respond_to do |format|
      begin
        @chronic_prescription.update!(chronic_prescription_params)

        message = "La receta crónica de "+@chronic_prescription.patient.fullname+" se ha auditado correctamente."
        notification_type = "auditó"

        @chronic_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @chronic_prescription, notice: message }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @chronic_prescription_products = @chronic_prescription.original_chronic_prescription_products.present? ? @chronic_prescription.original_chronic_prescription_products : @chronic_prescription.original_chronic_prescription_products.build        
        format.html { redirect_to edit_chronic_prescription_path(@chronic_prescription) }
      end
    end
  end

  # DELETE /chronic_prescriptions/1
  # DELETE /chronic_prescriptions/1.json
  def destroy
    authorize @chronic_prescription
    @professional_fullname = @chronic_prescription.professional.fullname
    @chronic_prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La receta de "+@professional_fullname+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /chronic_prescriptions/1/dispense
  def dispense_new
    authorize @chronic_prescription
    # @chronic_prescription.chronic_dispensations.build
  end

  def dispense
    authorize @chronic_prescription
    @chronic_prescription.status = 'dispensada_parcial'

    respond_to do |format|
      begin
        @chronic_prescription.update!(chronic_prescription_dispensation_params)
        @chronic_prescription.dispense_by(current_user)
        flash.now[:success] = "La receta de "+@chronic_prescription.professional.fullname+" se ha dispensado correctamente."
        format.html { redirect_to @chronic_prescription }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        # @chronic_dispensations = @chronic_prescription.chronic_dispensations.present? ? @chronic_prescription.chronic_dispensations : @chronic_prescription.chronic_dispensations.build        
        format.html { redirect_to dispense_new_chronic_prescription_path(@chronic_prescription) }
      end
    end
  end


  def return_dispensation
    authorize @chronic_prescription
    respond_to do |format|
      begin
        @chronic_prescription.return_dispensation(current_user)
      rescue ArgumentError => e
        flash[:error] = e.message
      else
        flash[:notice] = 'La receta se ha retornado a '+@chronic_prescription.status+'.'
      end
      format.html { redirect_to @chronic_prescription }
    end
  end

  # def get_by_patient_id
  #   @chronic_prescriptions = Prescription.with_patient_id(params[:term]).order(created_at: :desc).limit(10)
  #   render json: @chronic_prescriptions.map{ |pre| { id: pre.id, order_type: pre.order_type.humanize, status: pre.status.humanize, professional: pre.professional_fullname,
  #   supply_count: pre.quantity_ord_supply_lots.count, created_at: pre.created_at.strftime("%d/%m/%Y") } }
  # end

  # def generate_order_report(prescription)
  #   report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'prescription', 'first_page.tlf')

  #   report.use_layout File.join(Rails.root, 'app', 'reports', 'prescription', 'first_page.tlf'), :default => true
    
  #   if prescription.cronica?
  #     supply_relations = prescription.quantity_ord_supply_lots.sin_entregar.joins(:supply).order("name")
  #   else
  #     supply_relations = prescription.quantity_ord_supply_lots.joins(:supply).order("name")
  #   end
  
  #   supply_relations.each do |qosl|
  #     if report.page_count == 1 && report.list.overflow?
  #       report.start_new_page layout: :other_page do |page|
  #       end
  #     end
      
  #     report.list do |list|
  #       list.add_row do |row|
  #         row.values  supply_code: qosl.supply_id,
  #                     supply_name: qosl.supply.name,
  #                     requested_quantity: qosl.requested_quantity.to_s+" "+qosl.unity.pluralize(qosl.requested_quantity),
  #                     delivered_quantity: qosl.delivered_quantity.to_s+" "+qosl.unity.pluralize(qosl.delivered_quantity),
  #                     lot: qosl.sector_supply_lot_lot_code,
  #                     laboratory: qosl.sector_supply_lot_laboratory_name,
  #                     expiry_date: qosl.sector_supply_lot_expiry_date, 
  #                     applicant_obs: qosl.provider_observation
  #       end
  #     end
      
  #     if report.page_count == 1

  #       report.page[:order_type] = prescription.order_type
  #       report.page[:prescribed_date] = prescription.prescribed_date.strftime("%d/%m/%Y")
  #       report.page[:expiry_date] = prescription.expiry_date.present? ? prescription.expiry_date.strftime("%d/%m/%Y") : "---"
         
  #       report.page[:professional_name] = prescription.professional.fullname
  #       report.page[:professional_dni] = prescription.professional.dni
  #       report.page[:professional_enrollment] = prescription.professional.enrollment
  #       report.page[:professional_phone] = prescription.professional.phone

  #       report.page[:patien_name] = "#{prescription.patient.first_name} #{prescription.patient.last_name}"
  #       report.page[:patien_dni] = prescription.patient.dni

  #     end
  #   end
    

  #   report.pages.each do |page|
  #     page[:title] = 'Receta Digital'
  #     page[:remit_code] = prescription.remit_code
  #     page[:date_now] = DateTime.now.strftime("%d/%m/%YY")
  #     page[:page_count] = report.page_count
  #     page[:sector] = current_user.sector_name
  #     page[:establishment] = current_user.establishment_name
  #   end

  #   report.generate
  # end
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chronic_prescription
      @chronic_prescription = ChronicPrescription.find(params[:id])
    end

    def chronic_prescription_params
      params.require(:chronic_prescription).permit(
        :professional_id,
        :patient_id,
        :diagnostic,        
        :date_prescribed,
        :expiry_date,
        original_chronic_prescription_products_attributes: [
          :id,
          :product_id, 
          :request_quantity,
          :total_request_quantity,
          :observation,
          :_destroy
        ]
      )
    end

    def chronic_prescription_dispensation_params
      params.require(:chronic_prescription).permit(
        chronic_dispensations_attributes: [
          :id,
          :status,
          :observation,
          :_destroy,
          chronic_prescription_products_attributes: [
            :id, 
            :original_chronic_prescription_product_id,
            :product_id, 
            :lot_stock_id,
            :request_quantity,
            :delivery_quantity,
            :observation,
            :_destroy,
            order_prod_lot_stocks_attributes: [
              :id,
              :quantity,
              :lot_stock_id,
              :_destroy
            ]
          ]
        ]
      )
    end

    def dispensing?
      return params[:commit] == "dispensing"
    end
end
