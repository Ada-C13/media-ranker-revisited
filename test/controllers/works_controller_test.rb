require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }
  let(:dan) { users(:dan) }

  describe "guest user" do
    describe "root" do
      it "succeeds with all media types" do
        get root_path

        must_respond_with :success
      end

      it "succeeds with an absent media type" do
        only_book = works(:poodr)
        only_book.destroy
  
        get root_path
  
        must_respond_with :success
      end

      it "succeeds with no media present" do
        Work.destroy_all
  
        get root_path
  
        must_respond_with :success
      end
    end
    

    describe "index" do
      it "redirects to root_path with guest user" do
        get works_path

        must_redirect_to root_path
      end

    
  end
  
  describe "show" do
    it "succeeds for an existing work ID" do
      perform_login(users(:dan))
      delete logout_path
      get work_path(existing_work.id)

    
      must_redirect_to root_path
    end

    it "renders 404 not_found for a bad work ID" do
      destroyed_id = existing_work.id
      existing_work.destroy

      get work_path(destroyed_id)

      must_respond_with :not_found
    end
  end
end

describe "authenticated" do
  
  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["wrong", "66", "", "  ", "something"]

  describe "index" do

    it "succeeds when there are works" do
      perform_login(users(:dan))
      get works_path

      must_respond_with :found
    end

    it "succeeds when there are no works" do
      perform_login(users(:dan))

      Work.all do |work|
        work.destroy
      end

      get works_path

      must_respond_with :found
    end
  end
  describe "show" do
    it "succeeds for an existing work ID" do
      perform_login(users(:dan))
      get work_path(existing_work.id)

      must_respond_with :found
    end

    it "renders 404 not_found for a bad work ID" do
      perform_login(users(:dan))
      destroyed_id = existing_work.id
      existing_work.destroy

      get work_path(destroyed_id)

      must_respond_with :not_found
    end
  end
end
  
  describe "new" do
    it "succeeds" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      new_work = { work: { title: "Sample Work", category: "album" } }

      expect {
        post works_path, params: new_work
      }.must_change "Work.count", 1

      new_work_id = Work.find_by(title: "Sample Work").id

      must_respond_with :redirect
      must_redirect_to work_path(new_work_id)
    end

    it "renders bad_request and does not update the DB for bad data" do
      bad_work = { work: { title: nil, category: "book" } }

      expect {
        post works_path, params: bad_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bad categories" do
      INVALID_CATEGORIES.each do |category|
        invalid_work = { work: { title: "Invalid Work", category: category } }

        proc { post works_path, params: invalid_work }.wont_change "Work.count"

        Work.find_by(title: "Invalid Work", category: category).must_be_nil
        must_respond_with :bad_request
      end
    end
  end

 

  describe "edit" do
    it "succeeds for an existing work ID" do
      get edit_work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bad work ID" do
      bad_id = existing_work.id
      existing_work.destroy

      get edit_work_path(bad_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an existing work ID" do
      updates = { work: { title: "Sample Work" } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"
      updated_work = Work.find_by(id: existing_work.id)

      updated_work.title.must_equal "Sample Work"
      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "renders bad_request for bad data" do
      updates = { work: { title: nil } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      work = Work.find_by(id: existing_work.id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bad work ID" do
      bad_id = existing_work.id
      existing_work.destroy

      put work_path(bad_id), params: { work: { title: "Test Title" } }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an existing work ID" do
      expect {
        delete work_path(existing_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bad work ID" do
      bad_id = existing_work.id
      existing_work.destroy

      expect {
        delete work_path(bad_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do

      post upvote_path(existing_work)
      flash[:result_text].must_equal "You must log in to do that"
      must_redirect_to work_path(existing_work)
    end

    it "redirects to the work page after the user has logged out" do
      perform_login(dan)
      logout_path

      post upvote_path(existing_work)
      flash[:result_text].must_equal "You must log in to do that"
      must_redirect_to work_path(existing_work)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(users(:kari))
      movie = works(:movie)

      post upvote_path(movie)
      must_respond_with :found
      must_redirect_to work_path(movie)
      flash[:result_text].wont_be_nil
      flash[:status].wont_be_nil
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(users(:kari))
      movie = works(:movie)

      post upvote_path(movie)
      must_respond_with :found
      must_redirect_to work_path(movie)
      flash[:result_text].wont_be_nil
      flash[:status].wont_be_nil

      post upvote_path(movie)
      
      flash[:status].must_equal :failure
      must_redirect_to work_path(movie)
    end
  end
end