class CommandRequestsController < ApplicationController
  before_action :set_command_request, only: [:show, :edit, :update, :destroy]

  # GET /command_requests
  # GET /command_requests.json
  def index
    @command_requests = CommandRequest.all
  end

  # GET /command_requests/1
  # GET /command_requests/1.json
  def show
  end

  # GET /command_requests/new
  def new

    @command_request = CommandRequest.new
  end

  # GET /command_requests/1/edit
  def edit
  end

  # POST /command_requests
  # POST /command_requests.json
  def create

    #@command_request.command_text = 'SSSXP11' if command_request_params.command_text == 'c'
    @command_request = CommandRequest.new(command_request_params)
    @command_request.command_text = case @command_request.command_text
                                      when 'cortar'
                                        'SSSXP11'
                                      when 'encender'
                                        'SSSXP10'
    end
    @command_request.user_id = current_user.id




    respond_to do |format|
      if @command_request.save
        format.html { redirect_to @command_request, notice: 'Command request was successfully created.' }
        format.json { render :show, status: :created, location: @command_request }
      else
        format.html { render :new }
        format.json { render json: @command_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /command_requests/1
  # PATCH/PUT /command_requests/1.json
  def update
    respond_to do |format|
      if @command_request.update(command_request_params)
        format.html { redirect_to @command_request, notice: 'Command request was successfully updated.' }
        format.json { render :show, status: :ok, location: @command_request }
      else
        format.html { render :edit }
        format.json { render json: @command_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /command_requests/1
  # DELETE /command_requests/1.json
  def destroy
    @command_request.destroy
    respond_to do |format|
      format.html { redirect_to command_requests_url, notice: 'Command request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_command_request
      @command_request = CommandRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def command_request_params
      params.permit(:device_id, :command_text)
    end
end
