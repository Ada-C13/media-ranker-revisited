require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }

  describe "logged in" do
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
  
    before do
      perform_login
    end
  
    describe "index" do
      it "succeeds when there are works" do
        ada = users(:ada)
        perform_login(ada)
  
        get works_path
  
        must_respond_with :success
      end
  
      it "succeeds when there are no works" do
        ada = users(:ada)
        perform_login(ada)
  
        Work.all do |work|
          work.destroy
        end
  
        get works_path
  
        must_respond_with :success
      end
    end
  
    describe "create" do
      it "creates a work with valid data for a real category" do
        ada = users(:ada)
        perform_login(ada)
  
        new_work = { work: { title: "Bubble", category: "album" } }
  
        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1
  
        new_work_id = Work.find_by(title: "Bubble").id
  
        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end
  
      it "renders bad_request and does not update the DB for bogus data" do
        bad_work = { work: { title: nil, category: "album" } }
  
        expect {
          post works_path, params: bad_work
        }.wont_change "Work.count"
  
        must_respond_with :bad_request
      end
  
      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          invalid_work = { work: { title: "Invalid Work", category: category } }
  
          expect { post works_path, params: invalid_work }.wont_change "Work.count"
  
          expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
          must_respond_with :bad_request
        end
      end
    end
  
    describe "show" do
      it "succeeds for an extant work ID" do
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
        updates = { work: { title: "Floss" } }
  
        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: existing_work.id)
  
        expect(updated_work.title).must_equal "Floss"
        must_respond_with :redirect
        must_redirect_to work_path(existing_work.id)
      end
  
      it "renders bad_request for bogus data" do
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
        post upvote_path(existing_work.id)
  
        must_respond_with :redirect
        must_redirect_to work_path(existing_work)
      end
  
      it "redirects to the root page after the user has logged out" do
        perform_login
  
        expect(session[:user_id]).wont_be_nil
        post upvote_path(existing_work.id)
  
        delete logout_path
  
        expect(session[:user_id]).must_be_nil
  
        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user = users(:ada)
        work = works(:album)
  
        perform_login(user)
  
        expect{
          post upvote_path(work.id)
        }.must_differ "Vote.count", 1 
  
        vote = Vote.find_by(user_id: user.id, work_id: work.id)
        expect(vote.user.username).must_equal "countess_ada"
  
      end
  
      it "redirects to the work page if the user has already voted for that work" do
        user = users(:ada)
        work = works(:album)
  
        perform_login(user)
  
        expect{
          post upvote_path(work.id)
        }.must_differ "Vote.count", 1 
        
        post upvote_path(work)
        must_respond_with :redirect
  
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "Could not upvote"
      end
    end
  end

  describe 'guest' do
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
      it "redirects when there are works" do
        get works_path
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
  
  
      it "redirects when there are works" do  
        Work.all do |work|
          work.destroy
        end
  
        get works_path
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
    end

    describe "new" do
      it "redirects when a guest attempts to make a new work" do
        get new_work_path
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
    end

    describe "create" do
      it "will not save a new work if not logged in" do  
        new_work = { work: { title: "Bubble", category: "album" } }

        post works_path, params: new_work

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
    end
  
    describe "show" do
      it "redirects for an extant work ID" do
        get work_path(existing_work.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
  
      it "renders 404 not_found for a bogus work ID" do
        destroyed_id = existing_work.id
        existing_work.destroy
  
        get work_path(destroyed_id)
  
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "redirects for an extant work ID" do
        get edit_work_path(existing_work.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy
  
        get edit_work_path(bogus_id)
  
        must_respond_with :not_found
      end
    end
  
    describe "update" do
      it "redirects for valid data and an extant work ID" do
        updates = { work: { title: "Floss" } }
        put work_path(existing_work), params: updates
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy
  
        put work_path(bogus_id), params: { work: { title: "Test Title" } }
  
        must_respond_with :not_found
      end
    end
  
    describe "destroy" do
      it "redirects for an extant work ID" do
        delete work_path(existing_work.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You must be logged in."
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
        post upvote_path(existing_work.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
