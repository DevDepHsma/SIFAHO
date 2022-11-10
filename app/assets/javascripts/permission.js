$(document).on('turbolinks:load', function() {
  if(!(_PAGE.controller === 'permissions' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  $(".perm-mod-toggle-button").on('change', function(e){
    const parent = $(e.target).closest('.card');
    const permissions = parent.find('.perm-toggle-button');
    permissions.each((index, permission) => {
      $(permission).prop('checked', $(e.target).is(':checked'));
      $(permission).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
    });
  });
  $(".perm-toggle-button").on('change', function(e){
    $(e.target).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
    // mark "todos" checkbox as checked if all children are checked
    const parentCheckbox = $(e.target).closest('.card').find('input[type=checkbox].perm-mod-toggle-button').first();
    const checkboxes = $(e.target).closest('.collapse').find('input[type=checkbox].perm-toggle-button');
    const checkBoxValueArr = checkboxes.toArray().map(element => $(element).is(':checked') );
    const anyUnchecked = checkBoxValueArr.some(element => element == false);
    parentCheckbox.prop('checked', !anyUnchecked);
  });
  
  $('#remote_form_sector, #remote_form_sector_selector').on('changed.bs.select', function (e) {
    toggleLoading();
    $("#remote_form_input_sector").val($(e.target).val());
    $("#remote_form_search_name").val("");
    $(e.target).closest('form').submit();
  });

  $("#remote_form_sector_selector").on('loaded.bs.select', function(e){
    $(e.target).siblings('.dropdown-menu').first().find('.bs-searchbox input.form-control').first().attr('id', $(e.target).attr('id') + '_inp_search');
  });
  
});

function searchModule(e){
  const regexp = new RegExp(e.target.value, 'i');
  $("#permission_users button.btn-block").each((index, ele) => {
    if( regexp.test($(ele).text()) ){
      $(ele).closest('div.card').show();
    }else{
      $(ele).closest('div.card').hide();
    }
  });
}