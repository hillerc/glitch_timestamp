request = require 'request'
CLOSEIO_API_USER = process.env.CLOSEIO_API_TOKEN
HYPERDEV_OPPORTUNITY_STATUS = 'stat_POyboToK72f1PmFzIaHkKO4nmMwnD6IZWpebF1ftbM4'

path = (endpoint) ->
  "https://#{CLOSEIO_API_USER}:@app.close.io/api/v1/#{endpoint}/"


module.exports =

  getLead: (email) ->
    console.log 'getLead'
    return new Promise (resolve, reject) ->
      request
        url: path 'lead'
        qs: query: "email=#{email}"
        (error, response, responseBody) ->
          responseJson = JSON.parse responseBody
          if error
            reject Error 'get lead failed'
          else
            # console.log 'getLead', responseJson
            resolve responseJson

  newLead: (name, company, phone, email) ->
    console.log 'newLead'
    return new Promise (resolve, reject) ->
      request
        method: 'POST'
        url: path 'lead'
        body: JSON.stringify
          name: company
          contacts: [
            name: name
            emails: [
              type: 'office'
              email: email
            ]
            phones: [
              type: 'office'
              phone: phone or 'n/a'
            ]
          ]
        (error, response, responseBody) ->
          console.log responseBody
          responseJson = JSON.parse responseBody
          if error
            reject Error 'new lead failed'
          else
            console.log 'newLead', responseJson
            resolve responseJson

  newOpportunity: (leadId) ->
    console.log 'leadId in new opp', leadId
    console.log 'HYPERDEV_OPPORTUNITY_STATUS', HYPERDEV_OPPORTUNITY_STATUS
    return new Promise (resolve, reject) ->
      request
        method: 'POST'
        url: path 'opportunity'
        body: JSON.stringify
          status_id: HYPERDEV_OPPORTUNITY_STATUS
          user_id: 'user_nCiX4bqa6GcMu5JR24qkSnObLPJA8e3DqTsTnEHZ1Ed'
          lead_id: leadId
          value_period: "annual"
        (error, response, responseBody) ->
          if error
            reject Error 'new lead failed'
          else
            console.log 'newOpportunity', responseBody
            resolve responseBody


  leadHasOpportunity: (opportunities) ->
    leadHasOpportunity = false
    for opportunity in opportunities
      if opportunity.status_id is HYPERDEV_OPPORTUNITY_STATUS
        leadHasOpportunity = true
    leadHasOpportunity

  sendSuccess: (res) ->
    console.log '🌺 sendSuccess'
    res.send 200
