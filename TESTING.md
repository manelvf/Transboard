# Testing Guide

This document provides comprehensive information about the test suite for Transboard.

## Overview

Transboard uses **Minitest** as its testing framework with **SimpleCov** for code coverage analysis. The test suite is organized into three main categories:

1. **Model Tests** - Testing database models and the Model module
2. **Upload Tests** - Testing file upload and PO file parsing functionality
3. **Route Tests** - Integration tests for HTTP endpoints

## Quick Start

```bash
# Run all tests
rake test

# Run specific test suites
rake test_models     # Model tests only
rake test_upload     # Upload tests only
rake test_routes     # Route/integration tests only

# Run tests with coverage report
rake test:coverage

# Clean test database
rake test:clean
```

## Prerequisites

### MongoDB

Tests require a running MongoDB instance:

```bash
# Start MongoDB
mongod

# Or using Docker
docker run -d -p 27017:27017 --name mongodb mongo:6.0
```

### Test Database

Tests use a separate database `transboarddb_test` to avoid conflicts with development data. The database is automatically cleaned before and after each test.

## Test Structure

```
test/
├── test_helper.rb      # Shared test configuration and helpers
├── models_test.rb      # Model and database tests
├── upload_test.rb      # File upload and parsing tests
└── routes_test.rb      # HTTP endpoint integration tests
```

## Test Helper

`test/test_helper.rb` provides:

- **SimpleCov configuration** for code coverage
- **Test database setup** with MongoDB
- **Helper methods** for creating test data
- **Base test class** with common functionality

### Available Helper Methods

```ruby
# User management
create_test_user(email: 'test@example.com', password: 'password123')

# Database cleanup
clean_database

# Test data creation
create_test_document(author_id, overrides = {})
create_test_line(msgid = 'Hello', msgstr = 'Hola')
create_test_proposal(author_id, msgstr = 'Translation')
create_test_vote(author_id)
create_test_collaboration(author_id, status = 'pending')

# File mocking
mock_po_file(content)
sample_po_content      # Returns sample PO file content
empty_po_content       # Returns empty PO file content
```

## Test Coverage

### Model Tests (`models_test.rb`)

Tests for MongoMapper models and the Model module:

- **DocumentModelTest**
  - Document creation and validation
  - Required fields (name, authorId, etc.)
  - Relationships (lines, collaborations)
  - Timestamps

- **LineModelTest**
  - Line creation
  - Proposal relationships
  - Multiple proposals per line

- **ProposalModelTest**
  - Proposal creation
  - Vote relationships
  - Timestamps

- **VoteModelTest**
  - Vote creation
  - Timestamps

- **CollaborationModelTest**
  - Collaboration creation
  - Status options (pending, accepted, admin, blocked)
  - Timestamps

- **ModelModuleTest**
  - `createDocument` method
  - `appendLine` method
  - `getDocument` method
  - `getDocumentList` method
  - `deleteAllDocuments` method
  - Visibility conversion (public/private)

### Upload Tests (`upload_test.rb`)

Tests for file upload and PO file parsing:

- **PO File Parsing**
  - `getMsgid` with valid/invalid input
  - `getMsgstr` with valid/invalid input
  - Special character handling
  - Empty strings
  - Format validation

- **File Upload**
  - Valid PO file upload
  - Empty file handling
  - Multiple translations
  - Incomplete msgid/msgstr pairs
  - Public/private project creation
  - Line counting accuracy

### Route Tests (`routes_test.rb`)

Integration tests for HTTP endpoints:

- **RoutesTest**
  - `GET /` - Index page
  - `GET /about` - About page
  - `GET /create_new_project` - Project creation form
  - `POST /uploadFile` - File upload handling
  - `GET /editproject/:id` - Project editing
  - `GET /delete/:id` - Project deletion
  - `GET /dashboard` - User dashboard
  - `GET /projects` - Public projects list
  - `GET /download/:id` - PO file download

- **ProposalVoteRoutesTest**
  - `POST /addline` - Add translation proposal
  - `POST /vote` - Vote on proposal
  - Duplicate vote prevention

