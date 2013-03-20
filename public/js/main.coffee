$ ->
  
  $('form#name-form').on 'submit', (event) ->
    $.pjax.submit event, '.content'