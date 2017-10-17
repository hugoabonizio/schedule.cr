require "./spec_helper"

describe TimeString do
  context ".to_h" do
    it "returns the string converted to hash" do
      time_string = TimeString.new("14:00:00")

      time_hash = time_string.to_h

      time_hash.should eq({:hour => 14, :minute => 0, :second => 0})
    end
  end
end
