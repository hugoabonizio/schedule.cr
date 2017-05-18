require "../schedule"

schedule = Schedule::Runner.new
schedule.every(100.milliseconds) do
end
