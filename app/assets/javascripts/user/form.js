$(document).on('turbolinks:load', function (e) {

  if (!(_PAGE.controller === 'users' && (['index'].includes(_PAGE.action)))) return false;

  // Función para autocompletar nombre y apellido del doctor
  $('#professional').autocomplete({
    source: $('#professional').data('autocomplete-source'),
    minLength: 2,
    autoFocus: true,
    messages: {
      noResults: function (count) {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function (event, ui) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
      function (event, ui) {
        $("#professional_id").val(ui.item.id);
      },
    response: function (event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });
  
   // on change establishment select
   $('#filter_establishment').on('change', function(e){
    if(typeof e.target.value === 'undefined' || typeof e.target.value === null || e.target.value.length < 2){
      $('#filter_sector').find('option').remove();
      $('#filter_sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
    getSectors($(this).val());
  });

  // ajax, brings sector according with the establishment ID
  function getSectors(establishmentId){
    if(typeof establishmentId !== 'undefined'){ 
      $.ajax({
        url: "/sectores/with_establishment_id", // Ruta del controlador
        method: "GET",
        dataType: "JSON",
        data: { term: establishmentId}
      })
      .done(function( data ) {
        if(data.length){
          $('#filter_sector').removeAttr("disabled");
          $('#filter_sector').find('option').remove();
          $.each(data, function(index, element){
            $('#filter_sector').append('<option value="'+element.id+'">'+ element.label +'</option>');
          });
          $('#filter_sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
        }
      });
    }else{
      $('#filter_sector').find('option').remove();
      $('#filter_sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  }

});