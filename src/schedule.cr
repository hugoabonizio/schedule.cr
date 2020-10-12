require "./schedule/ext/*"
require "./schedule/*"

module Schedule
  class StopException < Exception; end

  class RetryException < Exception; end

  class InvalidTimeException < Exception; end

  class_property exception_handler : (Proc(Nil) | Proc(Exception, Nil))?

  def self.every(interval, &block)
    spawn do
      loop do
        sleep interval
        run(block)
      end
    end
  end

  def self.every(interval : Symbol, &block)
    spawn do
      loop do
        sleep calculate_interval(interval)
        run(block)
      end
    end
  end

  def self.every(interval : Symbol, at : String | Array, &block)
    spawn do
      loop do
        sleep calculate_interval(interval, at)
        run(block)
      end
    end
  end

  def self.after(interval, &block)
    delay(interval) do
      loop do
        run(block)
        break
      end
    end
  end

  private macro run(block)
    begin
      block.call
    rescue ex : StopException
      break
    rescue ex : RetryException
      next
    rescue ex
      if handler = @@exception_handler
        begin
          case h = handler
          when Proc(Nil)
            h.call
          when Proc(Exception, Nil)
            h.call(ex)
          end
        rescue ex : StopException
          break
        end
      end
    end
  end

  def self.stop
    raise StopException.new
  end

  def self.retry
    raise RetryException.new
  end

  def self.calculate_interval(interval : Symbol)
    now = Time.local
    case interval
    when :minute
      now.at_end_of_minute - now
    when :hour
      now.at_end_of_hour - now
    when :day
      now.at_end_of_day - now
    else
      raise InvalidTimeException.new
    end
  end

  def self.calculate_interval(interval : Symbol, at : String | Array(String))
    current_time = Time.local
    next_day = current_time.find_next(interval)
    next_datetime = next_time(next_day, at)
    next_datetime = if next_datetime == next_day
                      next_day = (next_day + 1.day).change(hour: 0, minute: 0, second: 0)
                      next_time(next_day.find_next(interval), at)
                    else
                      next_datetime
                    end
    next_datetime - current_time
  end

  def self.next_time(current_time : Time, at : Array(String))
    at = at.sort
    at.each do |time|
      time_string = TimeString.new(time)
      new_time = current_time.change(**time_string.to_tuple)
      if new_time > current_time
        return new_time
      end
    end
    current_time
  end

  def self.next_time(current_time : Time, at : String)
    time_string = TimeString.new(at)
    new_time = current_time.change(**time_string.to_tuple)
    return new_time if new_time > current_time
    current_time
  end

  macro exception_handler(&block)
    {% if block.args.size == 0 %}
      Schedule.exception_handler = ->{ {{block.body}}; nil }
    {% else %}
      Schedule.exception_handler = ->({{ block.args[0] }} : Exception){ {{block.body}}; nil }
    {% end %}
  end
end
