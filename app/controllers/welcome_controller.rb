class WelcomeController < ApplicationController
  def index
    redirect_to home_user_path(current_user) if current_user
  end

  def about
  end

  def contact
  end

  def contributor
  end
end
