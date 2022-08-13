$(document).on('turbolinks:load', function() {

  

});
function sort_by(sortColumn, sortMethod, target){
  const form = $("#" + $(target).attr('data-form'));
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

function page_size_selection(e, formId){
  $("form#"+formId).find('input[name="per_page"]').val(e.target.value);
  $("form#"+formId).submit();
}

function mark_selected(e){
  if($(e.target).val() != ''){
    $(e.target).addClass('filled');
  }else{
    $(e.target).removeClass('filled');
  }
}
