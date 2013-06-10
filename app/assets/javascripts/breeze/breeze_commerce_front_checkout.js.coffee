if $('#checkout-form').length > 0 # i.e. if we're on the shopping cart page

  # Post to the provided URL with the specified parameters.
  post = (path, parameters) ->
    form = $("<form></form>")
    form.attr "method", "post"
    form.attr "action", path
    $.each parameters, (key, value) ->
      field = $("<input></input>")
      field.attr "type", "hidden"
      field.attr "name", key
      field.attr "value", value
      form.append field
    # The form needs to be a part of the document in
    # order for us to be able to submit it.
    $(document.body).append form
    form.submit()

  # Copy the shipping address to the billing address
  duplicateAddress = ->
    $("#order_billing_address_name").val $("#order_shipping_address_name").val()
    $("#order_billing_address_address").val $("#order_shipping_address_address").val()
    $("#order_billing_address_city").val $("#order_shipping_address_city").val()
    $("#order_billing_address_state").val $("#order_shipping_address_state").val()
    $("#order_billing_address_postcode").val $("#order_shipping_address_postcode").val()
    selected = $("#order_shipping_address_country option:selected").val()
    $("#order_billing_address_country option[value='" + selected + "']").attr "selected", "selected"
    $("#order_billing_address_phone").val $("#order_shipping_address_phone").val()
    false

  clearBillingAddress = ->
    $("#order_billing_address_name").val ""
    $("#order_billing_address_address").val ""
    $("#order_billing_address_city").val ""
    $("#order_billing_address_state").val ""
    $("#order_billing_address_postcode").val ""
    $ "#order_billing_address_country option[value=\"\"]"
    $("#order_billing_address_phone").val ""
    false

  # Checkout Form
  validateStep = (stepName) ->
    stepValid = true
    $(stepName + " input").add(stepName + " textarea").add(stepName + " select").each (index) ->
      if $(this)[0].form == null
        # IE9 gets a null form.
        # Temporary shim to bypass client-side validation on IE9
        alert('Form is null.')
        stepValid = true
      else
        stepValid = false  unless $(this).valid() is 1
    stepValid

  # Return a nicely-formatted address
  # addressType is 'shipping' or 'billing'
  formatAddress = (addressType) ->
    address = ""
    address += $("#order_" + addressType + "_address_name").val() + "<br />"
    address += $("#order_" + addressType + "_address_address").val().replace(/\n\r?/g, '<br />') + "<br />"
    address += $("#order_" + addressType + "_address_city").val() + " "
    address += $("#order_" + addressType + "_address_state").val() + "<br />"
    address += $("#order_" + addressType + "_address_postcode").val() + "<br />"
    address += $("#order_" + addressType + "_address_country").val() + "<br />"
    address += "Contact Phone " + $("#order_" + addressType + "_address_phone").val()
    address

  changePanel = (from, to, summaryHtml) ->
    $(panels[from]).children(".checkout-body").slideUp()
    $(panels[from]).removeClass("active").addClass("visited")
    $(panels[from]).children(".checkout-summary").slideDown()
    $(panels[to]).children(".checkout-body").slideDown()
    $(panels[to]).addClass("active")
    $(panels[to]).children(".checkout-summary").slideUp()
    $(document).trigger "breezeCommerceCheckoutPanelChange", $(panels[to])
    false

  currentStepIndex = ->
    element = $(panels.join()).children(".checkout-body").filter(":visible").first().parent().attr("id")
    panels.indexOf "#" + element

  # Panels for the checkout form
  panels = ["#sign-in", "#shipping", "#billing", "#confirmation"]

  $("#new_customer").validate
    onkeyup: false,
    onclick: false
    errorElement: "span"
    errorClass: "help-inline"
    highlight: (label) ->
      $(label).closest(".control-group").removeClass("success").addClass "error"
    success: (label) ->
      label.append("").closest(".control-group").removeClass("error").addClass "success"

  $("#checkout-form").validate
    # onkeyup: false,
    errorElement: "span"
    errorClass: "help-inline"
    highlight: (label) ->
      $(label).closest(".control-group").removeClass("success").addClass "error"
    success: (label) ->
      label.append("").closest(".control-group").removeClass("error").addClass "success"

  # Show/hide password field for returning customers
  $("#returning_customer").change ->
    if @checked
      $('#continue-1b').hide()
    else
      $('#continue-1b').show()
    $("li#returning_customer_password").slideToggle @checked

  $('#button-sign_in').click (e) ->
    e.preventDefault()
    post(
      "/commerce/customers/sign_in"
      commit: "Sign in"
      authenticity_token: $('meta[name=csrf-token]').attr('content')
      utf8: "✓"
      'customer[email]': 'test@example.com'
      'customer[password]': 'test'
    )

  $("#continue-1a").click (event) ->
    changePanel(0, 1)

  $("#continue-1b").click (event) ->
    if $("#customer_email").valid()
      $("#order_email").val $("#customer_email").val()
      $("#guest_email").html $("#customer_email").val()
      $(document).trigger "breezeCommerceCheckoutGuestEmailEnter", $(this)
      return changePanel(0, 1)
    false

  $("#continue-2").live "click", (event) ->
    if validateStep("#shipping")
      duplicateAddress()
      $("#shipping .checkout-summary .summary").html formatAddress("shipping")
      $(document).trigger "breezeCommerceShippingAddressEnter", $(this)
      return changePanel(1, 2)
    false

  $("#checkout-form #same").change ->
    if $(this).attr("checked")
      duplicateAddress()
      $("#billing fieldset.address-billing ol.form").slideUp()
    else
      clearBillingAddress()
      $("#billing fieldset.address-billing ol.form").slideDown()

  $("#continue-3").click (event) ->
    if validateStep("#billing")
      $("#billing .checkout-summary .summary").html formatAddress("billing")
      $(document).trigger "breezeCommerceBillingAddressEnter", $(this)
      return changePanel(2, 3)
    false

  $("#create_new_account").change ->
    $("li#new_account_password").slideToggle @checked

  $("#continue-4").click (event) ->
    if validateStep("#confirmation")
      $(document).trigger "breezeCommerceOrderSubmit", $(this)
      $('form#checkout-form').submit()
    false

  $("#edit-sign-in").click (event) ->
    changePanel currentStepIndex(), 0

  $("#edit-shipping").click (event) ->
    changePanel currentStepIndex(), 1

  $("#edit-payment").click (event) ->
    changePanel currentStepIndex(), 2

  $("#changed-my-mind").click (event) ->
    changePanel currentStepIndex(), 3

  $(document).ready ->
    # Starting status

    # ... depends on whether we have a customer already signed in
    if $("#sign-in").attr("data-customer_signed_in") is "true"
      # Hide first panel, show second
      $(panels.join()).children(".checkout-body").hide()
      $(panels[1]).children(".checkout-body").show()
      $(panels.slice(1).join()).children(".checkout-summary").hide()
    else
      # Hide all but first panel
      $(panels.slice(1).join()).children(".checkout-body").hide()
      $(panels.join()).children(".checkout-summary").hide()