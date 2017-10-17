require "./spec_helper"
require "timecop"

describe Schedule do
  context ".every" do
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

    it "should execute every second is :second symbol is passed" do
      flag1 = 0
      Schedule.every(:second) do
        flag1 += 1
        Schedule.stop if flag1 >= 2
      end
      flag1.should eq 0
      sleep 2.second
      flag1.should eq 1
      sleep 1.second
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

  context ".after" do
    it "should execute after 0.1 seconds" do
      flag1 = 0
      Schedule.after(100.milliseconds) do
        flag1 += 1
      end
      flag1.should eq 0
      sleep 110.milliseconds
      flag1.should eq 1
      sleep 110.milliseconds
      flag1.should eq 1
    end

    it "should handles exceptions" do
      flag2 = 0
      Schedule.exception_handler do
        flag2 += 1
      end

      flag2.should eq 0
      Schedule.after(0.seconds) do
        raise Exception.new
      end

      sleep 100.milliseconds
      flag2.should eq 1
    end

    it "should stop" do
      flag3 = 0
      Schedule.after(100.milliseconds) do
        Schedule.stop
        flag3 += 1
      end
      flag3.should eq 0
      sleep 110.milliseconds
      flag3.should eq 0
    end

    it "should retry" do
      flag4 = 0
      Schedule.after(100.milliseconds) do
        begin
          raise "try again" if flag4 < 2
        rescue
          flag4 += 1
          sleep 100.milliseconds
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

  context ".exception_handler" do
    it "passes the exception to the handle" do
      message = ""
      Schedule.exception_handler do |ex|
        message = ex.message
      end

      Schedule.after(100.milliseconds) do
        raise "test"
      end

      message.should eq("")
      sleep 110.milliseconds
      message.should eq("test")
    end
  end

  context ".calculate_interval" do
    it "provide time for corresponding interval" do
      Schedule.calculate_interval(:minute).should eq 1.minute
    end

    context "at 3 PM on Sunday" do
      it "should calculate_interval(:sunday, '16:00:00') should give '01:00:00'" do
        time = Time.new(2017, 10, 15, 15, 0, 0)
        Timecop.freeze(time)

        Schedule.calculate_interval(:sunday, "16:00:00").to_s.should eq "01:00:00"
      end
    end

    context "5 PM on sunday" do
      it "should calculate_interval(:sunday, '16:00:00') should give next sunday 4 PM" do
        time = Time.new(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time)

        Schedule.calculate_interval(:sunday, "16:00:00").to_s.should eq "6.23:00:00"
      end

      it "should calculate_interval(:sunday, '19:00:00') should give 3 hours" do
        time = Time.new(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time)

        Schedule.calculate_interval(:sunday, "20:00:00").to_s.should eq "03:00:00"
      end
    end

    context ", for multiple times on the same day" do
      it "should return the time right after current time" do
        time = Time.new(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time)

        Schedule.calculate_interval(:sunday, ["16:00:00", "18:00:00"]).to_s.should eq "01:00:00"
      end

      it "should return the time for next week if the time slot of the day has passed" do
        time = Time.new(2017, 10, 15, 19, 0, 0)
        Timecop.freeze(time)

        Schedule.calculate_interval(:sunday, ["16:00:00", "18:00:00"]).to_s.should eq "6.21:00:00"
      end
    end
  end
end
