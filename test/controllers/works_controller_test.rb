require "test_helper"

describe WorksController do
  let(:album) { 
    works(:album) 
  }

  let(:book) {
    works(:poodr)
  }

  let(:movie) {
    works(:parasite)
  }

  let(:ada) {
    users(:ada)
  }

  describe "logged in users" do 
    before do 
      perform_login(ada)
    end

    describe "root" do
      it "succeeds with all media types" do
        expect(session[:user_id]).wont_be_nil

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
      before do 
        perform_login
      end
  
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
        new_work = { 
          work: { 
            title: "Dirty Computer", 
            category: "album" 
          } 
        }
  
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
  
      it "succeeds for an extant work ID (album category)" do
        expect(session[:user_id]).wont_be_nil
        
        get work_path(album.id)
  
        must_respond_with :success
      end

      it "succeeds for an extant work ID (book category)" do
        expect(session[:user_id]).wont_be_nil
        
        get work_path(book.id)
  
        must_respond_with :success
      end

      it "succeeds for an extant work ID (movie category)" do
        expect(session[:user_id]).wont_be_nil
        
        get work_path(movie.id)
  
        must_respond_with :success
      end
  
      it "renders 404 not_found for a bogus work ID" do
        destroyed_id = album.id
        album.destroy
  
        get work_path(destroyed_id)
  
        must_respond_with :not_found
      end
    end
  
    describe "edit" do
      it "succeeds for an extant work ID" do
        get edit_work_path(album.id)
  
        must_respond_with :success
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        get edit_work_path(bogus_id)
  
        must_respond_with :not_found
      end
    end
  
    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        updates = { work: { title: "Dirty Computer" } }
  
        expect {
          put work_path(album), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: album.id)
  
        expect(updated_work.title).must_equal "Dirty Computer"
        must_respond_with :redirect
        must_redirect_to work_path(album.id)
      end
  
      it "renders bad_request for bogus data" do
        updates = { work: { title: nil } }
  
        expect {
          put work_path(album), params: updates
        }.wont_change "Work.count"
  
        work = Work.find_by(id: album.id)
  
        must_respond_with :not_found
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        put work_path(bogus_id), params: { work: { title: "Test Title" } }
  
        must_respond_with :not_found
      end
    end
  
    describe "destroy" do
      it "succeeds for an extant work ID" do
        expect {
          delete work_path(album.id)
        }.must_change "Work.count", -1
  
        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        expect {
          delete work_path(bogus_id)
        }.wont_change "Work.count"
  
        must_respond_with :not_found
      end
    end
  
    describe "upvote" do
      before do 
        current_user = users(:lovelace)
        perform_login(current_user)
      end
  
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        expect(session[:user_id]).wont_be_nil
  
        expect {
          post upvote_path(movie)
        }.must_change "Vote.count", 1
        
        expect(flash["status"]).must_equal :success
        expect(flash["result_text"]).must_include "Successfully upvoted!"
      end


      it "redirects to the work page after the user has logged out" do
        expect(session[:user_id]).wont_be_nil
  
        delete logout_path
  
        expect(session[:user_id]).must_be_nil
  
        expect {
          post upvote_path(movie)
        }.wont_change "Vote.count"
  
        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"
  
        must_redirect_to root_path
      end
  

      it "redirects to the work page if the user has already voted for that work" do
        expect(session[:user_id]).wont_be_nil
        post upvote_path(movie)
  
        expect {
          post upvote_path(movie)
        }.wont_change "Vote.count"
  
        must_redirect_to work_path(movie)
  
        expect(flash["status"]).must_equal :failure
        expect(flash["result_text"]).must_include "Could not upvote"
        expect(flash["messages"][:user]).must_include "has already voted for this work"
      end
    end
  end



  describe "guest users" do 
    describe "root" do
      it "succeeds with all media types" do
        get root_path
  
        must_respond_with :success
      end
    end
  

    describe "index" do
  
      it "redirects to the main page as guest user" do
        get works_path
  
        must_redirect_to root_path

        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"
      end
    end


    # TODO
    describe "new" do
      it "redirects to root_path as guest user when trying to add a new work" do

        get new_work_path

        must_respond_with :redirect
        must_redirect_to root_path 
        
      end
    end
  
    # TODO
    describe "create" do
      it "redirects to root_path when trying to create a work with valid data for a real category" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }
  
        expect {
          post works_path, params: new_work
        }.wont_change "Work.count"
    
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_include "You must log in to do that"

        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      # TODO:
      it "redirects to root_path and does not update the DB for bogus data" do
        bad_work = { work: { title: nil, category: "book" } }
  
        expect {
          post works_path, params: bad_work
        }.wont_change "Work.count"
  
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_include "You must log in to do that"
        must_respond_with :redirect

      end
  
      # TODO
      it "redirects to root_path when trying to create a work for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          invalid_work = { work: { title: "Invalid Work", category: category } }
  
          expect { post works_path, params: invalid_work }.wont_change "Work.count"
  
          expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil

          expect(flash[:status]).must_equal :failure
          expect(flash[:result_text]).must_include "You must log in to do that"

          must_respond_with :redirect
        end
      end
    end

  
    describe "show" do  
      it "redirects to the main page as guest user" do
        get work_path(album.id)
  
        must_redirect_to root_path

        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"
      end
    end

    describe "edit" do
      # TODO
      it "redirects to root_path when trying to edit for an extant work ID" do
        get edit_work_path(album.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        get edit_work_path(bogus_id)
  
        must_respond_with :not_found
      end
    end
  

    describe "update" do
      # TODO
      it "redirects to root_path when trying to update a valid work" do
        updates = { work: { title: "Dirty Computer" } }
  
        expect {
          put work_path(album), params: updates
        }.wont_change "Work.count"

        updated_work = Work.find_by(id: album.id)
  
        expect(updated_work.title).must_equal "Old Title"

        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"

        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      # TODO
      it "redirects to root_path when updating a work for bogus data" do
        updates = { work: { title: nil } }
  
        expect {
          put work_path(album), params: updates
        }.wont_change "Work.count"
  
        work = Work.find_by(id: album.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      it "renders 404 not_found for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        put work_path(bogus_id), params: { work: { title: "Test Title" } }
  
        must_respond_with :not_found
      end
    end

    # TODO
    describe "destroy" do
      it "redirects to root_path for an extant work ID" do
        expect {
          delete work_path(album.id)
        }.wont_change "Work.count"
  
        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"
          
        must_respond_with :redirect
        must_redirect_to root_path
      end
  
      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        bogus_id = album.id
        album.destroy
  
        expect {
          delete work_path(bogus_id)
        }.wont_change "Work.count"
  
        must_respond_with :not_found
      end
    end


    describe "upvote" do
      let(:work_params) {
        works(:parasite)
      }
  
      it "redirects to the root page if no user is logged in" do
        expect {
          post upvote_path(work_params)
        }.wont_change "Vote.count"
  
        expect(flash["status"]).must_equal :failure 
        expect(flash["result_text"]).must_include "You must log in to do that"
  
        must_redirect_to root_path
      end
    end

  end
end
