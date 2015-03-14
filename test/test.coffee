# ids = ["548980a875d85914249792d4", "548980a975d85914249792d5", "548980a975d85914249792d6"]
# User = require('../proxy').User

# User.find {_id: $in: []}, (err, users)->
#     if err then throw err
#     else console.log users

ReactiveData = require('../proxy').ReactiveData

doc1 = 
	data: 
		album: 'good'
	to: "54c49569df9674701a45c03c"
	create_at: new Date('2015-02-01')

# doc2 = 
# 	data: 
# 		album: 'better'
# 	to: "54c49569df9674701a45c03c"
# 	create_at: new Date('2015-01-11')

# doc3 = 
# 	data: 
# 		album: 'best'
# 	to: "54c49569df9674701a45c03c"
# 	create_at: new Date('2015-11-01')

ReactiveData.insert doc1, (err, doc)->
	if err then throw err

	console.log doc

# ReactiveData.insert doc2, (err, doc)->
# 	if err then throw err

# 	console.log doc

# ReactiveData.insert doc3, (err, doc)->
# 	if err then throw err

# 	console.log doc
