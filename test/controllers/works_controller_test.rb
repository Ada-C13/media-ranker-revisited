require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }
  before do
    @user = users(:ada)
  end
  describe "root" do
    it "succeeds with all media types" do
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      only_book = works(:poodr)
      only_book.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all do |work|
        work.destroy
      end

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works and user is logged in" do
      
      perform_login(@user)
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works, and user is logged in" do
      Work.all do |work|
        work.destroy
      end
      perform_login(@user)
      get works_path

      must_respond_with :success
    end

    it "redirects when user is not logged in" do
      get works_path

      must_respond_with :redirect
    end
  end

  describe "new" do
    it "succeeds when user is logged in" do
      perform_login(@user)
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category when user is logged in" do
      new_work = { work: { title: "Dirty Computer", category: "album" } }
      perform_login(@user)
      expect {
        post works_path, params: new_work
      }.must_change "Work.count", 1

      new_work_id = Work.find_by(title: "Dirty Computer").id

      must_respond_with :redirect
      must_redirect_to work_path(new_work_id)
    end

    it "doesn't creates a work with valid data for a real category when user is not logged in" do
      new_work = { work: { title: "Dirty Computer", category: "album" } }
      expect {
        post works_path, params: new_work
      }.wont_change "Work.count"

      new_work = Work.find_by(title: "Dirty Computer")

      must_respond_with :redirect
      new_work.must_be_nil
    end

    it "renders bad_request and does not update the DB for bogus data" do
      bad_work = { work: { title: nil, category: "book" } }
      perform_login(@user)
      expect {
        post works_path, params: bad_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        invalid_work = { work: { title: "Invalid Work", category: category } }
        perform_login(@user)
        expect { post works_path, params: invalid_work }.wont_change "Work.count"

        expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    it "succeeds for an extant work ID when user is logged in" do
      perform_login(@user)
      get work_path(existing_work.id)
      must_respond_with :success
    end

    it "redirects for an extant work ID when user is not logged in" do
      get work_path(existing_work.id)
      must_respond_with :redirect
    end

    it "renders 404 not_found for a bogus work ID when user is logged in" do
      destroyed_id = existing_work.id
      existing_work.destroy
      perform_login(@user)
      get work_path(destroyed_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID when user is logged in" do
      perform_login(@user)
      get edit_work_path(existing_work.id)
      must_respond_with :success
    end

    it "redirects for an extant work ID when user is not logged in" do
      get edit_work_path(existing_work.id)
      
      must_respond_with :redirect
    end

    it "renders 404 not_found for a bogus work ID when user is logged in" do
      bogus_id = existing_work.id
      existing_work.destroy
      perform_login(@user)
      get edit_work_path(bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID when user is logged in" do
      updates = { work: { title: "Dirty Computer" } }
      perform_login(@user)
      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"
      updated_work = Work.find_by(id: existing_work.id)

      expect(updated_work.title).must_equal "Dirty Computer"
      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "redirects for valid data and an extant work ID when user is not logged in" do
      updates = { work: { title: "Dirty Computer" } }
      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"
      updated_work = Work.find_by(id: existing_work.id)

      expect(updated_work.title).must_equal "Old Title"
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders bad_request for bogus data when user is logged in" do
      updates = { work: { title: nil } }
      perform_login(@user)
      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      work = Work.find_by(id: existing_work.id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID when user is logged in" do
      bogus_id = existing_work.id
      existing_work.destroy
      perform_login(@user)
      put work_path(bogus_id), params: { work: { title: "Test Title" } }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID when user is logged in" do
      perform_login(@user)
      expect {
        delete work_path(existing_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for an extant work ID when user is logged in" do
      expect {
        delete work_path(existing_work.id)
      }.wont_change "Work.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID when user is logged in" do
      bogus_id = existing_work.id
      existing_work.destroy
      perform_login(@user)
      expect {
        delete work_path(bogus_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end

  end

  describe "upvote" do
    it "redirects to the root_path if no user is logged in" do
      expect{post upvote_path(existing_work.id)}.wont_change existing_work.vote_count
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:ada)
      work = works(:movie)
      perform_login(user)
      expect{post upvote_path(work)}.must_differ "work.votes.count", 1
    end

    it "won't upvote if the user has already voted for that work" do
      user = users(:ada)
      work = works(:movie)
      perform_login(user)
      expect{post upvote_path(work)}.must_differ "work.votes.count", 1
      expect{post upvote_path(work)}.wont_change "work.votes.count"
    end
  end
end
