cradle = require 'cradle'
url = require 'url'

database = process.env.DATABASE || 'tho'
environment = process.env.ENV || 'development'
database += "_#{environment}" unless process.env.ENV == 'production'

cloudantUrl = process.env.CLOUDANT_URL || "http://localhost:5984/#{database}"
cloudant = url.parse cloudantUrl
options = {}
options.host = "#{cloudant.protocol}//#{cloudant.hostname}"
options.port = cloudant.port || if 'https:' == cloudant.protocol then 443 else 80
if cloudant.auth
  options.auth =
    username: cloudant.auth.split(':')[0]
    password: cloudant.auth.split(':')[1]

server = new (cradle.Connection)(options)

db = server.database database

module.exports = db
