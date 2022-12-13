$(document).on('turbolinks:load', function () {
  if (!(_PAGE.controller === 'permissions' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action)))) return false;

  $('#remote_form_sector_selector').on('changed.bs.select', function (e) {
    toggleLoading();
    $(e.target).closest('form').submit();
  });

  $("#permission_users").on('submit', () => {
    toggleLoading();
  });
});

function addSectorClick(e){
  if ($_UNSAVED) {
    modalConfirm($(e.target).attr('data-target'), true);
  } else {
    $($(e.target).attr('data-target')).modal('show');
  }
}

function permissionModChange(e){
  const parent = $(e.target).closest('.card');
  const permissions = parent.find('.perm-toggle-button');
  permissions.each((index, permission) => {
    $(permission).prop('checked', $(e.target).is(':checked'));
    $(permission).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
  });
}

function permissionChange(e){
  $(e.target).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
  // mark "todos" checkbox as checked if all children are checked
  const parentCheckbox = $(e.target).closest('.card').find('input[type=checkbox].perm-mod-toggle-button').first();
  const checkboxes = $(e.target).closest('.collapse').find('input[type=checkbox].perm-toggle-button');
  const checkBoxValueArr = checkboxes.toArray().map(element => $(element).is(':checked'));
  const anyUnchecked = checkBoxValueArr.some(element => element == false);
  parentCheckbox.prop('checked', !anyUnchecked);
}

function searchModule(e) {
  const regexp = new RegExp(e.target.value, 'i');
  $("#permission_users button.btn-block").each((index, ele) => {
    if (regexp.test($(ele).text())) {
      $(ele).closest('div.card').show();
    } else {
      $(ele).closest('div.card').hide();
    }
  });
}

function toggleRole(e) {
  toggleLoading();
  const url_to_build_permissions = $(e.target).attr('data-url');
  const target = $(e.target).attr('data-target');
  const role_id = $('input[name="' + target + '[role_id]"]').val()
  $('input[name="' + target + '[_destroy]"]').val($(e.target).is(':checked') ? 0 : 1)
  $.ajax({
    url: url_to_build_permissions,
    method: 'GET',
    dataType: 'JSON',
    data: {role_id}
  }).done( function(response){
    elements = response.map(function(e){ return $("input#perm-check-"+e); });
    
    elements.forEach(function (element) {
      $(element).prop('checked', $(e.target).is(':checked'));
      $(element).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
      const parentCheckbox = $(element).closest('.card').find('input[type=checkbox].perm-mod-toggle-button').first();
      const checkboxes = $(element).closest('.collapse').find('input[type=checkbox].perm-toggle-button');
      const checkBoxValueArr = checkboxes.toArray().map(children => $(children).is(':checked'));
      const anyUnchecked = checkBoxValueArr.some(element => element == false);
      parentCheckbox.prop('checked', !anyUnchecked);
    });
    toggleLoading();
  });
}

function changeSector(change_sector_url) {
  if ($_UNSAVED) {
    modalConfirm(null, false,function () {
      $.ajax({
        url: change_sector_url,
        dataType: 'script',
        method: 'GET',
      });
    });
  } else {
    toggleLoading();
    $.ajax({
      url: change_sector_url,
      dataType: 'script',
      method: 'GET',
    })
  }
}



