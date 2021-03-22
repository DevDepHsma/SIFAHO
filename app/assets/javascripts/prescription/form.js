$(document).on('turbolinks:load', function(e){

  if(!(['prescriptions'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update', 'dispense'].includes(_PAGE.action))) ) return false;

  
  // button submit
  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
    $('form#'+$(e.target).attr('form')).submit();
  });


  $('#patient-dni').autocomplete({
    source: $('#patient-dni').data('autocomplete-source'),
    autoFocus: true,
    minLength: 7,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró el paciente");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    response: function (event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    },
    select:
    function (event, ui) {
      event.preventDefault();
      // limpiamos los campos de andes
      $(".andes-input").val("");
      $("#patient-phones").html("");
      $(".andes-input").attr('disabled', true);

      if(ui.item.dni != '' && typeof ui.item.lastname !== 'undefined' && typeof ui.item.firstname !== 'undefined'){
        console.log(ui.item);
        $("#patient-dni").val(ui.item.dni);
        $("#patient-lastname").val(ui.item.lastname).attr('readonly', true);
        $("#patient-firstname").val(ui.item.firstname).attr('readonly', true);
        
        if(ui.item.create && typeof ui.item.status === 'undefined'){
          $(".andes-input").removeAttr('disabled');
          $("#patient-status").val("Validado");
          
          // Datos del paciente rellenados con Andes
          $("#patient-birthdate").val(ui.item.data.fechaNacimiento);
          $("#patient-marital-status").val(ui.item.data.estadoCivil);

          for(let index = 0; ui.item.data.contacto.length > index; index++){
            if(['celular', 'fijo'].includes(ui.item.data.contacto[index].tipo)){

              const phoneType = $("<input>");
              $(phoneType).attr('id', 'patient-phone-type-'+index)
              .attr('name', 'patient[patient_phones_attributes]['+index+'[phone_type]')
              .attr('type', 'hidden')
              .val(ui.item.data.contacto[index].tipo);
              
              const phoneNumber = $("<input>");
              $(phoneNumber).attr('id', 'patient-phone-number-'+index)
              .attr('name', 'patient[patient_phones_attributes]['+index+'][number]')
              .attr('type', 'hidden')
              .val(ui.item.data.contacto[index].valor);
              $("#patient-phones").append(phoneType, phoneNumber);
            }else if(['email'].includes(ui.item.data.contacto[index].tipo)){
              $("#patient-email").val(ui.item.data.contacto[index].valor);
            }
          };

          $("#patient-postal-code").val(ui.item.data.direccion[0].codigoPostal);
          $("#patient-line").val(ui.item.data.direccion[0].valor);
          $("#patient-city-name").val(ui.item.data.direccion[0].ubicacion.localidad.nombre);
          $("#patient-state-name").val(ui.item.data.direccion[0].ubicacion.provincia.nombre);
          $("#patient-country-name").val(ui.item.data.direccion[0].ubicacion.pais.nombre);
          $("#patient-andes-id").val(ui.item.data.id);
        }else{
          $("#patient-status").val(ui.item.status);
        }
      }else{
        resetForm();
      }

      setPatientSex(ui.item.sex);      
      setPatientPrescriptions(ui.item.create, ui.item.id);      
      const url = $('#patient-dni').attr('data-insurance-url');
      getInsurances(url, ui.item.dni);
      
    }
  });
  
  $('#patient-dni').on('keyup', function(e) {
    if($(e.target).val().length < 7){
      
      resetForm();
      resetPatientPrescriptions();
      $("#patient-submit").attr('disabled', true);
      
    }
  });
  /* =================================================FUNCIONES========================================================================= */
  
  /* Se obtienen las prescripciones */
  function getPrescriptionsTo(patientId){
    const prescriptionsUrl = $("#patient-dni").attr("data-prescriptions-url");
    $.ajax({
      url: prescriptionsUrl + "/" + patientId,
      dataType: "script"
    });
  }
  
  /* Reseteamos el formulario */
  function resetForm(){
    $("#patient-status").val("Temporal");
    $("#patient-lastname").val("").removeAttr('readonly');
    $("#patient-firstname").val("").removeAttr('readonly');
    setPatientSex();
    /* $('#patient-sex-fake').val("").addClass('d-none');
    $("#patient-sex").val("Otro").removeClass('d-none');
    $("#patient-sex").selectpicker('refresh'); */
  }
  
  /* Seteamos las prescripciones del paciente */
  function setPatientPrescriptions(isCreate, patientId){
    if(isCreate){
      resetPatientPrescriptions();
      $("#patient-submit").attr('disabled', false);
    }else{
      $("#new-receipt-buttons").fadeIn(300);
      // $("#new-chronic").fadeIn(300);
      // $("#new-outpatient").fadeIn(300);
      $("#patient-submit").attr('disabled', true);
      
      getPrescriptionsTo(patientId);
    }
  }

  /* Reset de prescripciones[tabs] */
  function resetPatientPrescriptions(){
    /* $("#new-chronic").fadeOut(300);
    $("#new-outpatient").fadeOut(300); */
    $("#new-receipt-buttons").fadeOut(300);
    $("div#chronic-prescriptions").html('');
    $("div#outpatient-prescriptions").html('');
    $("#chronic-tab").find('span.badge-secondary').first().html('0');
    $("#outpatient-tab").find('span.badge-secondary').first().html('0');
  }

  /* Seteamos el sexo del paciente */
  function setPatientSex(sex){
    if(typeof sex !== 'undefined'){
      // precargamos el sexo del paciente
      $("#patient-sex option").each((index, item) => {
        const sexMatch = new RegExp(sex, 'i');
        if($(item).val() && $(item).val().match(sexMatch)){
          $('#patient-sex-fake').val($(item).val()).attr('readonly', true).removeClass('d-none');
          $("#patient-sex").val($(item).val()).addClass('d-none');
          $("#patient-sex").selectpicker('refresh');
        }
      });
    }else{
      $('#patient-sex-fake').val("").addClass('d-none');
      $(".patient-form-selector").val("Otro").removeClass('d-none');
      $(".patient-form-selector").selectpicker('refresh');
    }
  }
});