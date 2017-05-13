require "./schedule/*"

module Schedule
  class StopException < Exception; end

  class RetryException < Exception; end

  @@exception_handler : (Proc(Nil) | Proc(Exception))?

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
            case h = handler
            when Proc(Nil)
              h.call
            when Proc(Exception, Nil)
              h.call(ex)
            end
          end
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

  def self.exception_handler(&block)
    @@exception_handler = block
  end
end
