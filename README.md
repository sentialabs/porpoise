# Porpoise

## Welcome

Porpoise implements a Redis like interface using MySQL as its storage engine. This provides an easy replacement for Rails applications that currently use Redis to store key/value data and would like to switch to MySQL for whatever reason.

### Performance

Redis outperforms this implementation by a long shot :p I don't think I have to tell why. This thing integrates with Rails, uses ActiveRecord and all the bloat that comes with it. But sometimes... performance is not the issue.

### Then why?

To simplify your stack? To get a real multi-master setup using MySQL/Galera? To get rid of an unstable situation?

This gem was written out of the need to get rid of our shaky Redis Dynomite cluster which we implemented due to the requirement of having actual multi-master clusters. Master-slave- and failover setups tend to break over time, so multi-master is our way to go.

So Redis /w Dynomite kept exploding at every little burp so we needed a solution. MySQL / Galera was already there as our primary datastore so the alternative was easily chosen. Reasons: proven multi-master setup and a more easy stack. With our userbase and use of Redis, performance was of minor importance.

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
        adapter: mysql2
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
 
Porpoise was designed as an easy replacement for Redis. Therefore it implements various of the types Redis knows (strings, sets and hashes) and their functions. Access them like this:

    Porpoise::String.<redis-function-name-and-arguments>
    Porpoise::Set.<redis-function-name-and-arguments>
    Porpoise::Hash.<redis-function-name-and-arguments>

Namespacing is easy as well. Surround your Porpoise calls in a block like this example:

    Porpoise.with_namespace(:your_namespace) do
        Porpoise::String.set('test-key', 'test-value')
        Porpoise::Hash.hset('test-key', 'foo', 'bar')
    end

## Development

Clone this repo. Development is done from within a Docker container for which the Dockerfile is included in this repo. Build and start the the container to access this gems development environment:

    docker build -t porpoise-app .
    docker run -it --rm -v "$PWD:/porpoise" porpoise-app

Run all other actions from within the container. Tests:

    bundle exec rspec spec

Console:

    ./bin/console



PR's are welcome :)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/porpoise.

