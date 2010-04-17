require 'spec_helper'

describe Day do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Day.create!(@valid_attributes)
  end
end
