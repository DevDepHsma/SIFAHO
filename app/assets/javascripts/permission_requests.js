$(document).on('turbolinks:load', function() {
  if(!(_PAGE.controller === 'permission_requests' && (['new'].includes(_PAGE.action))) ) return false;
  $("#permission_request_establishment_id").on('change', function(e){
    $.ajax({
      url: e.target.getAttribute('data-request-url'), // request sectors
      type: 'GET',
      data: {
        term: e.target.value
      }
    });
  });
});

