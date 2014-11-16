class RunningsController < ApplicationController


  # List all running sessions
  def index
    @runnings = Facade::SportSession.where(user_id: current_user.id, type: 'Running')
    @friends = current_user.friends
  end

  def new
    @running = Facade::SportSession.create(user: current_user, type: 'Running')
    @friends = current_user.friends
  end


  def edit
    @running = Facade::SportSession.find_by id: params[:id]

    if Date.parse(@running.entry_date) < Date.today
      # Can only edit results
      @results = @running.sport_session_participants.where(:user_id => current_user.id).first!.result
      render :edit_results
    else
      # Normal edit
      @friends = current_user.friends
      render :edit
    end


  end

  def show
    @running = Facade::SportSession.find_by id: params[:id]
  end


  # POST /runnings
  def create

    date_time_object = DateTime.strptime(sport_session_params[:entry_date], '%Y-%m-%d')
    entry_params = sport_session_params.merge({user: current_user, type: 'Running', entry_date: date_time_object})
    @entry = Facade::SportSession.create(entry_params)

    if @entry.save

      # 1. Invite the friends, needs other handling
      if entry_params[:friends].present?
        @entry.invite(entry_params[:friends])
      end

      # 2. For the current RunningParticipantResult model to work, I need to be participant too
      SportSessionParticipant.create(:user_id => current_user.id, :sport_session_id => @entry.id, :confirmed => true)

      # The stuff above should be hidden behind the facade/model
      # Also we might need more information what is going wrong than just a true/false. Either with
      # exceptions or an error messages array?

      redirect_to runnings_url, notice: 'Running session successfully created'
    else
      flash[:notice] = 'Unable to create Running session'
      render :new
    end
  end


  def update
    @running = Facade::SportSession.find_by id: params[:id]

    if Date.parse(@running.entry_date) < Date.today

      # Save result
      @results = @running.sport_session_participants.where(:user_id => current_user.id).first!.result
      @results.length = results_params[:length]
      @results.time = results_params[:time]

      @results.save

      # TODO Check for achievements

      redirect_to runnings_url, notice: 'Saved details'

    else

      # Update entry
      entry_params = sport_session_params.merge({user: current_user, type: 'Running'})
      if @running.update(entry_params)
        redirect_to runnings_url, notice: 'Running session successfully updated'
      else
        render :edit
      end
    end
  end


  def destroy
    @session = Facade::SportSession.find_by id: params[:id]
    if @session.delete
      redirect_to sport_sessions_index_path, notice: 'Sport session was successfully destroyed.'
    else
      redirect_to sport_sessions_index_path, notice: 'Sport session cannot be removed.'
    end
  end

  def sport_session_params
    Hash[params[:sport_session].map {|k,v| [k.to_sym,v]}]
  end

  def results_params
    params[:results]
  end

end
