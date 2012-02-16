require 'spec_helper'

describe Comment do
  describe 'visible to' do
    
    before :each do
      @user = Fabricate(:user)
      @post = Fabricate(:post)
    end
    
    describe 'to owner'
    describe 'to parent owner'
    describe 'to children owners'
    describe 'to childrens children owners'
  end
end
