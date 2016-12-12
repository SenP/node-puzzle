fs = require 'fs'
readline = require 'readline'
stream = require 'stream'

exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  readStream = fs.createReadStream('#{__dirname}/../data/geo.txt')
  writeStream = new stream
  rl = readline.createInterface(readStream, writeStream)
  counter = 0

  rl.on('line', (line) -> 
    line = line.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    # line[0],       line[1],       line[3]
    if line[3] == countryCode then counter += +line[1] - +line[0]
  )

  rl.on('close', ->
    cb null, counter
  )
