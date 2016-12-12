through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 0
  chars = 0
  bytes = 0

  transform = (chunk, encoding, cb) ->
    linesArr = chunk.split(/\n/g)
    linesArr = if linesArr then linesArr else [chunk]
    chars = chunk.length
    bytes = Buffer.byteLength(chunk, 'utf8')
    # Process each line
    for line in linesArr
      do (line) -> 
        # Count quoted words and remove them from line
        qtokens = line.match(/("[^"]*")+/g)
        wordsInLine = if qtokens then qtokens.length else 0
        cleanLine = if qtokens then line.replace(/("[^"]*")+/g, '') else line

        # Remove repeating spaces and trim spaces at start/end
        cleanLine = cleanLine.replace(/[ ]{2,}/g," ")
        cleanLine = cleanLine.replace(/(^\s*)|(\s*$)/g,"")

        # Count words    
        tokens = if cleanLine then cleanLine.split(' ') else []
        
        for t in tokens  
          do (t) -> 
            if !(/[^A-Za-z0-9]+/g.test(t))  
              t = t.replace(/([a-z])([A-Z])/g,'$1 $2')
              wordsInLine += t.split(' ').length

        words += wordsInLine
        lines += if wordsInLine then 1 else 0
    return cb()

  flush = (cb) ->
    this.push {words, lines, chars, bytes}
    this.push null
    return cb()

  return through2.obj transform, flush
