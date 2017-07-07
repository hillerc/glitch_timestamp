express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
engines = require 'consolidate'
bodyParser = require 'body-parser'
stylish = require 'stylish'
autoprefixer = require 'autoprefixer-stylus'
rq = require 'request-promise'
closeIo = require './closeIo'

PORT = process.env.PORT

app.use(express.static('public'))

# sets up jade
app.set('view engine', 'jade')
app.engine('jade', engines.jade)

# sets up coffee-script support
app.use coffeeMiddleware
  bare: true
  src: "public"
require('coffee-script/register')

app.use bodyParser.urlencoded
  extended: false
app.use bodyParser.json()
app.use bodyParser.text()

# sets up stylus and autoprefixer

app.use stylish
  src: __dirname + '/public'
  setup: (renderer) ->
    renderer.use autoprefixer()
  watchCallback: (error, filename) ->
    if error
      console.log error
    else
      console.log "#{filename} compiled to css"

app.listen PORT, ->
  console.log "Your app is running on #{PORT}"

getInvitedUserToken = (request) ->
  if request.query.token
    token = "?token=#{request.query.token}"
  else
    token = ""

getEmail = (request) ->
  if request.query.email
    email = request.query.email
  else
    email = ''

displayIndex = (request, response) ->
  token = getInvitedUserToken(request)
  email = getEmail(request) # if request.query.email then request.query.email else ""
  response.render 'index',
    title: 'Glitch - The community where you\'ll build the app of your dreams'
    email: email
    token: token
    communityProjects: "https://glitch.com/community/"

# ROUTES

# Only routes under /about/* and /legal/* will appear at https://glitch.com/about/, etc.

app.head '/', (request, response) ->
  console.log "#{request.method} /"
  console.log request.headers

  response.write("OK")
  response.send()

app.get '/', (request, response) ->
  console.log "#{request.method}  /"
  console.log request.headers
  displayIndex(request, response)

app.get '/about', (request, response) ->
  console.log "#{request.method}  /about"
  console.log request.headers
  displayIndex(request, response)

app.get '/legal', (request, response) ->
  response.render 'legal',
    title: 'Glitch – The Fine Print'

app.get '/faq', (request, response) ->
  response.render 'faq',
    title: 'Glitch – Frequently Asked Questions'
    
app.get '/partners', (request, response) ->
  response.render 'partners',
    title: 'Glitch For Platforms – Help developers succeed with your API or SDK'
    
app.get '/foryourapi', (request, response) ->
  response.render 'partners',
    title: 'Glitch For Platforms – Help developers succeed with your API or SDK'

app.get '/forplatforms', (request, response) ->
  response.render 'partners',
    title: 'Glitch For Platforms – Help developers succeed with your API or SDK'

app.get '/foreducation', (request, response) ->
  response.render 'education',
    title: 'Glitch For Education – Succeed with teaching folks to code'
  
app.get '/foropensource', (request, response) ->
  response.render 'opensource',
    title: 'Glitch For Open Source – Scale your project, without the overhead'
    
app.post '/email-sales', (req, res) ->
  form = req.body
  console.log form
  name = form[0].val
  company = form[1].val
  email = form[2].val
  phone = form[3].val

  closeIo.getLead(email).then (responseJson) ->
    lead = responseJson.data[0]
    if lead
      console.log '🕵 lead exists'
      opportunities = lead.opportunities
      if closeIo.leadHasOpportunity opportunities
        console.log '🙅 entry already exists do nothing'
        closeIo.sendSuccess res
      else
        console.log '👼 add opportunity to existing lead'
        leadId = lead.id
        console.log 'leadId', leadId
        closeIo.newOpportunity(leadId).then (response) ->
          console.log 'new opp response', response
          closeIo.sendSuccess res
    else
      console.log '👑 the lead is new, make a lead and opportunity'
      closeIo.newLead(name, company, phone, email).then (responseJson) ->
        leadId = responseJson.id
        console.log 'leadId', leadId
        closeIo.newOpportunity(leadId).then (response) ->
          console.log 'new opp response', response
          closeIo.sendSuccess res

  .catch (error) ->
    console.error error

# Must be after other routes
# Handle 404
app.use (req, res) ->
  res.status(404)
  res.sendfile('public/404.html')
