class Establishments::ExternalOrders::Templates::ApplicantsController < Establishments::ExternalOrders::Templates::TemplatesController
  # GET /external_order_templates/new
  def new
    policy(:external_order_template_applicant).new?
    @external_order_template = ExternalOrderTemplate.new(order_type: 'solicitud')
    @external_order_template.external_order_product_templates.build
    @sectors = []
  end

  # GET /external_order_templates/1/edit
  def edit
    policy(:external_order_template_applicant).edit?(@external_order_template)
    @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
  end

  # POST /external_order_templates
  # POST /external_order_templates.json
  def create
    policy(:external_order_template_applicant).create?
    @external_order_template = ExternalOrderTemplate.new(external_order_template_params)
    @external_order_template.owner_sector = current_user.sector
    @external_order_template.created_by = current_user

    respond_to do |format|
      @external_order_template.save!
      format.html do
        redirect_to external_orders_templates_applicant_url(@external_order_template),
                    notice: 'La plantilla se ha creado correctamente.'
      end
    rescue ArgumentError => e
      flash[:alert] = e.message
    rescue ActiveRecord::RecordInvalid
    ensure
      @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
      format.html { render :new }
    end
  end

  # PATCH/PUT /external_order_templates/1
  # PATCH/PUT /external_order_templates/1.json
  def update
    policy(:external_order_template_applicant).update?(@external_order_template)

    respond_to do |format|
      @external_order_template.update!(external_order_template_params)
      format.html do
        redirect_to external_orders_templates_applicant_url(@external_order_template),
                    notice: 'La plantilla se ha editado correctamente.'
      end
    rescue ArgumentError => e
      flash[:alert] = e.message
    rescue ActiveRecord::RecordInvalid
    ensure
      @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
      format.html { render :edit }
    end
  end

  def build_from_template
    respond_to do |format|
      @external_order = ExternalOrder.create(provider_sector_id: @external_order_template.destination_sector_id,
                                             applicant_sector: current_user.sector,
                                             requested_date: DateTime.now,
                                             status: 'solicitud_auditoria',
                                             applicant_observation: @external_order_template.applicant_observation,
                                             order_type: @external_order_template.order_type)
      format.html do
        redirect_to edit_products_external_orders_applicant_path(id: @external_order,
                                                                 template: @external_order_template)
      end
    end
  end
end
