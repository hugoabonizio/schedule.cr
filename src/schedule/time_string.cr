class TimeString
  def initialize(@time : String)
    @time_array = [] of String
    @time_array = @time.split(":")
  end

  def to_tuple
    {
      hour:   get_hour,
      minute: get_minute,
      second: get_second,
    }
  end

  private def get_hour
    @time_array[0].to_i
  end

  private def get_minute
    @time_array[1].to_i
  end

  private def get_second
    @time_array[2].to_i
  end
end
