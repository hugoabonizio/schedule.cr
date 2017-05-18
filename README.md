# Schedule [![Build Status](https://travis-ci.org/hugoabonizio/schedule.cr.svg?branch=master)](https://travis-ci.org/hugoabonizio/schedule.cr)

**Schedule** is a Crystal shard that provides a clear DSL to write periodic tasks. It has the ability to stop or retry the job whenever is necessary, with proper ways to handle exceptions.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  schedule:
    github: hugoabonizio/schedule.cr
```

## Usage

```crystal
require "schedule"

# Print "Hello!" each 2 seconds
Schedule.every(2.seconds) do
  puts "Hello!"
end

# Set a default exception handler
Schedule.exception_handler do |ex|
  puts "Exception recued! #{ex.message}"
end

# Stop or retry a task
Schedule.every(100.milliseconds) do
  begin
    count += computed_value
  rescue
    Schedule.retry
  end

  Schedule.stop if count >= MAX_VALUE
end
```

Scheduled tasks can be isolated having its own runner:
```crystal
runner = Schedule::Runner.new
runner.every(100.milliseconds) do
  Schedule.stop if condition
end

runner.exception_handler do |ex|
  puts ex.message
end
```

## Contributing

1. Fork it ( https://github.com/hugoabonizio/schedule.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [hugoabonizio](https://github.com/hugoabonizio) Hugo Abonizio - creator, maintainer
