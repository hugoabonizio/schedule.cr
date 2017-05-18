require "../schedule"

count = 0
Schedule.every(100.milliseconds) do
  count += 1
  puts "Hello #{count}"
end

sleep 1.second
