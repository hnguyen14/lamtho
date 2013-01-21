module.exports = (db) ->
  db.save '_design/Word'
    look_up:
      map: (doc) ->
        for prevWord of doc.prevWords
          emit [doc.bangtrac, prevWord, doc.am, doc.prevWords[prevWord]], _id: doc.id

  , (err, res) ->
    console.log err if err
