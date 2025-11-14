# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Modern Dependency Management System

#### Dependency Management
- Ruby version specification (`.ruby-version`) for Ruby 3.2.0
- Modern `Gemfile` with semantic versioning using `~>` constraints
- Dependency groups (production, development, test)
- `Gemfile.lock` now tracked in version control for reproducible builds
- Bundler configuration (`.bundle/config`) for consistent local setup
- Environment variable management with `.env.example` template
- `DEPENDENCIES.md` comprehensive documentation

#### Updated Dependencies
- **sinatra**: 1.3.2 → 4.0 (major version upgrade)
- **haml**: 3.1.5 → 6.3 (major version upgrade)
- **mongo**: 1.6.2 → 2.20 (major version upgrade)
- **mongo_mapper**: 0.11.1 → 0.15
- **gettext**: 2.2.0 → 3.4 (major version upgrade)
- **fast_gettext**: 0.6.7 → 2.3 (major version upgrade)
- **pony**: 1.4 → 1.13
- **bson**: 1.6.2 → 5.0 (major version upgrade)

#### New Dependencies
- **sinatra-contrib**: Replaces standalone sinatra-reloader with full extension suite
- **rackup**: Required for Sinatra 4.x
- **puma**: Modern, concurrent web server
- **rake**: Task automation
- **bundler-audit**: Security vulnerability scanning
- **dotenv**: Environment variable management
- **rubocop**: Code style and linting
- **rubocop-performance**: Performance-focused linting
- **rack-test**: HTTP testing utilities
- **minitest**: Testing framework
- **simplecov**: Code coverage analysis
- **rerun**: Development auto-reload

#### Removed Dependencies
- **bson_ext**: No longer needed in modern BSON versions

#### Automation & CI/CD
- Enhanced `rakefile` with dependency management tasks:
  - `rake deps:install` - Install dependencies
  - `rake deps:update` - Update dependencies
  - `rake deps:outdated` - Check for outdated gems
  - `rake deps:audit` - Security vulnerability scanning
  - `rake deps:clean` - Clean unused dependencies
  - `rake deps:tree` - Show dependency tree
- Code quality tasks:
  - `rake lint:check` - Run RuboCop checks
  - `rake lint:fix` - Auto-fix style violations
- GitHub Actions CI workflow (`.github/workflows/ci.yml`):
  - Automated security audits
  - Code quality checks with RuboCop
  - Test suite execution with MongoDB
  - Weekly scheduled security scans
- Dependabot configuration (`.github/dependabot.yml`):
  - Weekly dependency update checks
  - Automated pull requests for updates
  - Grouped minor/patch updates

#### Code Quality
- RuboCop configuration (`.rubocop.yml`) with:
  - Ruby 3.2 target version
  - Performance checks enabled
  - Security checks enabled
  - Sensible defaults for Sinatra projects
  - Excluded vendor and generated directories

#### Documentation
- `DEPENDENCIES.md` - Comprehensive dependency management guide
- Updated `README.md` with quick start and development instructions
- `CHANGELOG.md` - Project changelog
- Inline comments in `Gemfile` for clarity

#### Configuration
- `.env.example` - Template for environment variables:
  - Application settings
  - MongoDB configuration
  - Email/SMTP settings
  - Development/production toggles
- Updated `.gitignore`:
  - Track `Gemfile.lock`
  - Ignore `.env` files
  - Ignore coverage reports
  - Ignore vendor bundles

### Changed
- Gemfile source updated from `:rubygems` to `'https://rubygems.org'`
- Version constraints changed from exact pins to semantic versioning
- Rakefile formatted and enhanced with modern Ruby style

### Improved
- **Security**: Automated vulnerability scanning with bundler-audit
- **Reproducibility**: Gemfile.lock ensures identical dependencies across environments
- **Maintainability**: Semantic versioning allows safe automatic updates
- **Developer Experience**: Clear documentation and automated tasks
- **Code Quality**: Automated linting and style checking
- **CI/CD**: Automated testing and security scanning

## Migration Notes

For existing installations:

```bash
# Install bundler if needed
gem install bundler

# Install dependencies
bundle install

# Copy environment template
cp .env.example .env

# Edit configuration
nano .env

# Run security audit
rake deps:audit

# Check code style
rake lint:check
```

---

## [Legacy] - Pre-2025

### Original Stack
- Ruby (version unspecified)
- Sinatra 1.3.2
- MongoDB with MongoMapper
- GetText for i18n
- Basic Gemfile with exact version pins
