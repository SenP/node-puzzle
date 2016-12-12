assert = require 'assert'
WordCount = require '../lib'
fs = require 'fs'

helper = (input, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input
  counter.end()


describe '10-word-count', ->

  describe 'base tests', ->
    it 'should count a single word', (done) ->
      input = 'test'
      expected = words: 1, lines: 1, chars: 4, bytes: 4
      helper input, expected, done

    it 'should count words in a phrase', (done) ->
      input = 'this is a basic test'
      expected = words: 5, lines: 1, chars: 20, bytes: 20
      helper input, expected, done

    it 'should count quoted characters as a single word', (done) ->
      input = '"this is one word!"'
      expected = words: 1, lines: 1, chars: 19, bytes: 19
      helper input, expected, done

  # !!!!!
  # Make the above tests pass and add more tests!
  # !!!!!
  describe 'additional tests', ->
    it 'should count quoted characters as a single word when mixed with non-quoted words', (done) ->
      input = '"this is one word!" but this is not'
      expected = words: 5, lines: 1, chars:35, bytes:35
      helper input, expected, done

    it 'should ignore words containing non-alphanumeric characters', (done) ->
        input = 'this test has in-vaid _words'
        expected = words: 3, lines: 1, chars:28, bytes:28
        helper input, expected, done

    it 'should count quoted words containing non-alphanumeric characters', (done) ->
        input = 'this test has "inval_id words" like "$dollar"'
        expected = words: 6, lines: 1, chars:45, bytes:45
        helper input, expected, done

    it 'should count camelcased word as multiple words', (done) ->
        input = 'CamelCasedWords'
        expected = words: 3, lines: 1, chars:15, bytes:15
        helper input, expected, done   
  
  # Test provided fixtures
  # ----------------------
  describe 'fixture tests', ->
    # Fixture 1,9,44
    it 'should count lines, words and characters for fixture 1,9,44', (done) ->
        fs.readFile 'test/fixtures/1,9,44.txt','utf8', (err, input) ->
          expected = words: 9, lines: 1, chars:45, bytes:45
          helper input, expected, done

    # Fixture 3,7,46
    it 'should count lines, words and characters for fixture 3,7,46', (done) ->
        fs.readFile 'test/fixtures/3,7,46.txt','utf8', (err, input) ->
          expected = words: 7, lines: 3, chars:49, bytes:49
          helper input, expected, done

    # Fixture 5,9,40
    it 'should count lines, words and characters for fixture 5,9,40', (done) ->
        fs.readFile 'test/fixtures/5,9,40.txt','utf8', (err, input) ->
          expected = words: 9, lines: 5, chars:45, bytes:45
          helper input, expected, done

  # Edge cases
  # ----------

  describe 'edge cases', ->
    it 'should count empty input correctly', (done) ->
        input = ''
        expected = words: 0, lines: 0, chars:0, bytes:0
        helper input, expected, done

    it 'should ignore empty lines', (done) ->
        input = '\n \n test1 \n test2 \n\n'
        expected = words: 2, lines: 2, chars:20, bytes:20
        helper input, expected, done

    it 'should count camelcased word as single word if in quotes', (done) ->
        input = 'this is a test for "CamelCasedWords" in quotes'
        expected = words: 8, lines: 1, chars:46, bytes:46
        helper input, expected, done

    it 'should count camelcased word starting with lowercase', (done) ->
        input = 'test for camelCasedWord'
        expected = words: 5, lines: 1, chars:23, bytes:23
        helper input, expected, done
    
    it 'should count camelcased word with continuous uppercase letters correctly', (done) ->
        input = 'test for camelID'
        expected = words: 4, lines: 1, chars:16, bytes:16
        helper input, expected, done
    
    it 'should count phrases having uneven spaces correctly', (done) ->
        input = ' test for   words    with uneven spacing  '
        expected = words: 6, lines: 1, chars:42, bytes:42
        helper input, expected, done

    it 'should not count words having unmatched double quotes', (done) ->
        input = 'test for words with "unmatched quotes'
        expected = words: 5, lines: 1, chars:37, bytes:37
        helper input, expected, done

    it 'should ignore nested quotes within quoted words', (done) ->
        input = 'test for "quoted words with ""nested quotes"" "'
        expected = words: 3, lines: 1, chars:47, bytes:47
        helper input, expected, done

    it 'should count correctly provided only invalid words as input', (done) ->
        input = '1.test _bad$ input!'
        expected = words: 0, lines: 0, chars:19, bytes:19
        helper input, expected, done