require "./spec_helper"

describe Schedule do
  it "should execute every 0.1 seconds" do
    flag1 = 0
    Schedule.every(100.milliseconds) do
      flag1 += 1
    end
    flag1.should eq 0
    sleep 110.milliseconds
    flag1.should eq 1
    sleep 110.milliseconds
    flag1.should eq 2
  end

  it "should handles exceptions" do
    flag2 = 0
    Schedule.exception_handler do
      flag2 += 1
      Schedule.stop
    end
    flag2.should eq 0
    Schedule.every(0.seconds) do
      raise Exception.new
    end
    sleep 0.1
    flag2.should eq 1
  end

  it "should stop" do
    flag3 = 0
    Schedule.every(100.milliseconds) do
      Schedule.stop if flag3 >= 2
      flag3 += 1
    end
    flag3.should eq 0
    sleep 110.milliseconds
    flag3.should eq 1
    sleep 110.milliseconds
    flag3.should eq 2
    sleep 110.milliseconds
    flag3.should eq 2
  end

  it "should retry" do
    flag4 = 0
    Schedule.every(100.milliseconds) do
      begin
        raise "try again" if flag4 < 2
      rescue
        flag4 += 1
        Schedule.retry
      end
    end
    flag4.should eq 0
    sleep 110.milliseconds
    flag4.should eq 1
    sleep 110.milliseconds
    flag4.should eq 2
    sleep 110.milliseconds
    flag4.should eq 2
  end
end
