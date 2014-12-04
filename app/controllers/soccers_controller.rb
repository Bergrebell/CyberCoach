class SoccersController < ApplicationController

    # List all soccer sessions
    def index
      @soccers = Facade::SportSession.where(user_id: current_user.id, type: 'Soccer')
      @friends = current_user.friends
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
