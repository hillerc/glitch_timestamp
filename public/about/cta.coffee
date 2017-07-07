$('.contact-form').submit (event) ->
  $('input').removeClass 'error'
  data = []
  event.preventDefault()
  inputs = $(event.target).find('input').not('input[type=submit]')
  inputs.each ->
    input = {}
    input.name = @name
    input.val = $(this).val()
    data.push input
    return
  if formIsValid(data)
    submitForm data
  false

formIsValid = (data) ->
  console.log data
  valid = true
  name = data[0].val.trim()
  company = data[1].val.trim()
  email = data[2].val.trim()
  phone = data[3].val.trim()
  if name == ''
    $('input[name=name]').addClass 'error'
    valid = false
  if company == ''
    $('input[name=company]').addClass 'error'
    valid = false
  if email == ''
    $('input[name=email]').addClass 'error'
    valid = false
  if valid
    true
  else
    false

submitForm = (data) ->
  $('.form-submit').addClass('hidden')
  $('.form-sending').removeClass('hidden')
  $.ajax
    type: "POST",
    url: "/email-sales",
    data: JSON.stringify(data)
    contentType: "application/json; charset=utf-8"
    success: (response) ->
      console.log '💌 successfully sent!', response
      $('.contact-form-desc').addClass 'hidden'
      $('.contact-form-inputs').addClass 'hidden'
      $('.contact-success').removeClass 'hidden'
    error: (error) ->
      console.error 'ajax error', error 