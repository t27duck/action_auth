# ActionAuth

ActionAuth is a gem designed to implement a straight forward (as possible) role-based permission system for Ruby apps via a simple configuration DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_auth

## Usage

### Configuring Permissions

Permission information is created via a DSL provided to the main `ActionAuth::Config` object, commonly done by providing a path to a text file. This should only be called once as all information is cleared every time the DSL is parsed.

You'll most likely want to put this in an initializer for your application:

```ruby
ActionAuth::Config.read(path_to_configuration_file)
```

Example Configuration:

```ruby
role :admin do
  includes :moderator
  category :users, actions: [:new, :create]
end

role :moderator do
  includes :regular
  category :posts, actions: [:create, :new]
  category :users, actions: [:edit, :update]
end

role :regular do
  category :posts, actions: [:index, :show]
  category :users, actions: [:show]
  category :users, actions: [:edit, :update], resolve: ->(current_user, user) { current_user.id == user.id }
end
```

ActionAuth's DSL revolves around five parts: `role`, `category`, `actions`, `resolve` (strategies), and `includes`.

`role` - A role is the primary means of grouping related permission information. Each role can be considered a "bucket" describing everything a certain role can do. ActionAuth supports users having multiple roles.

`category` - A category is a container holding related things the role is allowed to do. In a web app-like system, a category could be considered a controller.

`actions` - Actions belong to a category and list various... well... actions within the category that the user is allow to do. In a web application, actions can be thought to be similar to controller actions.

`resolve` - A category/action(s) combination may have an *optional* resolution strategy. A strategy is a lambda which should return `true` or `false`. The lambda should have one or two arguments. The first argument is always going to be the currently logged in user. If two arguments are accepted, the second one is an object that is used to (commonly) compare against the logged in user. For example, when determining if a user be able to update a post, the post object would be preloaded and passed in as the second argument. The lambda would then compare the post's creator to the current user and return true if the post belongs to the user.

`includes` - Call includes inside of a `role` block to chain other roles together. This provides a way to create a hierarchy of roles and share category/actions between roles without having to maintain copies.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/action_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActionAuth project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/action_auth/blob/master/CODE_OF_CONDUCT.md).
