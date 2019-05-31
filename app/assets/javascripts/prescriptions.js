$(document).on('turbolinks:load', function() {
  
  $(function () {
    var today = new moment();
    var expiryDate = new moment().add(30, 'days');
    $('#prescription_prescribed_date').datetimepicker({
      format: 'DD/MM/YYYY',
      date: today
    });
    $('#prescription_expiry_date').datetimepicker({
      format: 'DD/MM/YYYY',
      date: expiryDate,
      useCurrent: false, //Important! See issue #1075
    });
    $("#prescription_prescribed_date").on("dp.change", function (e) {
      $('#prescription_expiry_date').data("DateTimePicker").minDate(e.date);
      $('#prescription_expiry_date').data("DateTimePicker").date(e.date.add(30,'days'));
    });
    $("#prescription_expiry_date").on("dp.change", function (e) {
        $('#prescription_prescribed_date').data("DateTimePicker").maxDate(e.date);
    });
  });

  $('.selectpicker').selectpicker();

  $('.quantity_supply_lots').on('cocoon:after-insert', function(e, insertedItem) {
    $('.selectpicker').selectpicker();
  });

  $(".supply-name").on("click", function () {
    $(this).select();
  });
  $(".supply-lot-name").on("click", function () {
    $(this).select();
  });

  // Función para autocompletar nombre y apellido del doctor
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#professional').autocomplete({
      source: $('#professional').data('autocomplete-source'),
      minLength: 2,
      select:
      function (event, ui) {
        $("#professional_id").val(ui.item.id);
      },
      response: function(event, ui) {
        if (!ui.content.length) {
          var noResult = { value:"",label:"No se encontró al doctor" };
          ui.content.push(noResult);
        }else{
          $.ajax({
            url: "/prescriptions/get_by_patient_id", // Ruta del controlador
            type: 'GET',
            data: {
              term: $('#patient_id').val()
            },
            dataType: "json",
            error: function(XMLHttpRequest, errorTextStatus, error){
              alert("Failed: "+ errorTextStatus+" ;"+error);
            },
            success: function(data){
              if (!data.length) {
                $('#non-pre-mes').collapse();
              }else{
                $('#non-pre-mes').collapse();
              } // End if
            }// End success
          });// End ajax
        }
      }
    })
  });

  // Función para autocompletar Nombre de paciente
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#patient').autocomplete({
      source: $('#patient').data('autocomplete-source'),
      minLength: 3,
      response: function (data) {
        if (data.length < 1) {
          $("#patient").tooltip({
            placement: 'bottom',trigger: 'manual', title: 'No se encontró el paciente'}).tooltip('show');
        }
      },
      select:
      function (event, ui) {
        $("#patient").tooltip('hide');
        $("#patient_id").val(ui.item.id);
        $("#patient_dni").val(ui.item.dni);
        $.ajax({
          url: "/prescriptions/get_by_patient_id", // Ruta del controlador
          type: 'GET',
          data: {
            term: ui.item.id
          },
          dataType: "json",
          error: function(XMLHttpRequest, errorTextStatus, error){
            alert("Failed: "+ errorTextStatus+" ;"+error);
          },
          success: function(data){
            console.log(data);
            if (!data.length) {
              $('#non-pres').toggleClass('hidden', false);
              $('#pat-pres').toggleClass('hidden', true);
            }else{
              for(var i in data)
              {
                $("#pat-pres-body").append(
                  "<tr>"+
                    '<td>'+data[i].order_type+'</td>'+
                    '<td>'+data[i].professional+'</td>'+
                    '<td>'+data[i].supply_count+'</td>'+
                    '<td>'+data[i].status+'</td>'+
                    '<td>'+data[i].created_at+'</td>'+
                  "</tr>"
                );
              }
              $('#non-pres').toggleClass('hidden', true);
              $('#pat-pres').toggleClass('hidden', false);
            } // End if
          }// End success
        });// End ajax
      }
    })
  });

  // Ocultar tooltip
  $(document).on('focusout', '#patient', function() {
    $(this).tooltip('hide');
  });

  $.ui.autocomplete.prototype._renderItem = function (ul, item) {   
    if(item.length > 0 ){
      console.log("hay elementos");
    }
    var t = String(item.value).replace(
            new RegExp(this.term, "gi"),
            "<strong>$&</strong>");
    return $("<li></li>")
      .data("item.autocomplete", item)
      .append("<div>" + t + "</div>")
      .appendTo(ul);
  };

  $(document).on("keyup change",".treat-durat", function() {
    var _this = $(this);
    jQuery(function() {
      var nested_form = _this.parents(".nested-fields");
      var request_quantity = nested_form.find(".request-quantity");
      var daily_dose = nested_form.find(".daily-dose");
      daily_dose.val(1);
      request_quantity.val( _this.val() * daily_dose.val());
    });
  });

  $(document).on("keyup change",".daily-dose", function() {
    var _this = $(this);
    jQuery(function() {
      var nested_form = _this.parents(".nested-fields");
      var request_quantity = nested_form.find(".request-quantity");
      var treat_durat = nested_form.find(".treat-durat");
      request_quantity.val( treat_durat.val() * _this.val());
    });
  });
});