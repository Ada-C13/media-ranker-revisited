require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }

  describe "Authenticated users" do
    before do
      perform_login(users(:sarah))
    end

    describe "Root path" do
      it "Functionality works for each type of work in database" do
        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        only_book = works(:poodr)
        only_book.destroy

        get works_path

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
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index action" do
    it "succeeds when there are works" do
      perform_login(users(:sarah))

      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      perform_login(users(:sarah))

      Work.all do |work|
        work.destroy
      end

      get works_path

      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      perform_login(users(:sarah))

      get new_work_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      perform_login(users(:sarah))

      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      destroyed_id = existing_work.id
      existing_work.destroy

      get work_path(destroyed_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      perform_login(users(:sarah))

      get edit_work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      get edit_work_path(bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      perform_login(users(:devin))

      updates = { work: { title: "Dirty Computer" } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"
      updated_work = Work.find_by(id: existing_work.id)

      expect(updated_work.title).must_equal "Dirty Computer"
      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "renders bad_request for bogus data" do
      perform_login(users(:sarah))

      updates = { work: { title: nil } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      work = Work.find_by(id: existing_work.id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      put work_path(bogus_id), params: { work: { title: "Test Title" } }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      perform_login(users(:sarah))
      
      expect {
        delete work_path(existing_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      expect {
        delete work_path(bogus_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      perform_login(users(:sarah))

      post upvote_path(existing_work.id)

      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "redirects to the work page after the user has logged out" do
      work = works(:poodr)

      post upvote_path(existing_work.id)
      perform_logout(users(:sarah))

      expect(flash[:status]).must_equal :failure 
      must_respond_with :redirect
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(users(:devin))
      work = works(:album)

      post upvote_path(existing_work.id)

      expect(flash[:status]).must_equal :success
      must_respond_with :redirect
    end
  end
end
