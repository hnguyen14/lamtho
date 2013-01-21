_ = require('underscore')._
db = require '../config/cradle'
truyenkieu = require('../training/truyenkieu').text

a = [ 'à' , 'á' , 'ã' , 'ả' , 'ạ' , 'ă' , 'ằ' , 'ắ' , 'ẵ' , 'ă ̉' , 'ặ' , 'â' , 'ầ' , 'ấ' , 'ẫ' , 'ẩ' , 'ậ' , 'ă' , 'ắ' , 'ằ' , 'ẳ' , 'ẵ' , 'ặ' ]
e = [ 'è' , 'é' , 'ẽ' , 'ẻ' , 'ẹ' , 'ê' , 'ề' , 'ế' , 'ễ' , 'ể' , 'ệ']
i = [ 'ì' , 'í' , 'ĩ' , 'ỉ' , 'ị']
o = [ 'ò' , 'ó' , 'õ' , 'ỏ' , 'ọ' , 'ô' , 'ồ' , 'ố' , 'ỗ' , 'ổ' , 'ộ' , 'ơ' , 'ờ' , 'ớ' , 'ỡ' , 'ở' , 'ợ']
u = [ 'ù' , 'ú' , 'ũ' , 'ủ' , 'ụ' , 'ư' , 'ừ' , 'ứ' , 'ữ' , 'ử' , 'ự']
y = [ 'ỳ' , 'ý' , 'ỹ' , 'ỷ' , 'ỵ']

trac = ['á' , 'ã' , 'ả' , 'ạ' , 'ắ' , 'ẵ' , 'ă ̉' , 'ặ' , 'ấ' , 'ẫ' , 'ẩ' , 'ậ' , 'é' , 'ẽ' , 'ẻ' , 'ẹ' , 'ế' , 'ễ' , 'ể' , 'ệ' , 'í' , 'ĩ' , 'ỉ' , 'ị' , 'ó' , 'õ' , 'ỏ' , 'ọ' , 'ố' , 'ỗ' , 'ổ' , 'ộ' , 'ớ' , 'ỡ' , 'ở' , 'ợ' , 'ú' , 'ũ' , 'ủ' , 'ụ' , 'ứ' , 'ữ' , 'ử' , 'ự' , 'ý' , 'ỹ' , 'ỷ' , 'ỵ']

Training = 
  eval: (word) ->
    return null unless word.trim().length
    result =
      word : word.toLowerCase()
      prevWords: {}
    #bang trac
    chars = word.toLowerCase().split('')
    ints = _.intersection chars, trac
    if ints.length
      result.bangtrac = 'trac'
    else
      result.bangtrac = 'bang'
    #normalize
    for char,idx in chars
      if a.indexOf(char) > -1
        chars[idx] = 'a'
      else if e.indexOf(char) > -1
        chars[idx] = 'e'
      else if i.indexOf(char) > -1
        chars[idx] = 'i'
      else if o.indexOf(char) > -1
        chars[idx] = 'o'
      else if u.indexOf(char) > -1
        chars[idx] = 'u'
      else if y.indexOf(char) > -1
        chars[idx] = 'y'

    result.normalized = ''
    result.normalized = result.normalized + char for char in chars

    #am
    for char,idx in chars
      if char == 'a' || char == 'e' || char == 'i' || char == 'o' || char == 'u' || char == 'y'
        result.am = result.normalized.substring idx, word.length
        break

    result

  loadTraining: (cb) ->
    db.destroy () ->
      db.create (err) ->
        return cb err if err
        results = {}
        for line in truyenkieu
          words = line.split(/[\s,\(,\),\[,\],\\,\/,|,\+,!,\?,&,",\-,_,\.,:,;]/)
          for word in words
            result = Training.eval word
            if result
              result.prevWords[prevWord] = 1
              if results[result.word]
                prevCount = results[result.word].prevWords[prevWord]
                if prevCount
                  results[result.word].prevWords[prevWord] = prevCount + 1
                else
                  results[result.word].prevWords[prevWord] = 1
              else
                results[result.word] = result
              prevWord = result.word
        for key of results
          db.save results[key]
        cb()

module.exports = Training
