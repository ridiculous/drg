# DRG
[![Code Climate](https://codeclimate.com/github/ridiculous/drg/badges/gpa.svg)](https://codeclimate.com/github/ridiculous/drg)
[![Gem Version](https://badge.fury.io/rb/drg.svg)](http://badge.fury.io/rb/drg)

A suite of rake tasks to help you test and manage your project.

The `drg:pin` suite provides enhanced dependency management with Bundler. You can pin Gem versions to the current or the next
available minor, major or patch level version. 

The `drg:spec` task generates RSpec scaffolding for existing code. This helps bootstrap your tests and guide you in what 
[I think] you should be testing.

## Requirements

* Bundler 1.10+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drg'
```

## Tasks

```bash
rake drg:spec
rake drg:pin
rake drg:pin:major
rake drg:pin:minor
rake drg:pin:patch
rake drg:pin:latest
rake drg:pin:patch_latest
rake drg:pin:minor_latest
rake drg:unpin
```

### drg:spec

Generates RSpec scaffolding for existing code. Pass a file or directory and DRG will generate spec files for each:

```bash
rake drg:spec[app/controllers]
rake drg:spec[app/models/user.rb]
```

This task looks at your code's methods and breaks down their conditions into RSpec `context`s. For example:

Given this file:

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :update, User do |u|
        u.id == user.id
      end
    end
  end
end
```

It will generate this spec:
```ruby
require "spec_helper"

describe Ability do
  let(:user) {}

  subject { described_class.new user }

  describe "#initialize" do
    context "when user.luna?" do
      before {}
    end

    context "unless user.luna?" do
      before {}
    end
  end
end
```

### drg:pin

DRG really wants to help you manage your project's gems. But DRG doesn't want to replace Bundler. Instead, we want to build on
it. Pinning ignores gems that are fetched from somewhere other than rubygems. For example, gems listed with `:git`, `:github`,
or `:path` will be ignored. You can "pin" all your versions to the current version listed in the Gemfile.lock:

```bash
rake drg:pin
```

This task will update your Gemfile with the gem's full version. It'll change:

```ruby
gem 'rails'
gem 'byebug', require: false
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'drg' # need this
```

to:

```ruby
gem 'rails', '4.2.3'
gem 'byebug', '5.0.0', require: false
gem 'therubyracer', '0.12.2', platforms: :ruby
gem 'drg', '0.4.1' # need this
```

### drg:pin:minor

Want to pin gems at their __minor__ version?

```bash
rake drg:pin:minor
```

This task will update your Gemfile with the approximate gem's minor version. It'll change:

```ruby
gem 'rails', '4.2.3'
```

to:

```ruby
gem 'rails', '~> 4.2'
```

### drg:pin:patch

Want to pin gems at their __patch__ version?

```bash
rake drg:pin:minor
```

This task will update your Gemfile with the approximate gem's patch version. It'll change:

```ruby
gem 'rails', '4.2.3'
```

to 

```ruby
gem 'rails', '~> 4.2.3'
```

This can be combined with `bundle update` to quickly update all gems to the latest version.

### drg:pin:major

Pins your gems at the major level:

 ```bash
 rake drg:pin:major
 ```

### drg:pin:latest

Updates each outdated gem to the latest available version:

 ```bash
 rake drg:pin:latest         #=> updates all gems in the Gemfile
 rake drg:pin:latest[<gem>]  #=> updates only the specified <gem>
 ```

### drg:pin:patch_latest

Updates the patch version for each outdated gem to the latest version:

 ```bash
 rake drg:pin:patch_latest         #=> updates all gems in the Gemfile
 rake drg:pin:patch_latest[<gem>]  #=> updates only the specified <gem>
 ```

### drg:pin:minor_latest

Same as `patch_latest` except it updates the minor version to the latest

 ```bash
 rake drg:pin:minor_latest         #=> updates all gems in the Gemfile
 rake drg:pin:minor_latest[<gem>]  #=> updates only the specified <gem>
 ```

### drg:unpin

Remove the versions from your Gemfile. A clean start!

```bash
rake drg:unpin
```

### Skipping gems

You can tell drg to ignore gems by adding an inline comment with @drg (skip|ignore|frozen)

```ruby
gem 'name' # @drg skip
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
