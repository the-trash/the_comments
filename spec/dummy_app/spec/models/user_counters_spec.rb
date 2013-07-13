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

    it 'Post should has owner' do
      @post.user.should eq @post_holder
    end

    it 'should be Post' do
      @post.should be_instance_of Post
    end

    it 'Create new comment' do
      @comment = @user.comments.create!(
        commentable: @post,
        title: Faker::Lorem.sentence,
        raw_content: Faker::Lorem.paragraphs(3).join
      )

      @comment.user.should   eq @user
      @comment.holder.should eq @post_holder
    end
  end

  context 'User leave 3 comments and Instances has expectable counter values' do
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

      @user.reload
      @post_holder.reload
    end

    context 'User counters' do
      it 'my_comments counter' do
        @user.my_comments.count.should eq 3
        @user.my_comments_count.should eq 3
      end

      it 'Comcoms counters' do
        @user.comcoms.count.should           eq 0
        @user.draft_comcoms_count.should     eq 0
        @user.published_comcoms_count.should eq 0
        @user.deleted_comcoms_count.should   eq 0
      end
    end

    context 'Holder counters' do
      it 'my_comments counter' do
        @post_holder.my_comments.count.should eq 0
        @post_holder.my_comments_count.should eq 0
      end

      it 'Comcoms counters' do
        @post_holder.comcoms.count.should           eq 3
        @post_holder.draft_comcoms_count.should     eq 3
        @post_holder.published_comcoms_count.should eq 0
        @post_holder.deleted_comcoms_count.should   eq 0
      end
    end
  end
end
