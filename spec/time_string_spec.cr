require "./spec_helper"

describe TimeString do
  context ".to_h" do
    it "returns the string converted to hash" do
      time_string = TimeString.new("14:00:00")

      time_tuple = time_string.to_tuple

      time_tuple.should eq({hour: 14, minute: 0, second: 0})
    end
  end
end
