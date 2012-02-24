$(window).ready(function() {
  $('.info-link').click(function(e) {
    e.preventDefault();
    if($(this).data('visible')) {
      $(this).parent().next().hide();
      $(this).data('visible', false)
    }
    else {
      $(this).parent().next().show();
      $(this).data('visible', true)
    }
  });
});