require 'spec_helper'

def destroy_all
  User.destroy_all
  3.times{ begin; Comment.destroy_all; rescue; end; }
end

# --------------------------------------
# Helpers
# --------------------------------------
def my_comments_count_assert user, count
  user.my_comments.active.count.should eq count
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
# init functions
# --------------------------------------
def create_users_and_post
  @user        = FactoryGirl.create(:user)
  @post_holder = FactoryGirl.create(:user)
  @post        = FactoryGirl.create(:post, user: @post_holder)
end

def base_test_situation
  create_users_and_post

  3.times do
    @comment = Comment.create!(
      user: @user,
      commentable: @post,
      title: Faker::Lorem.sentence,
      raw_content: Faker::Lorem.paragraphs(3).join
    )
  end

  @user.reload
  @post_holder.reload
end

def tree_test_situation
  create_users_and_post

  # LEVEL 1
  3.times do
    Comment.create!(
      user: @user,
      commentable: @post,
      title: Faker::Lorem.sentence,
      raw_content: Faker::Lorem.paragraphs(3).join,
      state: :published
    )
  end
    # LEVEL 2
    parent_comment = Comment.first
    3.times do
      Comment.create!(
        user: @user,
        commentable: @post,
        parent_id: parent_comment.id,
        title: Faker::Lorem.sentence,
        raw_content: Faker::Lorem.paragraphs(3).join,
        state: :published
      )
    end
      # LEVEL 3
      parent_comment = Comment.first.children.first
      3.times do
        Comment.create!(
          user: @user,
          commentable: @post,
          parent_id: parent_comment.id,
          title: Faker::Lorem.sentence,
          raw_content: Faker::Lorem.paragraphs(3).join,
          state: :published
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
      @comment = Comment.create!(
        user: @user,
        commentable: @post,
        title: Faker::Lorem.sentence,
        raw_content: Faker::Lorem.paragraphs(3).join
      )

      @comment.user.should   eq @user
      @comment.holder.should eq @post_holder
    end
  end

  context "Written by me counters" do
    after(:all) { destroy_all }
    before(:all){ create_users_and_post }
    it 'should has correct My counters values' do
      @comment = Comment.create!(
        user: @user,
        commentable: @post,
        title: Faker::Lorem.sentence,
        raw_content: Faker::Lorem.paragraphs(3).join
      )
      @user.reload
      @user.my_comments_count.should           eq 1
      @user.my_draft_comments_count.should     eq 1
      @user.my_published_comments_count.should eq 0
    end
  end

  context "Commentable Denormalization" do
    after(:all) { destroy_all }
    before(:all) do
      base_test_situation
    end

    it 'should have denormalized fields' do
      title = "New Title!"
      @post.update_attribute(:title, title)
      @post.title.should eq title
      @comment = @post.comments.first
      @comment.commentable_title.should eq title
    end
  end

  context 'User leave 3 comments and Instances has expectable counter values' do
    after(:all) { destroy_all }

    before(:all){ base_test_situation }

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
      base_test_situation
      @comment = Comment.first
      @comment.to_published

      @user.reload
      @post.reload
      @comment.reload
      @post_holder.reload
    end

    describe 'User counters' do
      it 'has expectable values' do
        comments_counters_assert @user, [0,0,0]
        comments_count_assert    @user, [0,0,0]
        comcoms_counters_assert  @user, [0,0,0]
        comcoms_count_assert     @user, [0,0,0]
        my_comments_count_assert @user, 3
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
      base_test_situation
      @comment = Comment.first
      @comment.to_published
      @comment.to_deleted

      @user.reload
      @post.reload
      @comment.reload
      @post_holder.reload
    end

    it 'has correct counters values' do
      comments_counters_assert @user, [0,0,0]
      comments_count_assert    @user, [0,0,0]
      comcoms_count_assert     @user, [0,0,0]
      my_comments_count_assert @user, 2
      @user.my_comments.count.should eq 3

      comments_counters_assert @post_holder, [0,0,0]
      comments_count_assert    @post_holder, [0,0,0]
      comcoms_count_assert     @post_holder, [2,0,1]
      my_comments_count_assert @post_holder, 0
      @post_holder.my_comments.count.should eq 0

      comments_count_assert    @post, [2,0,1]
      comments_counters_assert @post, [2,0,1]
    end
  end

  context 'Comments tree, 1 branch to deleted' do
    after(:each) { destroy_all }
    before(:each){ tree_test_situation }

    it 'has correct counters values before deleting' do
      Comment.count.should eq 9

      my_comments_count_assert @user, 9
      comments_count_assert    @user, [0,0,0]

      my_comments_count_assert @post_holder, 0
      comments_count_assert    @post_holder, [0,0,0]

      comcoms_count_assert    @post_holder, [0,9,0]
      comcoms_counters_assert @post_holder, [0,9,0]

      comments_count_assert    @post, [0,9,0]
      comments_counters_assert @post, [0,9,0]
    end

    it 'has correct counters values after branch deleting' do
      @comment = Comment.first.children.first
      @comment.to_deleted

      @user.reload
      @post.reload
      @post_holder.reload

      Comment.with_state(:published).count.should eq 5
      Comment.with_state(:deleted).count.should   eq 4

      my_comments_count_assert @user, 5
      comments_count_assert    @user, [0,0,0]

      my_comments_count_assert @post_holder, 0
      comments_count_assert    @post_holder, [0,0,0]

      comcoms_count_assert    @post_holder, [0,5,4]
      comcoms_counters_assert @post_holder, [0,5,4]

      comments_count_assert    @post, [0,5,4]
      comments_counters_assert @post, [0,5,4]
    end

    # This code helps to me to catch logic bugs
    # there is no any asserts
    # context "callbacks catch" do
    #   after(:all) { destroy_all }
    #   it "before validation callback with increment! must be call manually" do
    #     @user        = FactoryGirl.create(:user)
    #     @post_holder = FactoryGirl.create(:user)
    #     @post        = FactoryGirl.create(:post, user: @post_holder)

    #     Comment.create!(
    #       user: @user,
    #       commentable: @post,
    #       title: Faker::Lorem.sentence,
    #       raw_content: Faker::Lorem.paragraphs(3).join,
    #       state: :deleted
    #     )
    #     Comment.first.to_published
    #   end
    # end

    # it 'has correct counters after comment destroy' do
    #   pending("has correct counters after comment destroy")
    # end
  end
end
