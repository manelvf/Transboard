
# database

conn = Mongo::Connection.new("localhost")
database = 'transboarddb'

MongoMapper.connection = conn 
MongoMapper.database = database
$db = conn.db(database)

