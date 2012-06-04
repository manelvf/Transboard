
conn = Mongo::Connection.new("localhost")
database = 'transboarddb_test'

MongoMapper.connection = conn 
MongoMapper.database = database
$db = conn.db(database)
