$(document).on('turbolinks:load', function() {
  let form;
  $(".custom-filters-v1 input").on('keyup', function(e){
    setTimeout(function(){
      $(e.target).closest('form.custom-filters-v1').submit();
    }, 2000);
  })
  $("form.custom-filters-v1").on('submit', function(event){
    event.preventDefault();
    event.stopPropagation();
    if(form) form.abort();
    form = $.ajax({
      url: event.target.getAttribute('action'),
      dataType: 'script',
      data: $(event.target).serialize()
    });
  });
});
