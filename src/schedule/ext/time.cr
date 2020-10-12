struct Time
  def change(year = nil, month = nil, day = nil, hour = nil, minute = nil, second = nil)
    current_time = self
    year ||= current_time.year
    month ||= current_time.month
    day ||= current_time.day
    hour ||= current_time.hour
    minute ||= current_time.minute
    second ||= current_time.second
    Time.local(year, month, day, hour, minute, second)
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
      return date if result
      date = date + 1.day
    end
  end
end
