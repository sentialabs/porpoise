# Porpoise

## Welcome

Porpoise implements an additional cache backend for Ruby on Rails applications. It's compatible with Rails' ActiveSupport::Cache interface and is easily configured. It also provides a Redis like interface using your chosen RDBMS as its storage engine. This provides an easy replacement for Rails applications that currently use Redis to store key/value data and would like to switch an RDBMS for whatever reason.

### Performance

Redis outperforms this implementation and I don't think I have to tell why. For an SQL based solution it still performs alright though. By using a short living in-memory cache it actually comes close to a Redis based solution, at least in our setup. Besides, this thing integrates with Rails, uses ActiveRecord and all the bloat that comes with it. And although a cache should help performance, cache read/write speed sometimes are not the problem. To prevent firing the same query when reading the same cache fragment over and over again, this thing comes with a short life in-memory cache to quickly return those items. In our situation, reading data was even faster than the Redis based solution.

### Then why?

To simplify your stack? To get a real multi-master setup using MySQL/Galera? To get rid of an unstable situation? To have a centralized cache when you have no Memcache or Redis at your disposal?

This gem was written out of the need to get rid of a shaky Redis Dynomite cluster which we implemented due to the requirement of having real multi-master clusters. Master-slave- and failover setups tend to break over time, so multi-master is the only acceptable way to go.

So Redis /w Dynomite kept exploding at every little burp so we needed a solution. MySQL / Galera was already there as our primary datastore so the alternative was easily chosen. Reasons: proven multi-master setup and a less complex stack. This was a win/win solution. With our userbase and use of Redis, performance was of minor importance.

## Compatibility

This gem has been tested with Rails 3, and includes tests for Rails 4 and Rails 5.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'porpoise'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install porpoise

After installation of the gem, install the required migration:

    $ rails generate porpoise:install

Porpoise runs in a different database for easy optimization and decoupling. Add an entry in your config/database.yml for porpoise.

    porpoise_development:
        adapter: <adapter of choice>
        username: <porpoise_db_user>
        ...

Run migrations to install the required table:

    rake db:migrate

## Usage

### Caching in Rails

Using Porpoise as caching backend in Rails is easy. Change your cache store config like this:

    config.cache_store = :porpoise_store

That's all! Optionally you can set a caching namespace like this:

    config.cache_store = :porpoise_store, { namespace: :your_namespace }

Namespacing automatically preprends each cache key with the chosen namespace.

### As generic key/value storage
 
Porpoise was designed as an easy replacement for Redis. Therefore it implements various of the commonly used types Redis knows (strings, sets and hashes) and most of their functions. Access them like this:

    Porpoise::String.<redis-function-name-and-arguments>
    Porpoise::Set.<redis-function-name-and-arguments>
    Porpoise::Hash.<redis-function-name-and-arguments>

Namespacing is easy as well. Surround your Porpoise calls in a block like this example:

    Porpoise.with_namespace(:your_namespace) do
        Porpoise::String.set('test-key', 'test-value')
        Porpoise::Hash.hset('test-key', 'foo', 'bar')
    end

## Development

Fork this repo. Development is done from within a Docker container for which the Dockerfile is included in this repo. Build and start the the container to access this gems development environment:

    docker build -t porpoise-app .
    docker run -it --rm -v "$PWD:/porpoise" porpoise-app

Run all other actions from within the container. Tests:

    appraisal install
    appraisal rails-3 rspec spec
    appraisal rails-4 rspec spec
    appraisal rails-5 rspec spec

Console:

    appraisal rails-3 ./bin/console
    appraisal rails-4 ./bin/console
    appraisal rails-5 ./bin/console

PR's are welcome :) This is my first gem thingie ever, so help me out.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sentialabs/porpoise.

