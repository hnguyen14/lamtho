_ = require('underscore')._
db = require '../config/cradle'
truyenkieu = require('../training/truyenkieu').text

a = [ 'à' , 'á' , 'ã' , 'ả' , 'ạ' , 'ă' , 'ằ' , 'ắ' , 'ẵ' , 'ă ̉' , 'ặ' , 'â' , 'ầ' , 'ấ' , 'ẫ' , 'ẩ' , 'ậ']
e = [ 'è' , 'é' , 'ẽ' , 'ẻ' , 'ẹ' , 'ê' , 'ề' , 'ế' , 'ễ' , 'ể' , 'ệ']
i = [ 'ì' , 'í' , 'ĩ' , 'ỉ' , 'ị']
o = [ 'ò' , 'ó' , 'õ' , 'ỏ' , 'ọ' , 'ô' , 'ồ' , 'ố' , 'ỗ' , 'ổ' , 'ộ' , 'ơ' , 'ờ' , 'ớ' , 'ỡ' , 'ở' , 'ợ']
u = [ 'ù' , 'ú' , 'ũ' , 'ủ' , 'ụ' , 'ư' , 'ừ' , 'ứ' , 'ữ' , 'ử' , 'ự']
y = [ 'ỳ' , 'ý' , 'ỹ' , 'ỷ' , 'ỵ']

trac = ['á' , 'ã' , 'ả' , 'ạ' , 'ắ' , 'ẵ' , 'ă ̉' , 'ặ' , 'ấ' , 'ẫ' , 'ẩ' , 'ậ' , 'é' , 'ẽ' , 'ẻ' , 'ẹ' , 'ế' , 'ễ' , 'ể' , 'ệ' , 'í' , 'ĩ' , 'ỉ' , 'ị' , 'ó' , 'õ' , 'ỏ' , 'ọ' , 'ố' , 'ỗ' , 'ổ' , 'ộ' , 'ớ' , 'ỡ' , 'ở' , 'ợ' , 'ú' , 'ũ' , 'ủ' , 'ụ' , 'ứ' , 'ữ' , 'ử' , 'ự' , 'ý' , 'ỹ' , 'ỷ' , 'ỵ']

Classifier = 
  eval: (word, cb) ->
    return cb 'Not a word' unless word.trim().length
    result =
      word : word.toLowerCase()
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

    cb null, result

  loadTraining: (cb) ->
    for line in truyenkieu
      words = line.split(/[\s,\(,\),\[,\],\\,\/,|,\+,!,\?,&,",\-,_,\.,:,;]/)
      console.log 'words', words
      for word in words
        Classifier.eval word, (err, result) -> console.log result

module.exports = Classifier
