$(document).on('turbolinks:load', function () {
  let $_AJAX
  $("#products-search ,#sectors-search , #patients-search").on('focusin', function (e) {
    $($(e.target).attr('data-target')).collapse('show');
  });

  $('.collapse').on('show.bs.collapse', function (e) {
    $("button[data-target='#" + $(e.target).attr('id') + "']").find('svg').first().addClass('fa-rotate-180')
  });
  $('.collapse').on('hide.bs.collapse', function (e) {
    $("button[data-target='#" + $(e.target).attr('id') + "']").find('svg').first().removeClass('fa-rotate-180')
  });

  $("#products-search , #patients-search, #sectors-search").on('keyup', function (e) {
    const regexp = /^[a-zA-Z | 0-9 | áéíóúñ%°,.-]$/ig;
    if (e.key.match(regexp) || e.key === 'Backspace') {
      clearTimeout($_AJAX);
      $_AJAX = setTimeout(function () {
        $(e.target).attr('disabled', true);
        $("#loader-container").css({ 'display': 'flex' });
        const products_ids = $("input[name='report[products_ids]']").val();
        const patients_ids = $("input[name='report[patients_ids]']").val();
        const sectors_ids = $("input[name='report[sectors_ids]']").val();
        if (e.target.id === "sectors-search") {
          $.ajax({
            url: $(e.target).attr('data-url'),
            contentType: 'script',
            data: { term: e.target.value, products_ids,sectors_ids }
          });
        } else {
          $.ajax({
            url: $(e.target).attr('data-url'),
            contentType: 'script',
            data: { term: e.target.value, products_ids, patients_ids }
          });
        }

      }, 700);
    }
  });
  $("input[name='report[report_type]']").on('click', function () {
    hideSearchType($(this))
  })

  if($("input[name='report[report_type]']").not(':checked')){//Charge first page select first option type
   $("input[name='report[report_type]']").first().click()
   
  }


});

function hideSearchType(radio_selected){
  if (radio_selected.val() == 'by_sector') {
    $("#patients-module").attr('hidden', 'true');
    $("#patients-search").attr('disabled', 'true')
    $("#sectors-search").removeAttr('disabled')
    $("#sectors-module").removeAttr('hidden');
  } else {
    if ((radio_selected.val() == 'by_patient')) {
      $("#sectors-module").attr('hidden', 'true');
      $("#sectors-search").attr('disabled', 'true')
      $("#patients-search").removeAttr('disabled')
      $("#patients-module").removeAttr('hidden');
    }
  }
}




function toggleSelectItem(event, type) {
  $("#loader-container").css({ 'display': 'flex' });
  const products_ids = $("input[name='report[products_ids]']").val();
  const patients_ids = $("input[name='report[patients_ids]']").val();
  const sectors_ids = $("input[name='report[sectors_ids]']").val();
  const term = type === 'product' ? $("input#products-search").val() : type === 'patient' ? $("input#patients-search").val() : $("input#sectors-search").val();
  if (type === 'sector') {
    $.ajax({
      url: event.target.getAttribute('data-url'),
      contentType: 'script',
      data: { term, products_ids, sectors_ids }
    });
  } else {
    $.ajax({
      url: event.target.getAttribute('data-url'),
      contentType: 'script',
      data: { term, products_ids, patients_ids }
    });
  }

}
