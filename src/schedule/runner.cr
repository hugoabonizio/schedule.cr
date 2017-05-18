module Schedule
  class Runner
    @exception_handler : (Proc(Nil) | Proc(Exception))?

    def every(interval, &block)
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
            if handler = @exception_handler
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

    def exception_handler(&block)
      @exception_handler = block
    end
  end
end
