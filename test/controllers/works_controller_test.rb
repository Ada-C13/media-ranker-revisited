require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }
  describe "logged in" do 
    before do 
      perform_login(users(:ada))
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
      it "succeeds when there are works" do
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all do |work|
          work.destroy
        end

        get works_path

        must_respond_with :success
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
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1

        new_work_id = Work.find_by(title: "Dirty Computer").id

        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        bad_work = { work: { title: nil, category: "book" } }

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
      it "won't allow user to upvote after logging out" do
        delete logout_path, params: {}
        
        work = works(:poodr)
        
        expect {
          post upvote_path(work.id)
        }.wont_change "Vote.count"
        
        must_redirect_to root_path
      end
      
      it "creates a vote for valid logged in user" do
        user = perform_login
        
        work = works(:poodr)
        vote = Vote.new(user: user, work: work)
        
        expect {
          post upvote_path(work.id)
        }.must_change "Vote.count", 1
        
        must_redirect_to work_path(work.id)
      end
      
      it "does not allow a new vote for previously voted on work" do
        user = perform_login
        
        work = works(:another_album)
        vote = Vote.new(user: user, work: work)
        
        expect {
          post upvote_path(work.id)
        }.wont_change "Vote.count"
        
        must_redirect_to work_path(work.id)
      end
    end
  end 
  describe "logged out" do 
    describe "root" do
      it "gues users can access homepage with works of all types" do
        get root_path
        
        must_respond_with :success
      end
      
      it "guest users can access homepage with works of one type missing" do
        movie = works(:movie)
        movie.destroy
        
        get root_path
        
        must_respond_with :success
      end
      
      it "succeeds with no works saved in the database" do
        Work.destroy_all
        
        get root_path
        
        must_respond_with :success
      end
    end
    

    describe "index" do
      it "does not allow guest user access and redirects to root" do
        get works_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "show" do
      it "does not allow guest user access and redirects to root" do
        get work_path(existing_work.id)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "new" do
      it "does not allow guest user access and redirects to root" do
        get new_work_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "create" do
      it "does not create a new work and redirects to root" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }
        
        expect {
          post works_path, params: new_work
        }.wont_change "Work.count"
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "edit" do
      it "does not update existing work and redirects to root" do
        get edit_work_path(existing_work.id)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "update" do
      it "does not update existing valid work and redirects to root" do
        updates = { work: { title: "Invalid" } }
        
        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "destroy" do
      it "does not allow guest user to destroy work and redirects to root page" do
        expect {
          delete work_path(existing_work.id)
        }.wont_change "Work.count"
        
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
    

    describe "upvote" do
      it "does not allow guest user to upvote existing works and redirects to root" do
        post upvote_path(existing_work)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end 
end
