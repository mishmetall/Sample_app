require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do

     it "should deny access " do
        get :index
        response.should redirect_to(signin_path)
     end

    describe "for signed-in-users" do

      before(:each)do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "user@chubaka.net")
        Factory(:user, :email => "user@karton.net")

        30.times do
          Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        User.all.each do |user|
          response.should have_selector('li', :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => "Previous")
        response.should have_selector('a', :href => "/users?escape=false&page=2",
                                           :content => "2")
        response.should have_selector('a', :href => "/users?escape=false&page=2",
                                           :content => "Next")
      end

    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "returns http success" do
      get :show, :id => @user
      response.should be_success
    end

    it "Should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "Should have right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name)
    end

    it "Should have the user's name'" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name)
    end

    it "Should have a profile image" do
      get :show, :id => @user
      response.should have_selector('h1>img', :class => "gravatar")
    end

    it "Should have the right URL" do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user),
                                            :href    => user_path(@user))
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new
      response.should be_success
    end

    it "Should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => ""}
      end
    end

    it "should have the right title" do
      post :create, :user => @attr
      response.should have_selector("title", :content => "Sign up")
    end

    it "should have the 'new' page" do
      post :create, :user => @attr
      response.should render_template('new')
    end

    it "should not create a user" do
      lambda do
        post :create, :user => @attr
      end.should_not change(User, :count)
    end
  end
  describe "success" do
    before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :password => "foobar",
                  :password_confirmation => "foobar"}
    end

    it "should create a user" do
      lambda do
        post :create, :user => @attr
      end.should change(User, :count).by(1)
    end

    it "should redirect to the user show page" do
      post :create, :user => @attr
      response.should redirect_to(user_path(assigns(:user)))
    end

    it "should have a welcome message" do
      post :create, :user => @attr
      flash[:success].should =~ /welcome to the sample app/i
    end

    it "should sign user in" do
      post :create, :user => @attr
      controller.should be_signed_in
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "Should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "Should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end

    it "should have link to change gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => "http://gravatar.com/emails",
                                        :content => "Change")
    end
  end

  describe "POST 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => ""}
      end

      it "should render the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "Should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end
    describe "success" do

      before(:each) do
        @attr = { :name => "New name", :email => "new@email.com", :password => "foobaz",
                  :password_confirmation => "foobaz"}
      end

      it "should change the user`s attributes`" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
        @user.encrypted_password.should == user.encrypted_password
      end

      it "should have flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update actions" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end

      it "should deny access to 'update'" do
        get :edit, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user, :user => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

    end

  end
end
