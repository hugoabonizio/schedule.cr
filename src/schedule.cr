require "./schedule/*"

module Schedule
  class StopException < Exception; end

  class RetryException < Exception; end

  class_property exception_handler : (Proc(Nil) | Proc(Exception, Nil))?

  def self.every(interval, &block)
    spawn do
      loop do
        begin
          sleep interval
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
    end
  end

  def self.after(interval, &block)
    delay(interval) do
      loop do
        begin
          block.call
          break
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
            break
          end
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

  macro exception_handler(&block)
    {% if block.args.size == 0 %}
      Schedule.exception_handler = ->{ {{block.body}}; nil }
    {% else %}
      Schedule.exception_handler = ->({{ block.args[0] }} : Exception){ {{block.body}}; nil }
    {% end %}
  end
end
