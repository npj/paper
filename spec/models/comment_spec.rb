require 'spec_helper'

describe Comment do
  describe 'visible to' do
    
    before :each do
      @post    = Fabricate(:post)
      @comment = Fabricate(:comment, :commentable => @post)
    end
    
    it 'owner' do
      @comment.visible_to.should include(@comment.user.id)
    end

    it 'post owner' do
      @comment.visible_to.should include(@post.user.id)
    end
    
    describe 'parent' do
      before :each do
        @child = Fabricate(:comment, :parent => @comment)
      end
      
      it 'child should be visible to parent owner' do
        @child.visible_to.should include(@comment.user.id)
      end
      
      it 'parent should be visible to child owner' do
        @comment.visible_to.should include(@child.user.id)
      end
      
      describe 'descendents' do
        before :each do
          @descendent = Fabricate(:comment, :parent => @child)
        end
        
        it 'descendent should not be visible to ancestor owner' do
          @descendent.visible_to.should_not include(@comment.user.id)
        end
        
        it 'descentdent should be visible to child owner' do
          @descendent.visible_to.should include(@child.user.id)
        end
        
        it 'child should be visible to descendent owner' do
          @child.visible_to.should include(@descendent.user.id)
        end
      end
    end
  end
  
  describe 'become private' do
    before :each do
      @parent = Fabricate(:comment)
      @child  = Fabricate(:comment, :parent => @parent)
      @leaves = 2.times.collect { Fabricate(:comment, :parent => @child) }
    end
    
    context 'before change' do
      it 'parent should be public' do
        @parent.should be_public
      end
      
      it 'child should be public' do
        @child.should be_public
      end
      
      it 'leaves should be public' do
        @leaves.each { |l| l.should be_public }
      end
    end
    
    context 'after change' do
      before :each do
        @parent.private!
      end
      
      it 'parent should be private' do
        @parent.should be_private
      end
      
      it 'child should be private' do
        @child.should be_private
      end
      
      it 'leaves should be private' do
        @leaves.each { |l| l.should be_private }
      end
    end
  end
end
