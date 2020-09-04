
// if( _PAGE.controller !== 'internal_orders' && (_PAGE.action !== 'new_applicant' || _PAGE.action !== 'edit_applicant') ) return;

// draw lot table selection
function drawLotTable(value, selectedLots, toDelivery){
  
  let tbody = $('<tbody></tbody>'); //$('#lot-selection').find('#tbody-lot-selection');
  $('#tdelivery-ref').html(toDelivery);

  // add every lot stock row
  value.map((item, index) => {
    const momentExpiryDate = moment(item.lot.expiry_date);
    const tdCheck = $('<td style="vertical-align:middle;" width="5%" onclick="event.stopPropagation();"></td>');
    const inputCheck = $('<input type="checkbox" aria-label="selection" name="lot-selection['+index+']" class="lot-selection" value="'+item.id+'">');
    
    // 
    inputCheck.on('change', (e) => {
      e.stopPropagation();
      const tr = $(e.target).closest('tr');

      if(!$(e.target).prop("checked")){
        $(tr).removeClass('selected-row');
        $(e.target).closest('tr').removeClass('selected-row');
      }else{
        $(e.target).closest('tr').addClass('selected-row');
      }
      
      getCurrentSelectedQuantity();
    });
     
    tdCheck.append(inputCheck);

    const thQuantity = $('<td onclick="event.stopPropagation();"></td>');
    const inputQuantity = $('<input type="number" min="0" max="100" class="form-control" aria-label="lot-quantity" name="lot-quantity['+index+']">');
    inputQuantity.on('focus', (e) => {
      e.stopPropagation();
      const tr = $(e.target).closest('tr');
      const checkBoxe = tr.find('input[type="checkbox"]').first();
      if(!checkBoxe.prop("checked")){
        checkBoxe.prop("checked", true);
        checkBoxe.trigger('change');
      }
    });
    
    inputQuantity.on('focusout', (e) => {
      e.stopPropagation();
      getCurrentSelectedQuantity();
    });

    thQuantity.append(inputQuantity);


    const tdCode = $('<td> '+item.lot.code+' </td>');
    const thStock = $('<td> '+item.quantity+' </td>');
    const thStatus = $('<td> '+item.lot.status+' </td>');
    const thExpiryDate = $('<td> '+momentExpiryDate.format("DD/MM/YYYY")+' </td>');
    const thLaboratory = $('<td width="35%"> '+item.lot.laboratory.name+' </td>');
    const tr = $('<tr></tr>');

    tr.on('click', (e) => {
      onClickRow(e);
    });

    tr.append(tdCheck, thQuantity, tdCode, thStock, thStatus, thExpiryDate, thLaboratory);
    tbody.append(tr);
  });

  tbody = initSelected(tbody, selectedLots);

  return tbody;
}

function onClickRow(e){
  e.stopPropagation();
  const tr = $(e.target).closest("tr");
  const checkBoxe = tr.find('input[type="checkbox"]').first();
  checkBoxe.prop("checked", !checkBoxe.prop("checked"));
  checkBoxe.trigger('change');
}

function addLot($parent, formHTML, option) {
  const new_id = new Date().getTime();
  const regexp = new RegExp("id_placeholder", "g");
  let content = formHTML.replace(regexp, new_id);

  const lotValueRef = new RegExp("lot_stock_value", "g");
  const quantityValueRef = new RegExp("quantity_value", "g");
  const lot_stock = $(option).find('input[type="checkbox"]').first();
  const quantity = $(option).find('input[type="number"]').first();
  content = content.replace(lotValueRef, lot_stock.val());
  content = content.replace(quantityValueRef, quantity.val());

  $($parent).append(content);
}

// Set every selected lot in the modal table
function initSelected(tbody, selectedLots){
  selectedLots.map((index, lot) => {
    const lotValue = $(lot).find('.lot_stock_ref').first().val();
    const qValue = $(lot).find('.lot_stock_quantity_ref').first().val();

    const checkbox = $(tbody).find('input[type="checkbox"][value="'+ lotValue +'"]').first();
    const quantityInput = $(checkbox).closest('tr').find('input[type="number"]').first();
    
    $(checkbox).prop("checked", true).trigger("change");
    $(quantityInput).val(qValue).trigger("change");
  });
  return tbody;
}

function getCurrentSelectedQuantity(){
  const selectedLots = $('#table-lot-selection').find('tr.selected-row');
  let totalQuantity = 0;
  selectedLots.map((index, tr) => {
    const inputQuantity = $(tr).find('input[type="number"]').val() * 1;
    totalQuantity += inputQuantity;
  });

  $("#qv-ref").attr('data-qv-ref', totalQuantity);
  $("#qv-ref").html(" " + totalQuantity);
}