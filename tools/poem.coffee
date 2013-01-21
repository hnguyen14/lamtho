async = require 'async'
db = require '../config/cradle'
intonation = ['bang', 'trac', 'trac', 'bang', 'bang', 'trac', 'bang']

Poem =
  findNextWord: (bangtrac, prevWord, am, cb) ->
    startKey = [bangtrac, prevWord, {}, {}]
    endKey = [bangtrac, prevWord]
    if am
      startKey = [bangtrac, prevWord, am, {}]
      endKey = [bangtrac, prevWord, am]

    db.view 'Word/look_up',
      descending: true
      limit : 30
      include_docs: true
      startkey: startKey
      endkey: endKey
    , (err, res) ->
      if res.length == 0
        Poem.getStartWord bangtrac, cb
      else
        cb res[Math.floor(Math.random() * res.length)].doc

  getStartWord: (bangtrac, cb) ->
    db.view 'Word/look_up',
      descending: true
      limit: 300
      include_docs: true
      startkey : [bangtrac, {}, {}, {}]
      endkey: [bangtrac]
    , (err, res) ->
      cb res[Math.floor(Math.random() * res.length)].doc


  genLine: (count, am, cb) ->
    Poem.getStartWord 'bang', (startWord) ->
      idx = 0
      sentence = [startWord.word]
      functions = [
        (cb) ->
          Poem.findNextWord intonation[idx], startWord.word, am, (nextWord) ->
            sentence.push nextWord.word
            idx++
            cb null, nextWord
      ]
      for i in [0..(count-3)]
        if am && count == 8 && i == 3
          functions.push (word, cb) ->
            Poem.findNextWord intonation[idx], word.word, am,  (nextWord) ->
              sentence.push nextWord.word
              idx++
              cb null, nextWord
        else
          functions.push (word,cb) ->
            Poem.findNextWord intonation[idx], word.word, null,  (nextWord) ->
              sentence.push nextWord.word
              idx++
              cb null, nextWord

      async.waterfall functions, (err, finalWord) ->
        cb 
          sentence: sentence.join ' '
          am: finalWord.am

  gen: (cb) ->
    poem = []
    idx = 0
    functions = []
    for i in [0..4]
      functions.push (cb) ->
        Poem.genLine 6, null, (result) ->
          console.log result.sentence
          poem.push result.sentence
          idx++
          cb null, result.am
      functions.push (am, cb) ->
        Poem.genLine 8, am, (result) ->
          poem.push result.sentence
          idx++
          cb()
    async.waterfall functions, -> cb poem

module.exports = Poem
