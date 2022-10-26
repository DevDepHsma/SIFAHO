class Sectors::InternalOrders::Templates::ProvidersController < Sectors::InternalOrders::Templates::TemplatesController
  # GET /internal_orders/templates/providers/new
  def new
    policy(:internal_order_template_provider).new?
    @internal_order_template = InternalOrderTemplate.new(order_type: 'provision')
    @sectors = current_user.establishment.sectors
    @internal_order_template.internal_order_product_templates.build
  end

  # GET /internal_orders/templates/providers/1/edit
  def edit
    policy(:internal_order_template_provider).edit?(@internal_order_template)
    @sectors = current_user.establishment.sectors
  end

  # POST /internal_orders/templates/providers
  # POST /internal_orders/templates/providers.json
  def create
    policy(:internal_order_template_provider).create?
    @internal_order_template = InternalOrderTemplate.new(internal_order_template_params)
    @internal_order_template.owner_sector = current_user.sector
    @internal_order_template.created_by = current_user

    respond_to do |format|
      @internal_order_template.save!
      begin
        format.html do
          redirect_to internal_orders_templates_provider_url(@internal_order_template),
                      notice: 'La plantilla se ha creado correctamente.'
        end
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = current_user.establishment.sectors
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /internal_orders/templates/providers/1
  # PATCH/PUT /internal_orders/templates/providers/1.json
  def update
    policy(:internal_order_template_provider).update?(@internal_order_template)
    respond_to do |format|
      if @internal_order_template.update(internal_order_template_params)
        format.html do
          redirect_to internal_orders_templates_provider_url(@internal_order_template),
                      notice: 'La plantilla se ha creado correctamente.'
        end
        format.json { render :show, status: :ok, location: @internal_order_template }
      else
        @sectors = current_user.establishment.sectors
        format.html { render :edit }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def build_from_template
    respond_to do |format|
      @internal_order = InternalOrder.create(applicant_sector_id: @internal_order_template.destination_sector_id,
                                             provider_sector: current_user.sector,
                                             requested_date: DateTime.now,
                                             status: 'proveedor_auditoria',
                                             observation: @internal_order_template.observation,
                                             order_type: @internal_order_template.order_type)
      format.html do
        redirect_to edit_products_internal_orders_provider_path(id: @internal_order, template: @internal_order_template)
      end
    end
  end
end
