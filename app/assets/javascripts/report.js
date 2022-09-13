$(document).on('turbolinks:load', function() {
  $("#products-search").on('keyup', function(e){
    const regexp = /^[a-zA-Z | 0-9 | áéíóúñ%°,.-]$/ig;
    const product_ids = $("input[name='product_ids']").val();
    if(e.key.match(regexp) || e.key === 'Backspace'){
      $.ajax({
        url: $(e.target).attr('data-url'),
        contentType: 'script',
        data: {product_term: e.target.value, product_ids }
      });
    }
  });

  $(".link-add-product").on('click', function(e){
    console.log($(e.target).attr('data-value'));
  });
});