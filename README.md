# Schedule [![Build Status](https://travis-ci.org/hugoabonizio/schedule.cr.svg?branch=master)](https://travis-ci.org/hugoabonizio/schedule.cr)

**Schedule** is a Crystal shard that provides a clear DSL to write periodic or scheduled tasks. It has the ability to stop or retry the job whenever is necessary, with proper ways to handle exceptions. See usage examples in [examples](https://github.com/hugoabonizio/schedule.cr/tree/master/examples) folder.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  schedule:
    github: hugoabonizio/schedule.cr
```

## Usage

[This blog post](https://blog.redpanthers.co/painless-cron-jobs-crystal-using-schedule/) describes the basic usage of **Schedule**.

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

# Execute a task after X interval
Schedule.after(2.seconds) do
  puts "Hi!"
end

# Schedule task every day at a particular time

Schedule.every(:day, "16:00:00") do
  puts "Good Afternoon!"
end

# Schedule task to run multiple time every day

Schedule.every(:day, ["16:00:00", "18:00:00"]) do
  puts "Greetings!"
end

# Schedule task to run a particular time at particular day of the week

Schedule.every(:sunday, "16:00:00") do
  puts "House Keeping"
end

# Schedule task to run multiple time on a given day
Schedule.every(:sunday, ["16:00:00", "18:00:00"] do
  puts "Greetings!"
end

```

#### Scheduled tasks can be isolated having its own runner:
```crystal
runner = Schedule::Runner.new
runner.every(100.milliseconds) do
  Schedule.stop if condition
end

runner.exception_handler do |ex|
  puts ex.message
end
```

### Flow control

A task can be stopped or retried using ```Schedule.stop``` and ```Schedule.retry``` respectively.

```crystal
Schedule.every(10.seconds) do
  result = try_to_update
  Schedule.retry if result == -1
  Schedule.stop if updates >= MAX_COUNT
end
```

### Exception handlers

You can use the ```Schedule.exception_handler do ... end``` form to set an exception handler or directly pass a proc to the ```Schedule.exception_handler``` class property.

```crystal
handler = ->(ex : Exception) { puts "Exception recued! #{ex.message}" }
Schedule.exception_handler = handler
```

## Contributing

1. Fork it ( https://github.com/hugoabonizio/schedule.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [hugoabonizio](https://github.com/hugoabonizio) Hugo Abonizio - creator, maintainer
