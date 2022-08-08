$(document).on('turbolinks:load', function() {
  // let form;
  // $(".custom-filters-v1 input").on('keyup', function(e){
  //   setTimeout(function(){
  //     $(e.target).closest('form.custom-filters-v1').submit();
  //   }, 2000);
  // })
  // $("form.custom-filters-v1").on('submit', function(event){
  //   event.preventDefault();
  //   event.stopPropagation();
  //   if(form) form.abort();
  //   form = $.ajax({
  //     url: event.target.getAttribute('action'),
  //     dataType: 'script',
  //     data: $(event.target).serialize()
  //   });
  // });

  $("a.custom-sort-v1").on('click', function(e){
    e.stopPropagation();
    e.preventDefault();
    sort_by($(e.target).attr('data-column'), $(e.target).attr('data-sort-method'), $(e.target));
  });

  function sort_by(sortColumn, sortMethod, $target){
    const sortString = [sortColumn, sortMethod].join(':');
    const form = $("#" + $target.attr('data-form'));
    console.log(form);
    const sortedInput = $(form).find('input[name="filter[sort]"]');
    $(sortedInput).val(sortString);
      // console.log(sortString, "<==========");
    // 'by_professional:asc'
    // 'by_professional:desc'
    // 'by_patient:asc-by_professional:asc'
    // $(form).find('input[name="sort"]').val(sorted + '-by_professional:asc');
    $(form).submit();
  }
});
