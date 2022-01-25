# Royal

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/royal`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'royal'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install royal

## Usage

```ruby
class User < ApplicationRecord
  include Royal::Points

  # ...
end
```

### Viewing the Point Balance

```ruby
user = User.first

user.loyalty_points # => 0
```

### Adding Loyalty Points

```ruby
user.add_loyalty_points(100) # => 100
```

### Spending Loyalty Points

```ruby
user.spend_loyalty_points(75) # => 25
```

```ruby
user.spend_loyalty_points(200) # => raises #<Royal::InsufficientPointsError ...>
```

### Including a Reason or Note

```ruby
user.add_loyalty_points(50, reason: 'Birthday points!')
```

### Linking to Another Record

```ruby
reward = Reward.find_by(name: 'Gift Card')

user.spend_loyalty_points(50, pointable: reward)
```

### Loyalty Point Balance History

```erb
<table>
  <tr>
    <th>Operation</th>
    <th>Balance</th>
    <th>Reason</th>
  </tr>
  <% user.loyalty_point_balances.each do |point_balance| %>
    <tr>
      <td><%= point_balance.amount.positive? ? 'Added' : 'Spent' %> <%= point_balance.amount %></td>
      <td><%= point_balance.balance %></td>
      <td><%= point_balance.reason %></td>
    </tr>
  <% end %>
</table>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mintyfresh/royal.
