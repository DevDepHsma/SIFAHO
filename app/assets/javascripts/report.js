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
        const products_ids = $("input[name='report[products_ids]']").val();
        const patients_ids = $("input[name='report[patients_ids]']").val();
        $.ajax({
          url: $(e.target).attr('data-url'),
          contentType: 'script',
          data: {term: e.target.value, products_ids, patients_ids }
        });
      }, 700);      
    }
  });
});



function toggleSelectItem(event, type){
  $("#loader-container").css({'display': 'flex'});
  const products_ids = $("input[name='report[products_ids]']").val();
  const patients_ids = $("input[name='report[patients_ids]']").val();
  const term = type === 'product' ? $("input#products-search").val() : $("input#patients-search").val();
  $.ajax({
    url: event.target.getAttribute('data-url'),
    contentType: 'script',
    data: { term, products_ids, patients_ids }
  });
}
