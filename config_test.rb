# frozen_string_literal: true

# Test database configuration for MongoDB

# Modern Mongo client API (2.x+)
client = Mongo::Client.new(['localhost:27017'], database: 'transboarddb_test')

# MongoMapper configuration
MongoMapper.connection = client
MongoMapper.database = 'transboarddb_test'

# Legacy $db variable for compatibility
$db = client.database
