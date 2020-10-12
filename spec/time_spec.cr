require "./spec_helper"

describe Time do
  context ".change" do
    it "should change parameters based on hash" do
      current_time = Time.local

      new_time = current_time.change(year: 2016,
        month: 5,
        day: 3,
        hour: 1,
        minute: 1,
        second: 1).to_s("%F %H:%M:%S %:z")

      new_time.should eq "2016-05-03 01:01:01 #{current_time.zone.format}"
    end

    it "should change just the parameters passed based on hash" do
      current_time = Time.local

      current_time.change(year: 2016).year.should eq 2016
      current_time.change(year: 2016).minute.should eq current_time.minute
    end

    it "should change the self object" do
      time = Time.local(2016, 1, 1, 1, 1, 1)

      time = time.change(**{hour: 0, minute: 0, second: 0})

      time.year.should eq 2016
      time.day.should eq 1
      time.month.should eq 1
    end
  end
end
