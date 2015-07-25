$ ->
  $('#show_name_field').click ->
    $('input[name=name]').show().focus()

  if $('input[name=name]').val().length > 0
    $('#show_name_field').click()

  if $('#error').text().length > 0
    $('#error').show()

