var panels = ['#sign-in', '#shipping-address', '#payment-information','#create-account','#finalise-order'];

$(function() { 
  $(panels.slice(1).join()).children('.checkout-body').hide();
  $(panels.join()).children('.checkout-summary').hide();

  jQuery.validator.prototype.subset = function(container) {
    var ok = true;
    var self = this;
    $(container).find(':input').each(function() {
      if (!self.element($(this))) {
        ok = false;
      }
    });
    return ok;
  }
  
  $('#continue-1').click(function(event) {
    return change(0, 1);
  });

  $('#continue-2').click(function(event) {
    var firstError = true;
    var validator = $('#checkout-form').validate({
        rules: {
          'order[email]': { email: true }
        },
        errorPlacement: function(error, element) {
          if (firstError) {
            element.closest('li').callout({ 
              msg: "Please complete this required field",
              pointer: "left"
            });
            element.change(function(event) {
              if(!element.hasClass('error')) {
                element.closest('li').callout('hide');
              }
            });
            element.focus();
            firstError = false;
          }
        }
      });

    var valid = validator.subset("#shipping-address");
    if (valid) {
      return change(1, 2);
    }

    return false;
  });

  $('#continue-3').click(function(event) {
    return change(2, 3);
  });

  $('#continue-4a').click(function(event) {
    return change(3, 4);
  });

  $('#continue-4b').click(function(event) {
    return change(3, 4);
  });

  $('#edit-sign-in').click(function(event) {
    return change(currentStepIndex(), 0);
  });

  function change(from, to) {
    $(panels[from]).children('.checkout-body').slideUp();
    $(panels[from]).children('.checkout-header').removeClass('active');
    $(panels[from]).children('.checkout-summary').slideDown().children('div.summary').html('<p>Signed in as Guest.</p>');

    $(panels[to]).children('.checkout-body').slideDown();
    $(panels[to]).children('.checkout-header').addClass('active');
    $(panels[to]).children('.checkout-summary').slideUp();
    return false;
  }

  function currentStepIndex() {
    var element = $(panels.join()).children('.checkout-body').filter(':visible').first().parent().attr('id');
    return panels.indexOf('#' + element);
  }
});