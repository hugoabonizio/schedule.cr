require "./schedule/*"

module Schedule
  class StopException < Exception; end

  class RetryException < Exception; end

  class_property exception_handler : (Proc(Nil) | Proc(Exception, Nil))?

  INTERVALS = {:hour   => 1.hour,
               :minute => 1.minute,
               :day    => 1.day,
               :second => 1.second}

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
    INTERVALS[interval]
  end

  macro exception_handler(&block)
    {% if block.args.size == 0 %}
      Schedule.exception_handler = ->{ {{block.body}}; nil }
    {% else %}
      Schedule.exception_handler = ->({{ block.args[0] }} : Exception){ {{block.body}}; nil }
    {% end %}
  end
end
