require 'spec_helper'

describe City do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    City.create!(@valid_attributes)
  end
end
