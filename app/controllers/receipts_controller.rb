class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :new, :edit, :update, :delete, :destroy, :rollback_order, :receive_order]

  # GET /receipts
  # GET /receipts.json
  def index
    authorize Receipt
    @filterrific = initialize_filterrific(
      Receipt.applicant(@current_user.active_sector).order(created_at: :desc),
      params[:filterrific],
      select_options: { },
      persistence_id: false
    ) or return
    @receipts = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportServices::ReceiptReportService.new(@current_user, @receipt).generate_pdf
        send_data pdf, filename: "recibo_#{@receipt.remit_code}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /receipts/new
  def new
    authorize Receipt
    @provenances = LotProvenance.all
  end

  # GET /receipts/1/edit
  def edit
    authorize @receipt
    @provenances = LotProvenance.all
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)
    authorize @receipt
    respond_to do |format|
      @receipt.applicant_sector = @current_user.active_sector
      @receipt.created_by = @current_user
      @receipt.code = "RE"+DateTime.now.to_s(:number)
      begin
        @receipt.auditoria! #default status
        @receipt.create_notification(@current_user, "creó")
        message = 'El recibo se ha creado y se encuentra en auditoría.'

        format.html { redirect_to @receipt, notice: message }
        format.json { render :show, status: :created, location: @receipt }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
        @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build
        @provenances = LotProvenance.all
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    authorize @receipt
    respond_to do |format|
      @receipt.update(receipt_params)
      begin
        @receipt.save!
        @receipt.create_notification(@current_user, "auditó")
        message = 'El recibo se ha auditado correctamente'
        format.html { redirect_to @receipt, notice: message }
        format.json { render :show, status: :ok, location: @receipt }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
        @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build

        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    authorize @receipt
    @sector_name = @receipt.applicant_sector.name
    @receipt.destroy
    respond_to do |format|
      flash.now[:success] = "Recibo de #{@sector_name} se ha eliminado."
      format.js
    end
  end

  def rollback_order
    authorize @receipt
    @receipt.return_remit
    respond_to do |format|
      flash.now[:success] = "Recibo de #{@receipt.remit_code} se ha retornado correctamente."
      format.html { redirect_to receipt_path(@receipt) }
    end
  end

  def receive_order
    authorize @receipt
    @receipt.receive_remit(@current_user)
    @receipt.create_notification(@current_user, 'recibió')
    respond_to do |format|
      flash.now[:success] = "El recibo #{@receipt.remit_code} se ha realizado correctamente"
      format.html { redirect_to @receipt }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_receipt
    @receipt = params[:id].present? ? Receipt.find(params[:id]) : Receipt.new
    @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
    @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def receipt_params
    params.require(:receipt).permit(
      :provider_sector_id,
      :observation,
      receipt_products_attributes: 
      [
        :id,
        :product_id,
        :receipt_id,
        :expiry_date, 
        :quantity,
        :provenance_id,
        :lot_code,
        :laboratory_id,
        :lot_id,
        :lot_stock_id,
        :_destroy
      ]
    )
  end
end
