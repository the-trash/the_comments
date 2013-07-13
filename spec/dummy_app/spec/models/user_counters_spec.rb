require 'spec_helper'

def destroy_all
  User.destroy_all
  Comment.destroy_all
end

def create_users_and_post
  @user = FactoryGirl.create(:user)

  @post_holder = FactoryGirl.create(:user)
  @post        = FactoryGirl.create(:post, user: @post_holder)
end

def base_testing_situation
  create_users_and_post

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

describe User do
  context 'User leave comment to the post' do
    before(:all){ create_users_and_post }
    after(:all){  destroy_all           }

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
    before(:all){ base_testing_situation }
    after(:all) { destroy_all            }

    describe 'User counters' do
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

    describe 'Holder counters' do
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

  context 'User leave 3 comments, 1 Comment DRAFT => PUBLISHED, counters should have expectable values' do
    before(:all) do
      base_testing_situation
      @comment = Comment.first.to_published

      @user.reload
      @post_holder.reload
    end

    after(:all) { destroy_all }

    describe 'User counters' do
      it 'has expectable values' do
        @user.comments.count.should    eq 3
        @user.my_comments_count.should eq 3
        @user.comcoms.count.should     eq 0

        @user.comments.with_state(:draft).count.should     eq 2
        @user.comments.with_state(:published).count.should eq 1
        @user.comments.with_state(:deleted).count.should   eq 0
      end
    end

    describe 'Holder counters' do
      it 'has expectable values' do
        @post_holder.comments.count.should    eq 0
        @post_holder.my_comments_count.should eq 0
        @post_holder.comcoms.count.should     eq 3

        @post_holder.comcoms.with_state(:draft).count.should     eq 2
        @post_holder.comcoms.with_state(:published).count.should eq 1
        @post_holder.comcoms.with_state(:deleted).count.should   eq 0

        @post_holder.draft_comcoms_count.should     eq 2 # TODO! 3
        @post_holder.published_comcoms_count.should eq 1
        @post_holder.deleted_comcoms_count.should   eq 0
      end
    end
  end
end