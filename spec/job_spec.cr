require "./spec_helper"

describe Schedule::Job do
  context ".run" do
    it "should run the job only once" do
      counter = 0
      Schedule::Job.run "counter_job" { counter += 1; sleep 10.milliseconds }
      Schedule::Job.run "counter_job" { counter += 1; sleep 10.milliseconds }
      Schedule::Job.run "counter_job" { counter += 1; sleep 10.milliseconds }
      sleep 1.millisecond
      counter.should eq 1
    end
  end
end
