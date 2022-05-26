class LotProvenancesController < ApplicationController
  before_action :set_lot_provenance, only: %i[show edit update destroy]

  # GET /lot_provenances
  # GET /lot_provenances.json
  def index
    authorize LotProvenance
    @lot_provenances = LotProvenance.all
  end

  # GET /lot_provenances/1
  # GET /lot_provenances/1.json
  def show
    authorize @lot_provenance
  end

  # GET /lot_provenances/new
  def new
    authorize LotProvenance
    @lot_provenance = LotProvenance.new
    respond_to do |format|
      format.js
    end
  end

  # GET /lot_provenances/1/edit
  def edit
    authorize @lot_provenance
    respond_to do |format|
      format.js
    end
  end

  # POST /lot_provenances
  # POST /lot_provenances.json
  def create
    @lot_provenance = LotProvenance.new(lot_provenance_params)
    respond_to do |format|
      if @lot_provenance.save
        @lot_provenances = LotProvenance.all
        flash[:notice] = 'La procedencia se ha creado correctamente.'
        format.js
      else
        format.js { render :new }
        format.json { render json: @lot_provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lot_provenances/1
  # PATCH/PUT /lot_provenances/1.json
  def update
    authorize @lot_provenance
    respond_to do |format|
      if @lot_provenance.update(lot_provenance_params)
        @lot_provenances = LotProvenance.all
        flash[:notice] = 'La procedencia se ha modificado correctamente.'
        format.js
      else
        format.html { render :edit }
        format.json { render json: @lot_provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lot_provenances/1
  # DELETE /lot_provenances/1.json
  def destroy
    authorize @lot_provenance
    @lot_provenance.destroy
    respond_to do |format|
      format.html { redirect_to lot_provenances_url, notice: 'La procedencia se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lot_provenance
    @lot_provenance = LotProvenance.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lot_provenance_params
    params.require(:lot_provenance).permit(:name)
  end
end
