class WelcomeController < ApplicationController
  def index
    user = current_user || User.find_one(email: "admin@younoter.com")
    if user
      redirect_to home_user_path(user) 
    else
      redirect_to login_path
    end
  end

  def about
  end

  def contact
  end

  def contributor
  end
end
