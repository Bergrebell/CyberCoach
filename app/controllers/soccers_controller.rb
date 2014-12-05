class SoccersController < ApplicationController

    # List all soccer sessions
    def index
      @all_confirmed_participants = current_user.confirmed_participants_of_all_sessions
      # If sessions must be filtered, use the passed params for filtering
      # display all running sessions otherwise, upcoming, past or unconfirmed, respectively.
      if params.count > 0
        @soccers_upcoming = current_user.sport_sessions_filtered(params, true, 'Soccer').select { |s| s.is_upcoming }
        @soccers_past = current_user.sport_sessions_filtered(params, true, 'Soccer').select { |s| s.is_past }
        @invitations = current_user.sport_sessions_filtered(params, false, 'Soccer')
      else
        soccers = current_user.sport_sessions_confirmed('Soccer')
        @soccers_upcoming = soccers.select { |s| s.is_upcoming }
        @soccers_past = soccers.select { |s| s.is_past }
        @invitations = current_user.sport_sessions_unconfirmed('Soccer')
      end
    end

    def new
      @soccer = Facade::SportSession.create(user: current_user, type: 'Soccer')
    end


    def edit
      @soccer = Facade::SportSession.find_by id: params[:id]
    end

    def show
      @soccer = Facade::SportSession.find_by id: params[:id]
    end


    # POST /runnings
    def create
      date_time_object = DateTime.strptime(params[:date], Facade::SportSession::DATETIME_FORMAT)
      entry_params = params.merge({user: current_user, type: 'Soccer', entry_date: date_time_object})
      entry_params = Hash[entry_params.map {|k,v| [k.to_sym,v]}]
      @entry = Facade::SportSession.create(entry_params)
      if @entry.save
        redirect_to soccers_url, notice: 'Soccer session successfully created'
      else
        flash[:notice] = 'Unable to create Soccer session'
        render :new
      end
    end


    def update
      @soccer = Facade::SportSession.find_by id: params[:id]
      entry_params = sport_session_params.merge({user: current_user, type: 'Soccer'})
      if @soccer.update(entry_params)
        redirect_to soccers_url, notice: 'Soccer session successfully updated'
      else
        render :edit
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


end
