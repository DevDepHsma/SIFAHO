$(document).on('turbolinks:load', function() {
  let $_AJAX
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
