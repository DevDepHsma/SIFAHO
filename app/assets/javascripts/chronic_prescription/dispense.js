$(document).on('turbolinks:load', function(e){
  if( _PAGE.controller !== 'prescriptions/chronic_dispensations' || !(['new', 'create'].includes(_PAGE.action)) ) return false;
  
  initEvents();
  
  // button submit
  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
    $('form#'+$(e.target).attr('form')).submit();
  });

  // $(".progress-bar").each((index, element) => {
  //   const percentage = (($(element).attr('data-total-delivered') * 100) / $(element).attr('data-total-request')).toFixed(2);
  //   $(element).css({"width": percentage+"%"});
  //   $(element).attr("aria-valuenow", percentage);
  //   $(element).siblings('.percentage-text').first().text(percentage+"%");
  // });

  // cocoon init
  $('.chronic-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
    $(inserted_item).find('input.product-code').first().focus();
  });
  
  // set expiry date calendar format
  function initEvents(){

    // autocomplete establishment input
    $('.product-code').autocomplete({
      source: $('.product-code').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el código de insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onChangeOnSelectAutoCProductCode(event.target, ui.item);
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    // Función para autocompletar y buscar el insumo
    $('.product-name').autocomplete({
      source: $('.product-name').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el noombre del insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onSelectAutoCSupplyName(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.request-quantity").first().focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
    
    deliveryQuantityEventBinding();

    lotsQuantitySelection();
    
    const trs = $('.chronic-product-cocoon-container').find('tr.nested-fields');
    trs.map((index, tr) => {
      const toDelivery = $(tr).find("input.deliver-quantity").val(); // get delivery quanitty
      let totalQuantitySelected = 0;
      const lotStockHidden = $(tr).find('.lots').has('input._destroy[value="false"]');// filter values with _destroy=true
      let selectedQuantity;
      if(lotStockHidden.length){
        selectedQuantity = $(lotStockHidden).find('.lot_stock_quantity_ref');
        selectedQuantity.map((index, option) => {
          // option
          totalQuantitySelected += ($(option).val() * 1);
        });
      }
      setProgress(tr, totalQuantitySelected, toDelivery, (typeof(selectedQuantity) !== 'undefined' ? selectedQuantity.length : 0));
    });

  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.attr('data-available-stock', item.stock);
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      // tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input  
      tr.find("input.deliver-quantity").first().focus();
      tr.find('div.lot-stocks-hidden').html('');
      setProgress(tr, 0, tr.find("input.deliver-quantity").first().val(), 0);
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.attr('data-available-stock', item.stock);
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      // tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input
      tr.find('div.lot-stocks-hidden').html('');
      setProgress(tr, 0, tr.find("input.deliver-quantity").first().val(), 0);
    }
  }

  function lotsQuantitySelection(){
    // Select del lote
    $(".select-lot-btn").on('click', function(e){
      const templateHidden = $(e.target).attr("data-template-fill-hidden");
      const tr = $(e.target).closest(".nested-fields");
      const rows = $('.chronic-product-cocoon-container').find('tr.nested-fields');
      
      const trIndex = $(rows).index(tr); // get the row index for manipulate lot hiddens fields value
      const url = $(e.target).attr('data-select-lot-url');
      const productId = tr.find("input.product-id").val(); // get product code
      const toDelivery = tr.find("input.deliver-quantity").val(); // get delivery quanitty
      const hiddenTarget = tr.find(".lot-stocks-hidden").first();
      const selectedLots = $(hiddenTarget).find('.lots').has('input._destroy[value="false"]');
      
      if(!productId){
        $('#dialog .modal-header').addClass('bg-warning');
        $('#dialog .modal-title').html("<i class='fa fa-exclamation-triangle'></i>  Elegir un producto");
        $('#dialog .modal-body').html("<p>No se ha seleccionado ningún producto</p><p>Por favor seleccione uno</p>");
        $('#dialog .modal-footer').html(
          "<button type='button' class='btn' data-dismiss='modal'>Volver</button>"
        );
        $('#dialog').modal("show");
        return;
      }
      $.ajax({
        url: url,
        method: 'GET',
        dataType: "JSON",
        data: {
          product_id: productId
      }}).done(function(response){
        const table_body = drawLotTable(response, selectedLots, toDelivery);
        $('#lot-selection').find('.modal-body tbody').first().remove();
        $('#lot-selection table').append(table_body);
        $('#lot-selection').attr('data-template-hidden', templateHidden);
        $('#lot-selection').attr('data-hidden-target', hiddenTarget);
        $('#lot-selection').attr('data-index-row', trIndex);
        $('#lot-selection').attr('data-to-delivery', toDelivery);

        $('#lot-selection table').find('input.lot-quantity').on('click', function(){
          this.select();
        });

        getCurrentSelectedQuantity();
        // Show the dynamic dialog
        $('#lot-selection').modal("show");

      });// End 

    });// End lot selection button click action
  }

  // On change delivery quantity
  function deliveryQuantityEventBinding(){
    $('input.request-quantity').on('change', function(e){
      const tr = $(e.target).closest(".nested-fields");
      const toRequest = $(e.target).val();
      tr.find("input.deliver-quantity").val(toRequest).trigger('change');

    });
    $('input.deliver-quantity').on('change', function(e){
      const tr = $(e.target).closest(".nested-fields");
      const toDelivery = tr.find("input.deliver-quantity").val();
      
        
      $(tr).find('button.select-lot-btn').siblings().first().css({'width': (!($(e.target).val() > 0) ? '100%' : '0%')});

      totalQuantitySelected = 0;
      let selectedQuantity = 0;
      const lotStocks = $(tr).find('.lot-stocks-hidden .lots');
      lotStocks.map((index, option) => {
        if($(option).find('input._destroy').first().val() === 'false'){
          selectedQuantity++;
          totalQuantitySelected += ($(option).find('.lot_stock_quantity_ref').first().val() * 1);
        }
      });
      
      setProgress(tr, totalQuantitySelected, toDelivery, selectedQuantity)
    });
  }

  
  // set progress bg, with quantity selected
  function setProgress(targetRow, totalQuantitySelected, toDelivery, selectedOptionsCount){
    if($(targetRow).attr("data-available-stock") == 0){
      $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': '0%'});
      $(targetRow).find('button.select-lot-btn').first().html('Sin stock');
      $(targetRow).find('button.select-lot-btn').first().attr('disabled', true);
    }else{
      $(targetRow).find('button.select-lot-btn').first().removeAttr('disabled');

      const quantityPercent = (totalQuantitySelected == 0 || toDelivery == 0) ? 0 : (totalQuantitySelected * 100 / toDelivery); //calc width percentage progress
      if(isNaN(quantityPercent)) return false; //return false if quantityPercent is NaN


      $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': (quantityPercent + '%')});
      $(targetRow).find('button.select-lot-btn').first().html("Seleccionados " + selectedOptionsCount);
      
      if(quantityPercent === 100){
        // add success class
        $(targetRow).find('button.select-lot-btn').siblings().first().addClass('complete-progress');
        $(targetRow).find('button.select-lot-btn').first().addClass('complete-progress');

        // remove danger class
        $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('fail-progress');
        $(targetRow).find('button.select-lot-btn').first().removeClass('fail-progress');
      }else if(quantityPercent < 100 ){
        // remove success class
        $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('complete-progress');
        $(targetRow).find('button.select-lot-btn').first().removeClass('complete-progress');

        // remove danger class
        $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('fail-progress');
        $(targetRow).find('button.select-lot-btn').first().removeClass('fail-progress');
      }else {
        // remove success class
        $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('complete-progress');
        $(targetRow).find('button.select-lot-btn').first().removeClass('complete-progress');
        
        // add danger class
        $(targetRow).find('button.select-lot-btn').siblings().first().addClass('fail-progress');
        $(targetRow).find('button.select-lot-btn').first().addClass('fail-progress');
      }
    }
  }

  // Remove style
  $('#lot-selection').on('hidden.bs.modal', function (e) {
    const templateHidden = $(e.target).attr('data-template-hidden');
    const trIndex = $(e.target).attr('data-index-row');
    const tr = $(".chronic-product-cocoon-container").find(".nested-fields")[trIndex];
    // const toDelivery = $(e.target).attr('data-to-delivery');
    const hiddenTarget = $(tr).find(".lot-stocks-hidden").first();
    // handle selected options
    const selectedOptions = $(e.target).find('tbody tr.selected-row');
    const nonSelectedOptions = $(e.target).find('tbody tr').not('.selected-row');
    
    let totalQuantitySelected = 0;
    // update hidden lots values
    selectedOptions.map((index, option) => {
      const lot_stock_id = $(option).find('input[type="checkbox"]').first().val();
      const quantity = $(option).find('input[type="number"]').first().val() * 1;
      const lot = $(hiddenTarget).find('div.lots[data-lsid="'+ lot_stock_id +'"]').first();

      // if not exists
      if(lot.length){
        $(lot).find('input[type="hidden"].lot_stock_quantity_ref').first().val(quantity);
        $(lot).find('input[type="hidden"]._destroy').first().val(false);
      }else{
        addLot(hiddenTarget, templateHidden, lot_stock_id, quantity);
      }
      // totalize the quanitty
      totalQuantitySelected += quantity;
    });
    
    // remove hidden lots values
    nonSelectedOptions.map((index, option) => {
      const lot_stock_id = $(option).find('input[type="checkbox"]').first().val();
      const lot = $(hiddenTarget).find('div.lots[data-lsid="'+ lot_stock_id +'"]').first();

      // if exists set _destroy in TRUE
      if(lot.length){
        $(lot).find('input[type="hidden"]._destroy').first().val(true);
      }
    });
    $(tr).find("input.deliver-quantity").first().val(totalQuantitySelected).trigger("change");
    // setProgress(tr, totalQuantitySelected, toDelivery, selectedOptions.length);
  }); 

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});