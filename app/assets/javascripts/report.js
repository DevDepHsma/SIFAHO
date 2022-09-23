$(document).on('turbolinks:load', function() {
  let $_AJAX
  $("#products-search , #patients-search").on('focusin', function(e){
    $($(e.target).attr('data-target')).collapse('show');
  });

  $('.collapse').on('show.bs.collapse', function (e) {
    $("button[data-target='#" + $(e.target).attr('id') + "']").find('svg').first().addClass('fa-rotate-180')
  });
  $('.collapse').on('hide.bs.collapse', function (e) {
    $("button[data-target='#" + $(e.target).attr('id') + "']").find('svg').first().removeClass('fa-rotate-180')
  });

  $("#products-search , #patients-search").on('keyup', function(e){
    const regexp = /^[a-zA-Z | 0-9 | áéíóúñ%°,.-]$/ig;
    if(e.key.match(regexp) || e.key === 'Backspace'){
      clearTimeout($_AJAX);
      $_AJAX = setTimeout(function(){
        $(e.target).attr('disabled', true);
        $("#loader-container").css({'display': 'flex'});
        const product_ids = $("input[name='report[product_ids]']").val();
        const patient_ids = $("input[name='report[patient_ids]']").val();
        $.ajax({
          url: $(e.target).attr('data-url'),
          contentType: 'script',
          data: {term: e.target.value, product_ids, patient_ids }
        });
      }, 700);      
    }
  });

  $("#all-products").on('change', function(e){
    console.log($(e.target).is(":checked"), "<==========")
    $(e.target).is(":checked") ? $("#products-selection-cotainer").hide() : $("#products-selection-cotainer").show();
  });
});



function toggleSelectItem(event, type){
  $("#loader-container").css({'display': 'flex'});
  const product_ids = $("input[name='report[product_ids]']").val();
  const patient_ids = $("input[name='report[patient_ids]']").val();
  const term = type === 'product' ? $("input#products-search").val() : $("input#patients-search").val();
  $.ajax({
    url: event.target.getAttribute('data-url'),
    contentType: 'script',
    data: { term, product_ids, patient_ids }
  });
}
