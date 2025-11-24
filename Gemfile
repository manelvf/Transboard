# frozen_string_literal: true

source 'https://rubygems.org'

# Specify Ruby version for rbenv, rvm, and deployment platforms
ruby '>= 3.2.0'

# ============================================================================
# Core Application Dependencies
# ============================================================================

# Web Framework
gem 'sinatra', '~> 4.0'              # Lightweight web framework
gem 'sinatra-contrib', '~> 4.0'     # Sinatra extensions (includes reloader)
gem 'sinatra-flash', '~> 0.3'       # Flash messages for user feedback
gem 'rackup', '~> 2.1'               # Rack server (required for Sinatra 4.x)

# Authentication & Authorization
gem 'sinatra-authentication', '~> 0.4'  # User authentication system

# Template Engine
gem 'haml', '~> 7.0'                 # HTML abstraction markup language

# Database
gem 'mongo', '~> 2.20'               # MongoDB driver
gem 'mongo_mapper', '~> 0.15'       # MongoDB ORM/ODM
gem 'bson', '~> 5.0'                 # BSON serialization format

# Internationalization
gem 'gettext', '~> 3.4'              # i18n and localization
gem 'fast_gettext', '~> 4.1'        # Performance-optimized gettext

# Email
gem 'pony', '~> 1.13'                # Simple email sending

# Web Server
gem 'puma', '~> 7.1'                 # Modern, concurrent web server

# ============================================================================
# Development Dependencies
# ============================================================================
group :development do
  gem 'rerun', '~> 0.14'             # Auto-restart app on file changes
  gem 'rubocop', '~> 1.60', require: false  # Ruby style guide and linter
  gem 'rubocop-performance', '~> 1.20', require: false  # Performance linting
end

# ============================================================================
# Test Dependencies
# ============================================================================
group :test do
  gem 'rack-test', '~> 2.1'          # Testing rack applications
  gem 'minitest', '~> 5.26'          # Testing framework
  gem 'simplecov', '~> 0.22', require: false  # Code coverage analysis
end

# ============================================================================
# Development & Test Dependencies
# ============================================================================
group :development, :test do
  gem 'rake', '~> 13.1'              # Task automation
  gem 'bundler-audit', '~> 0.9'     # Security vulnerability scanner
  gem 'dotenv', '~> 3.0'             # Environment variable management
end
