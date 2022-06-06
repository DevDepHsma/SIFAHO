$(document).on('turbolinks:load', function() {
  let professional_form = null;

  $("input#last-name, input#first-name").on('keyup', function(e){
    if((e.keyCode >= 65 && e.keyCode <= 90) || [8, 46].includes(e.keyCode)){
      console.log(e.keyCode, e.key, [8, 46].includes(e.keyCode));
      if(e.target.value.length > 2 || e.target.value.length == 0){
        $("#loading-icon").show();
        sendProfessionalForm();
        $(e.target).closest('form').submit();
      }else{
        $("#loading-icon").hide();
      }
    }
  });
  
  function sendProfessionalForm(){
    professional_form = $.ajax({
      type: $("#professional-form-async").attr('method'),
      dataType: "html",
      data: {
        last_name: $("#last-name").val(),
        first_name: $("#first-name").val(),
        id: $("input[type='hidden'][name='id']").val()
      },
      url: $("#professional-form-async").attr("action"),
      success: function(data) {
        // Success
        $("#loading-icon").hide();
        $('#professionals-list').html(data);
        $('[data-toggle="tooltip"]').tooltip({
          'selector': '',
          'container':'body'
        });
      },
      error:function(e){
        // Error
      }
    });
  }
});
