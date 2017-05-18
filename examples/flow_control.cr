require "../schedule"

MAX_COUNT = 3
count = 0
Schedule.every(100.milliseconds) do
  count += 1
  puts "Hello #{count}"
  Schedule.stop if count >= MAX_COUNT
end

sleep 1.second
