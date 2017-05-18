require "../schedule"

Schedule.exception_handler do
  puts "Exception recued! "
end

Schedule.every(100.milliseconds) do
  raise "I'm an Exception"
end

sleep 1.second
