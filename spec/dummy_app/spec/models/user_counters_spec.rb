require 'spec_helper'

def destroy_all
  User.destroy_all
  Comment.destroy_all
end

# --------------------------------------
# Helpers
# --------------------------------------
def my_comments_count_assert user, count
  user.my_comments.count.should eq count
  user.my_comments_count.should eq count
end

def comments_count_assert(obj, values)
  obj.comments.with_state(:draft).count.should     eq values[0]
  obj.comments.with_state(:published).count.should eq values[1]
  obj.comments.with_state(:deleted).count.should   eq values[2]
end

def comments_counters_assert(obj, values)
  obj.draft_comments_count.should     eq values[0]
  obj.published_comments_count.should eq values[1]
  obj.deleted_comments_count.should   eq values[2]
end

def comcoms_count_assert(obj, values)
  obj.comcoms.with_state(:draft).count.should     eq values[0]
  obj.comcoms.with_state(:published).count.should eq values[1]
  obj.comcoms.with_state(:deleted).count.should   eq values[2]
end

def comcoms_counters_assert(obj, values)
  obj.draft_comcoms_count.should     eq values[0]
  obj.published_comcoms_count.should eq values[1]
  obj.deleted_comcoms_count.should   eq values[2]
end
# --------------------------------------
# ~ Helpers
# --------------------------------------

# --------------------------------------
# init functions
# --------------------------------------
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
# --------------------------------------
# ~ init functions
# --------------------------------------

describe User do
  context 'User leave comment to the post' do
    after(:all){ destroy_all }

    before(:all){ create_users_and_post }

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
    after(:all) { destroy_all }

    before(:all){ base_testing_situation }

    describe 'User counters' do
      it 'my_comments counter' do
        my_comments_count_assert(@user, 3)
      end

      it 'Comcoms counters' do
        @user.comcoms.count.should eq 0

        comcoms_counters_assert(@user, [0,0,0])
      end
    end

    describe 'Holder counters' do
      it 'my_comments counter' do
        my_comments_count_assert(@post_holder, 0)
      end

      it 'Comcoms counters' do
        @post_holder.comcoms.count.should eq 3
        comcoms_counters_assert(@post_holder, [3,0,0])
      end
    end
  end

  context 'User leave 3 comments, 1 Comment DRAFT => PUBLISHED' do
    after(:all) { destroy_all }

    before(:all) do
      base_testing_situation
      @comment = Comment.first
      @comment.to_published

      @user.reload
      @post.reload
      @comment.reload
      @post_holder.reload
    end

    describe 'User counters' do
      it 'has expectable values' do
        my_comments_count_assert(@user, 3)
        
        @user.comcoms.count.should eq 0
        comments_count_assert(@user, [2,1,0])
      end
    end

    describe 'Holder counters' do
      it 'has expectable values' do
        @post_holder.comcoms.count.should eq 3

        my_comments_count_assert(@post_holder, 0)
        comcoms_count_assert    @post_holder, [2,1,0]
        comcoms_counters_assert @post_holder, [2,1,0]
      end
    end
  end

  context '3 comments, 1 Comment DRAFT => DELETE' do
    after(:all) { destroy_all }

    before(:all) do
      base_testing_situation
      @comment = Comment.first

      @comment.to_published
      @comment.to_deleted

      @user.reload
      @post.reload
      @comment.reload
      @post_holder.reload
    end

    it 'has correct counters values' do
      comments_count_assert @user,        [2,0,1]
      comments_count_assert @post_holder, [0,0,0]

      comcoms_count_assert    @user, [0,0,0]
      comcoms_counters_assert @user, [0,0,0]

      comcoms_count_assert    @post_holder, [2,0,1]
      comcoms_counters_assert @post_holder, [2,0,1]

      comments_count_assert    @post, [2,0,1]
      comments_counters_assert @post, [2,0,1]
    end
  end
end