- **CollaborationRoutesTest**
  - `GET /askcollaborate/:id` - Request collaboration
  - `GET /projectoptions/:id` - Project options page
  - `POST /changestatus` - Change collaborator status
  - Duplicate collaboration prevention

## Code Coverage

SimpleCov generates a coverage report after running tests:

```bash
# Run tests with coverage
rake test

# Open coverage report
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
```

Coverage report includes:

- Overall coverage percentage
- Per-file coverage
- Line-by-line coverage visualization
- Uncovered code highlighting

### Coverage Groups

- **Models** - model.rb
- **Routes** - transboard.rb
- **Modules** - upload.rb, language_codes.rb
- **Config** - config.rb, config_test.rb

## Writing New Tests

### Model Test Example

```ruby
class MyModelTest < TransboardTestBase
  def test_model_behavior
    # Arrange
    doc = create_test_document(@test_user.id)

    # Act
    doc.name = 'New Name'
    doc.save

    # Assert
    assert_equal 'New Name', doc.name
  end
end
```

### Route Test Example

```ruby
class MyRouteTest < TransboardTestBase
  def test_route_behavior
    # Arrange
    doc = create_test_document(@test_user.id)

    # Act
    get "/myroute/#{doc.id}"

    # Assert
    assert last_response.ok?
    assert_includes last_response.body, 'Expected Content'
  end
end
```

## Continuous Integration

Tests run automatically in GitHub Actions on:

- Push to main/develop branches
- Pull requests
- Weekly schedule

See `.github/workflows/ci.yml` for CI configuration.

## Test Database Management

### Automatic Cleanup

Tests automatically clean the database:
- **Before each test** in `setup`
- **After each test** in `teardown`

### Manual Cleanup

```bash
# Clean test database
rake test:clean
```

### Database Configuration

Test database configuration is in `config_test.rb`:

```ruby
client = Mongo::Client.new(['localhost:27017'], database: 'transboarddb_test')
MongoMapper.connection = client
MongoMapper.database = 'transboarddb_test'
```

## Common Issues

### MongoDB Connection Error

**Problem**: Tests fail with "Connection refused" error

**Solution**: Start MongoDB:
```bash
mongod
# Or
sudo service mongodb start
```

### Authentication Errors

**Problem**: Tests fail with authentication errors

**Solution**: Ensure test user is created in `setup` method

### Database Not Cleaned

**Problem**: Tests fail due to leftover data

**Solution**: Run manual cleanup:
```bash
rake test:clean
```

## Best Practices

1. **Isolation** - Each test should be independent
2. **Cleanup** - Use setup/teardown to clean database
3. **Descriptive Names** - Use clear test method names
4. **Arrange-Act-Assert** - Follow AAA pattern
5. **Coverage** - Aim for high code coverage
6. **Fast Tests** - Keep tests fast by minimizing database operations
7. **Realistic Data** - Use realistic test data with helpers

## Performance

Test suite performance metrics:

- **Model Tests**: ~1-2 seconds
- **Upload Tests**: ~2-3 seconds
- **Route Tests**: ~3-5 seconds
- **Total**: ~6-10 seconds

For faster feedback during development, run specific test suites:

```bash
# Only run tests for code you're changing
rake test_models
rake test_upload
rake test_routes
```

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Maintain >80% code coverage
4. Add integration tests for new routes
5. Update this documentation

## Troubleshooting

### Verbose Output

Enable verbose test output:

```bash
bundle exec rake test TESTOPTS="-v"
```

### Run Single Test

Run a specific test method:

```bash
bundle exec ruby test/models_test.rb -n test_document_creation
```

### Debug Mode

Add debugging to tests:

```ruby
def test_something
  require 'pry'; binding.pry  # Add breakpoint
  # test code
end
```

## Resources

- [Minitest Documentation](https://github.com/minitest/minitest)
- [Rack::Test Documentation](https://github.com/rack/rack-test)
- [SimpleCov Documentation](https://github.com/simplecov-ruby/simplecov)
- [MongoMapper Documentation](http://mongomapper.com/)
