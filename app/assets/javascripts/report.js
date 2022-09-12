$(document).on('turbolinks:load', function() {
  $("#products-search").on('keyup', function(e){
    const regexp = /^[a-zA-Z | 0-9 | áéíóúñ%°,.-]$/ig;
    if(e.key.match(regexp) || e.key === 'Backspace'){
      $.ajax({
        url: $(e.target).attr('data-url'),
        contentType: 'script',
        data: {term: e.target.value}
      });
    }
  });

  $(".link-add-product").on('click', function(e){
    console.log($(e.target).attr('data-value'));
  });
});