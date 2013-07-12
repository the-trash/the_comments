require 'spec_helper'

describe User do
  context 'User leave comment to the post' do
    before(:all) do
      @user = FactoryGirl.create(:user)

      @post_holder = FactoryGirl.create(:user)
      @post        = FactoryGirl.create(:post, user: @post_holder)
    end

    it 'should be User' do
      @user.should        be_instance_of User
      @post_holder.should be_instance_of User
    end

    it 'should be Post' do
      @post.should be_instance_of Post
    end

    it 'Post should has owner' do
      @post.user.should eq @post_holder
    end

    it 'Create new comment' do
      @comment = @user.comments.create!(
        commentable: @post,
        title: Faker::Lorem.sentence,
        raw_content: Faker::Lorem.paragraphs(3).join
      )

      @comment.user.should   eq @user
      @comment.holder.should eq @post_holder
      @comment.should        be_instance_of Comment
    end
  end

  context 'User leave comments and Instances has expectable counter values' do
    before(:all) do
      @user = FactoryGirl.create(:user)

      @post_holder = FactoryGirl.create(:user)
      @post        = FactoryGirl.create(:post, user: @post_holder)

      3.times do
        @comment = @user.comments.create!(
          commentable: @post,
          title: Faker::Lorem.sentence,
          raw_content: Faker::Lorem.paragraphs(3).join
        )
      end
    end

    it 'User have expectable counter values' do
      @user.comments.count.should    eq 3
      @user.my_comments.count.should eq 3
      @user.my_comments_count.should eq 3
    end
  end
end
