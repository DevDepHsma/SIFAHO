$(document).on('turbolinks:load', function() {

  $("form.custom-filters-v1").on('submit', (e) => {
    $("#loader-container").css({'display': 'flex'});
  })
  
  $("a.page-link").on('click', (e) => {
    $("#loader-container").css({'display': 'flex'});
  })
  
  $("button.btn-clean-filters").on('click', (e) => {
    const $form = $("#" + $(e.target).attr('form'));
    resetForm($form);
    $form.submit();
  });
  
  function resetForm($form){
    $form.find('input:text, input:password, input:file, select, textarea').val('');
    $form.find('input:radio, input:checkbox')
         .removeAttr('checked').removeAttr('selected');
  }
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
