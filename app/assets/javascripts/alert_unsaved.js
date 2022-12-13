
let $_UNSAVED = false;
 
$(document).on('change', 'form[role="check-modified"]:not([data-remote]) :input', function() {
  return $_UNSAVED = true;
});

$(document).on('turbolinks:load', function() {
  return $_UNSAVED = false;
});
 
$(document).on('submit', 'form[role="check-modified"]', function() {
  $_UNSAVED = false;
});

$(document).on('change', 'form[role="check-modified"].editing', function() {
  return $_UNSAVED = true;
}); 
 

$(document).on('turbolinks:before-visit', function(event) {
  /* check if exists a product unsaved on order products form */
  if($(document).find('.unsaved-row').length){
    $_UNSAVED = true;
  };

  if($_UNSAVED){
    event.preventDefault();
    modalConfirm(event.originalEvent.data.url);
  }
});

function modalConfirm(target, isModal = false, callback = null){
  $("#confirm-unsaved").modal('show');
  $("#confirm-unsaved-btn").on("click", function(){
    toggleLoading();
    if(isModal){
      $(target).modal('show');
      toggleLoading();
    }else if(callback !== null){
      callback();
    }else if(target !== undefined && target !== null){
      continueTo(target);
    }
    $("#confirm-unsaved").modal('hide');
    $_UNSAVED = false;
    $(this).unbind();
    $("#no-confirm-unsaved-btn").unbind();
  });
  
  $("#no-confirm-unsaved-btn").on("click", function(){
    $("#confirm-unsaved").modal('hide');
    $(this).unbind();
    $("#confirm-unsaved-btn").unbind();
  });
  return;
};

function continueTo(target){
  window.location = target;
}