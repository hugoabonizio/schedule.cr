require "./spec_helper"

describe Time do
  context ".change" do
    it "should change parameters based on hash" do
      current_time = Time.new
      current_time.change({:year   => 2016,
                           :month  => 5,
                           :day    => 3,
                           :hour   => 1,
                           :minute => 1,
                           :second => 1}).to_s.should eq "2016-05-03 01:01:01"
    end

    it "should change just the parameters passed based on hash" do
      current_time = Time.new
      current_time.change({:year => 2016}).year.should eq 2016
      current_time.change({:year => 2016}).minute.should eq current_time.minute
    end
  end
end
