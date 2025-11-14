# Transboard

A web application for collaborative translation of PO (Portable Object) localization files. Written in Ruby using Sinatra.

## Features

- Upload and manage translation projects
- Collaborative translation with voting system
- Support for multiple languages
- Project visibility controls (public/private)
- User authentication and access management
- Export translations as PO files

## Prerequisites

- Ruby 3.2.0 (automatically detected from `.ruby-version`)
- MongoDB
- Bundler

## Quick Start

```bash
# Install dependencies
bundle install

# Copy environment configuration
cp .env.example .env

# Edit .env with your settings
nano .env

# Start MongoDB (if not running)
mongod

# Run the application
bundle exec ruby transboard.rb
```

The application will be available at `http://localhost:4567`

## Development

### Dependencies

This project uses modern dependency management with Bundler. See [DEPENDENCIES.md](DEPENDENCIES.md) for detailed information.

```bash
# Install dependencies
rake deps:install

# Run security audit
rake deps:audit

# Check code quality
rake lint:check
```

### Available Rake Tasks

```bash
# View all tasks
rake -T

# Update translation files
rake updatepo

# Dependency management
rake deps:install    # Install dependencies
rake deps:update     # Update dependencies
rake deps:audit      # Security audit
rake deps:outdated   # Check for updates

# Code quality
rake lint:check      # Run RuboCop
rake lint:fix        # Auto-fix issues
```

## Technology Stack

- **Framework**: Sinatra 4.x
- **Database**: MongoDB with MongoMapper ORM
- **Templates**: HAML
- **I18n**: GetText and Fast GetText
- **Server**: Puma
- **Testing**: Minitest with SimpleCov

## Documentation

- [Dependency Management](DEPENDENCIES.md) - Modern dependency management guide
- [Environment Configuration](.env.example) - Configuration template

## License

See the repository for license information.
