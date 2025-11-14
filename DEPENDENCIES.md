# Dependency Management

This document describes the modern dependency management system implemented for Transboard.

## Overview

Transboard now uses modern Ruby dependency management practices with Bundler, semantic versioning, and automated security auditing.

## Key Files

### Core Dependency Files

- **`.ruby-version`** - Specifies Ruby 3.2.0 for version managers (rbenv, rvm, chruby)
- **`Gemfile`** - Defines all gem dependencies with semantic versioning
- **`Gemfile.lock`** - Locks exact versions for reproducible builds (tracked in git)
- **`.bundle/config`** - Bundler configuration for local development

### Configuration Files

- **`.env.example`** - Template for environment-specific configuration
- **`.rubocop.yml`** - Code style and quality rules
- **`rakefile`** - Automated tasks for dependency and code management

## Quick Start

### Initial Setup

```bash
# Install the correct Ruby version (using rbenv, rvm, or chruby)
# The .ruby-version file will be automatically detected

# Install bundler
gem install bundler

# Install dependencies
bundle install
```

### Environment Configuration

```bash
# Copy the environment template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

## Dependency Groups

Dependencies are organized into logical groups:

### Production Dependencies

- **Web Framework**: Sinatra 4.x with modern extensions
- **Database**: MongoDB driver 2.x and MongoMapper ORM
- **Templates**: HAML 6.x templating engine
- **I18n**: GetText for internationalization
- **Email**: Pony for simple email sending
- **Server**: Puma as the application server

### Development Dependencies

- **rerun**: Auto-restart on file changes
- **rubocop**: Code style checking and linting
- **rubocop-performance**: Performance-focused linting

### Test Dependencies

- **rack-test**: HTTP request testing
- **minitest**: Testing framework
- **simplecov**: Code coverage analysis

### Shared Dev/Test Dependencies

- **rake**: Task automation
- **bundler-audit**: Security vulnerability scanning
- **dotenv**: Environment variable management

## Common Tasks

### Installing Dependencies

```bash
# Install all dependencies
bundle install

# Or use the rake task
rake deps:install
```

### Updating Dependencies

```bash
# Update all dependencies (respecting version constraints)
bundle update

# Update a specific gem
bundle update sinatra

# Or use rake tasks
rake deps:update
rake deps:outdated  # Check what can be updated
```

### Security Auditing

```bash
# Run security audit
rake deps:audit

# Or manually
bundle exec bundle-audit check --update
```

### Code Quality

```bash
# Check code style
rake lint:check

# Auto-fix style issues
rake lint:fix

# Or use bundler directly
bundle exec rubocop
bundle exec rubocop -a  # Auto-fix
```

### Dependency Information

```bash
# List all dependencies
bundle list

# Show dependency tree
rake deps:tree

# Check for outdated gems
rake deps:outdated
```

## Version Constraints

The Gemfile uses semantic versioning with pessimistic version constraints (`~>`):

- `~> 4.0` allows updates from 4.0 up to (but not including) 5.0
- `~> 6.3` allows updates from 6.3 up to (but not including) 7.0

This ensures:
- **Security patches** are automatically received
- **Minor updates** with new features are allowed
- **Breaking changes** are prevented

## Migration from Old System

### Key Changes

| Aspect | Old | New |
|--------|-----|-----|
| Ruby Version | Unspecified | 3.2.0 (specified in `.ruby-version`) |
| Bundler Source | `:rubygems` | `'https://rubygems.org'` |
| Version Pinning | Exact versions | Semantic versioning with `~>` |
| Gemfile.lock | Ignored | Tracked in git |
| Dependency Groups | None | Production, Development, Test |
| Security Scanning | None | Automated with bundler-audit |
| Code Quality | None | RuboCop with performance checks |

### Updated Gem Versions

| Gem | Old Version | New Version |
|-----|-------------|-------------|
| sinatra | 1.3.2 | ~> 4.0 |
| haml | 3.1.5 | ~> 6.3 |
| mongo | 1.6.2 | ~> 2.20 |
| mongo_mapper | 0.11.1 | ~> 0.15 |
| gettext | 2.2.0 | ~> 3.4 |
| fast_gettext | 0.6.7 | ~> 2.3 |
| pony | 1.4 | ~> 1.13 |
| bson | 1.6.2 | ~> 5.0 |

**Removed**:
- `bson_ext` - No longer needed in modern versions

**Added**:
- `sinatra-contrib` - Replaces sinatra-reloader with more features
- `rackup` - Required for Sinatra 4.x
- `puma` - Modern web server
- Development/test gems for quality and security

## Best Practices

### Always Track Gemfile.lock

The `Gemfile.lock` ensures all developers and deployments use identical gem versions:

```bash
# After adding/updating gems
git add Gemfile Gemfile.lock
git commit -m "Update dependencies"
```

### Regular Security Audits

Run security audits regularly:

```bash
# Weekly or before deployments
rake deps:audit
```

### Keep Dependencies Updated

Update dependencies monthly or when security issues are announced:

```bash
# Check for updates
rake deps:outdated

# Review and update
bundle update
rake deps:audit
```

### Use Bundler Exec

Always run gems through bundler to use the correct versions:

```bash
bundle exec ruby transboard.rb
bundle exec rake deps:audit
bundle exec rubocop
```

## Troubleshooting

### Installation Issues

If you encounter installation errors:

```bash
# Clean and reinstall
rake deps:clean
rm -rf vendor/bundle
bundle install
```

### Version Conflicts

If gems have version conflicts:

```bash
# Check dependency tree
rake deps:tree

# Update specific gem
bundle update problem-gem-name
```

### MongoDB Driver Issues

If you have MongoDB connection issues after upgrading:

1. Ensure MongoDB server is running
2. Check connection string in `config.rb` or `.env`
3. Verify MongoDB driver compatibility with your server version

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Install dependencies
  run: bundle install --jobs 4 --retry 3

- name: Security audit
  run: bundle exec bundle-audit check --update

- name: Run tests
  run: bundle exec rake test
```

## Additional Resources

- [Bundler Documentation](https://bundler.io/docs.html)
- [RuboCop Documentation](https://docs.rubocop.org/)
- [Bundler Audit](https://github.com/rubysec/bundler-audit)
- [Semantic Versioning](https://semver.org/)

## Support

For issues with dependency management:

1. Check this documentation
2. Review `Gemfile` comments
3. Run `bundle install --verbose` for detailed output
4. Check the [Transboard repository](https://github.com/manelvf/Transboard) for updates
