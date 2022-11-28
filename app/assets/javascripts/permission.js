$(document).on('turbolinks:load', function () {
  if (!(_PAGE.controller === 'permissions' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action)))) return false;
  $(".perm-mod-toggle-button").on('change', function (e) {
    if (!$(e.target).hasClass('editing')) {
      $(e.target).closest('form#permission_users').addClass('editing')
    }
    const parent = $(e.target).closest('.card');
    const permissions = parent.find('.perm-toggle-button');
    permissions.each((index, permission) => {
      $(permission).prop('checked', $(e.target).is(':checked'));
      $(permission).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
    });
  });
  $(".perm-toggle-button").on('change', function (e) {
    if (!$(e.target).hasClass('editing')) {
      $(e.target).closest('form#permission_users').addClass('editing')
    }
    $(e.target).siblings("input[type='hidden']").val(!$(e.target).is(':checked'));
    // mark "todos" checkbox as checked if all children are checked
    const parentCheckbox = $(e.target).closest('.card').find('input[type=checkbox].perm-mod-toggle-button').first();
    const checkboxes = $(e.target).closest('.collapse').find('input[type=checkbox].perm-toggle-button');
    const checkBoxValueArr = checkboxes.toArray().map(element => $(element).is(':checked'));
    const anyUnchecked = checkBoxValueArr.some(element => element == false);
    parentCheckbox.prop('checked', !anyUnchecked);
  });

  $('#remote_form_sector_selector').on('changed.bs.select', function (e) {
    toggleLoading();
    $(e.target).closest('form').submit();
  });

  $("#permission_users").on('submit', () => {
    toggleLoading();
  });

  $("#open-sectors-select-modal").on('click', (e) => {
    const modalId = $(e.target).attr('data-target')
    if ($("#permission_users").hasClass('editing')) {
      modalConfirm(function (confirm) {
        if (confirm) {
          $(modalId).modal('show');
        }
      });
    } else {
      $(modalId).modal('show');
    }
  })
});

$(document).on('turbolinks:before-visit', function (event) {
  event.preventDefault();
  if ($("#permission_users").hasClass('editing')) {
    modalConfirm(function (confirm) {
      if (confirm) {
        window.location = event.originalEvent.data.url;
      }else return;
    });
  } else {
    window.location = event.originalEvent.data.url;
  }
  return;
});

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
  if (!$(e.target).hasClass('editing')) {
    $(e.target).closest('form#permission_users').addClass('editing')
  }
  const url_to_build_permissions = $(e.target).attr('data-url');
  const target = $(e.target).attr('data-target');
  $('input[name="' + target + '"]').val($(e.target).is(':checked') ? 0 : 1)
  $.ajax({
    url: url_to_build_permissions,
    method: 'POST',
    data: $(e.target).closest('form').serialize()
  });
}

function changeSector(change_sector_url) {
  if ($("#permission_users").hasClass('editing')) {
    modalConfirm(function (confirm) {
      if (confirm) {
        toggleLoading();
        $.ajax({
          url: change_sector_url,
          dataType: 'script',
          method: 'GET',
        })
      }
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



