class RunningsController < ApplicationController


  # List all running sessions
  def index
    @sessions = current_user.sport_sessions
    @friends = current_user.friends
  end

  def new

    # _params = params.merge({:type => 'Running', :user_id => current_user.id, :cc_user => current_user.cc_user})
    # @running = Facade::SportSession.create(_params)

  end

  def show

  end

  def edit

  end

  def destroy

  end


end
