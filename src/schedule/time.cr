struct Time
  def change(options : Hash(Symbol, Int32 | Nil))
    current_time = Time.new
    year = options.fetch(:year, nil) || current_time.year
    month = options.fetch(:month, nil) || current_time.month
    day = options.fetch(:day, nil) || current_time.day
    hour = options.fetch(:hour, nil) || current_time.hour
    minute = options.fetch(:minute, nil) || current_time.minute
    second = options.fetch(:second, nil) || current_time.second

    Time.new(year, month, day, hour, minute, second)
  end
end
