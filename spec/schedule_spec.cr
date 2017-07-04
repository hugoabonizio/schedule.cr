require "./spec_helper"

describe Schedule do
  context "::every" do
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

  context "::after" do
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

  context "::exception_handler" do
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
end
