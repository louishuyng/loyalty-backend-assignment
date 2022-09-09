# Loyalty Backend Assignment

## Requirements

- Rails 7.0.3
- Ruby 3.1.2
- PostgreSQL

### Configuration

- Create `config/application.yml` by copying from `config/application.yml.example` and make any change appropriate to your setup.

### Setup Git hooks:

```bash
pnpm install
pnpm run prepare
```

### Installation

Inside project root folder, execute:

```
$ bundle
```

Database creation:

```
$ rake db:setup
```

Run migrations:

```
$ rake db:migrate
```

### Run Rubocop

```
$ bundle exec ubocop
```

or

```
$ rubocop
```

### Run Rspec

```
$ bundle exec rspec
```
