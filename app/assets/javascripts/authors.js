$(function() {
  $('h1').css({color: 'red'});


  $('.new-author')
    .on('ajax:send', function() {
      $('.authors').append('<img class="loader" style="height: 50px;" src="https://i.redd.it/ounq1mw5kdxy.gif" />');
    })
    .on('ajax:complete', function() {
      $('.loader').remove();
    })

});

