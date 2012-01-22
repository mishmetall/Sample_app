require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Homepage at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have a About at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a Help at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

  it "should have a Sign up at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end

  it "should have a Sign in at '/signin'" do
    get '/signin'
    response.should have_selector('title', :content => "Sign in")
  end

  it "should have a right links on the layout" do
    visit root_path
    response.should have_selector('title', :content => "Home")
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Sign up now!"
    click_link "Sign up now!"
    response.should have_selector('title', :content => "Sign up")
    response.should have_selector('a[href="/"]>img')
  end
end
