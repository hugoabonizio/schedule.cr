struct Time
  def change(options : Hash(Symbol, Int32 | Nil))
    current_time = self
    year = options.fetch(:year, nil) || current_time.year
    month = options.fetch(:month, nil) || current_time.month
    day = options.fetch(:day, nil) || current_time.day
    hour = options.fetch(:hour, nil) || current_time.hour
    minute = options.fetch(:minute, nil) || current_time.minute
    second = options.fetch(:second, nil) || current_time.second

    Time.new(year, month, day, hour, minute, second)
  end

  def find_next(day : Symbol)
    date = self
    loop do
      result = case day
               when :day
                 true
               when :sunday
                 date.sunday?
               when :monday
                 date.monday?
               when :tuesday
                 date.tuesday?
               when :wednesday
                 date.wednesday?
               when :thursday
                 date.thursday?
               when :friday
                 date.friday?
               when :saturday
                 date.saturday?
               else
                 raise "Undefined day of the week #{day}"
               end
      if result
        return date
      else
        date = date + 1.day
      end
    end
  end
end
