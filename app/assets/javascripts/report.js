$(document).on('turbolinks:load', function() {
  $("#products-search").on('keyup', function(e){
    const regexp = /^[a-zA-Z | 0-9 | áéíóúñ%°,.-]$/ig;
    if((e.key.match(regexp) || e.key === 'Backspace') && ($(e.target).val().length > 2 || $(e.target).val().length == 0)){
      $(e.target).attr('disabled', true);
      $("#loader-container").css({'display': 'flex'});
      const product_ids = $("input[name='product_ids']").val();
      $.ajax({
        url: $(e.target).attr('data-url'),
        contentType: 'script',
        data: {product_term: e.target.value, product_ids }
      });
    }
  });
});

function toggleSelectProduct(event){
  $("#loader-container").css({'display': 'flex'});
  const product_ids = $("input[name='product_ids']").val();
  const product_term = $("input#products-search").val();
  $.ajax({
    url: $(event.target).attr('data-url'),
    contentType: 'script',
    data: { product_term, product_ids }
  });
}