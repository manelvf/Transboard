# frozen_string_literal: true

# Database configuration for MongoDB

# Modern Mongo client API (2.x+)
client = Mongo::Client.new(['localhost:27017'], database: 'transboarddb')

# MongoMapper configuration
MongoMapper.connection = client
MongoMapper.database = 'transboarddb'

# Legacy $db variable for compatibility
$db = client.database

