$(document).on('turbolinks:load', function(e){
  if(!(['lots'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;

  // Función para autocompletar y buscar el insum
  $("#lot_product_code_fake").autocomplete({
    source: function(request, response) {
      $.ajax({
        url: $("#lot_product_code_fake").attr('data-autocomplete-source'),
        dataType: "json",
        data: {
          term: request.term,
        },
        success: function(data) {
          response(data);
        }
      });
    },
    minLength: 1,
    autoFocus: true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el producto");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select: function (event, ui) {
      $("#lot_product_code_fake").val(ui.item.code);
      $("#lot_product_name_fake").val(ui.item.name);
      $('#lot_product_id').val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });
  
  $("#lot_product_name_fake").autocomplete({
    source: function(request, response) {
      $.ajax({
        url: $("#lot_product_name_fake").attr('data-autocomplete-source'),
        dataType: "json",
        data: {
          term: request.term,
        },
        success: function(data) {
          response(data);
        }
      });
    },
    minLength: 1,
    autoFocus: true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el producto");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select: function (event, ui) {
      $("#lot_product_code_fake").val(ui.item.code);
      $("#lot_product_name_fake").val(ui.item.name);
      $('#lot_product_id').val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });

});