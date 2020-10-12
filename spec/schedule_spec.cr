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
    it "should return 30 seconds when scheduled at 30th second of a minute" do
      time = Time.local(2017, 10, 15, 15, 0, 30)
      Timecop.freeze(time) do
        Schedule.calculate_interval(:minute).to_f.ceil.should eq(30.seconds.to_i)
      end
    end

    it "should return 19 minutes when scheduled at 2:31 PM" do
      time = Time.local(2017, 10, 15, 14, 31, 0)
      Timecop.freeze(time) do
        Schedule.calculate_interval(:hour).to_f.ceil.should eq(29.minutes.to_i)
      end
    end

    context ":sunday, '16:00:00'" do
      it "should return 1 hour when executed at 3 pm on a Sunday'" do
        time = Time.local(2017, 10, 15, 15, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:sunday, "16:00:00").to_s.should eq "01:00:00"
        end
      end
    end

    context ":sunday, '16:00:00'" do
      it "should return 6 days and 23 hours when executed at 5 PM on a Sunday" do
        time = Time.local(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:sunday, "16:00:00").to_s.should eq "6.23:00:00"
        end
      end

      it "should return 3 hours when executed at 1 PM" do
        time = Time.local(2017, 10, 15, 13, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:sunday, "16:00:00").to_s.should eq "03:00:00"
        end
      end
    end

    context ":sunday, ['16:00:00', '18:00:00']" do
      it "should return 1 hour when scheduled at Sunday 5 PM" do
        time = Time.local(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:sunday, ["16:00:00", "18:00:00"]).to_s.should eq "01:00:00"
        end
      end

      it "should return 6 days 21 hours when scheduled at Sunday 7 PM" do
        time = Time.local(2017, 10, 15, 19, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:sunday, ["16:00:00", "18:00:00"]).to_s.should eq "6.21:00:00"
        end
      end
    end

    context ":day, at: '16:00:00'" do
      it "should return 1 hour when scheduled at 3 PM" do
        time = Time.local(2017, 10, 15, 15, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:day, "16:00:00").to_s.should eq "01:00:00"
        end
      end

      it "should return 23 hour when scheduled at 5 PM" do
        time = Time.local(2017, 10, 15, 17, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:day, "16:00:00").to_s.should eq "23:00:00"
        end
      end
    end

    context ":day, at: ['16:00:00', '18:00:00']" do
      it "should return 1 hour when scheduled at 3 PM" do
        time = Time.local(2017, 10, 15, 15, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:day, ["16:00:00", "18:00:00"]).to_s.should eq "01:00:00"
        end
      end

      it "should return 1 hour 30 minute when scheduled at 4:30 PM" do
        time = Time.local(2017, 10, 15, 16, 30, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:day, ["16:00:00", "18:00:00"]).to_s.should eq "01:30:00"
        end
      end

      it "should return 23 hour when scheduled at 9 PM" do
        time = Time.local(2017, 10, 15, 19, 0, 0)
        Timecop.freeze(time) do
          Schedule.calculate_interval(:day, "16:00:00").to_s.should eq "21:00:00"
        end
      end
    end
  end
end
