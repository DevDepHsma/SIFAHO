class MedicationsController < ApplicationController
  before_action :set_medication, only: [:show, :edit, :update, :destroy]

  # GET /medications
  # GET /medications.json
  def index
    @medications = Medication.all
  end

  # GET /medications/1
  # GET /medications/1.json
  def show
  end

  # GET /medications/new
  def new
    @medication = Medication.new
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
  end

  # GET /medications/1/edit
  def edit
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
  end

  # POST /medications
  # POST /medications.json
  def create
    @medication = Medication.new(medication_params)

    date_r = medication_params[:date_received]
    date_e = medication_params[:expiry_date]
    @medication.date_received = DateTime.strptime(date_r, '%d/%M/%Y %H:%M %p')
    @medication.expiry_date = DateTime.strptime(date_r, '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @medication.save
        format.html { redirect_to @medication, notice: 'Medication was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @medication }
      else
        format.html { render :new }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    new_date_received = DateTime.strptime(medication_params[:date_received], '%d/%M/%Y %H:%M %p')
    new_expiry_date = DateTime.strptime(medication_params[:expiry_date], '%d/%M/%Y %H:%M %p')

    respond_to do |format|
      if @medication.update(medication_params)
        @medication.update_attribute(:date_received, new_date_received)
        @medication.update_attribute(:expiry_date, new_expiry_date)
        format.html { redirect_to @medication, notice: 'Medication was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @medication }
      else
        format.html { render :edit }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /medications/1
  # DELETE /medications/1.json
  def destroy
    @medication.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to medications_url, notice: 'Medication was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medication
      @medication = Medication.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medication_params
      params.require(:medication).permit(:vademecum_id, :quantity, :date_received,
                                         :expiry_date, :medication_brand_id)
    end
end
