$(document).on('turbolinks:load', function() {

  $("a.custom-sort-v1").on('click', function(e){
    e.stopPropagation();
    e.preventDefault();
    sort_by($(e.target).attr('data-column'), $(e.target).attr('data-sort-method'), $(e.target));
  });

});
function sort_by(sortColumn, sortMethod, $target){
  const form = $("#" + $target.attr('data-form'));
  const sortedInput = $(form).find('input[name="filter[sort]"]');
  const oldSortedValue = sortedInput.val() !== '' ? sortedInput.val().split(";").filter((sp) => sp.indexOf(sortColumn+':')) : [];
  const attachedSort = ['asc', 'desc'].includes(sortMethod) ? [sortColumn, sortMethod].join(':') : '';
  
  if(attachedSort !== ''){
    oldSortedValue.push(attachedSort);
  }
  newSortedString = oldSortedValue.join(';');
  $(sortedInput).val(newSortedString);
  $(form).submit();
}
