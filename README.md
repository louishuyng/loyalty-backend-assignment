# Loyalty Backend Assignment

## Requirements

- Rails 7.0.3
- Ruby 3.1.2
- PostgreSQL

### Configuration

- Create `config/application.yml` by copying from `config/application.yml.example` and make any change appropriate to your setup.

---

### Setup Git hooks:

```bash
pnpm install
pnpm run prepare
```

---

### Installation

#### 1. Install gem dependencies

```
$ bundle install
```

#### 2. Setup Database

```
$ rake db:setup && rake db:migrate
```

#### 3. Run database seeding

> It will generate initial data
>
> - 3 basic rewards

```
$ bundle exec rake db:seed
```

---

### Running Project

#### Start Dev GRPC Server

```
$ bundle exec gruf
```

---

### Lint & Testing

#### Check Lint

```
$ bundle exec rubocop
```

#### Run Unit Test

```
$ bundle exec rspec
```
