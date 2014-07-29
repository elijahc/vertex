class RunsController < ApplicationController
  before_action :set_run, only: [:start, :show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /runs
  # GET /runs.json
  def index
    @runs = Run.all
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
  end

  # GET /runs/new
  def new
    @run = Run.new
  end

  # GET /runs/1/edit
  def edit
  end

  # POST /runs
  # POST /runs.json
  def create
    # Grab resources needed to build run
    @job  = Job.find(run_params[:job_id])
    @user = User.find(run_params[:user_id])
    @run  = Run.new(run_params.slice('job_id'))

    # Store prompt values
    @job.prompts.each do |p|
      pv_hash = {
        run:     @run,
        prompt:  p,
      }

      case p.field_type
      when "file_field"
        pv_hash[:file]=params[p.label]
        pv_hash[:value]=params[p.label].original_filename
      else
        pv_hash[:value]=params[p.label]
      end

      pv = PromptValue.new(pv_hash)

      unless pv.save
        ap pv
        ap pv.errors.full_messages
      end

    end

    respond_to do |format|
      if @run.save
        # Start the run
        format.html { redirect_to start_run_path(@run), notice: 'Run was successfully created.' }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  def start
    options = @run.inputs.merge({:run_id => @run.id})
    uuid = @run.start(options)
    respond_to do |format|
      if @run.uuid = uuid
        format.html { redirect_to @run, notice: 'Run was started successfully' }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :show }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runs/1
  # PATCH/PUT /runs/1.json
  def update
    respond_to do |format|
      if @run.update(run_params)
        format.html { redirect_to @run, notice: 'Run was successfully updated.' }
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1
  # DELETE /runs/1.json
  def destroy
    @run.destroy
    respond_to do |format|
      format.html { redirect_to runs_url, notice: 'Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run
      @run = Run.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      #params.require(:run).permit(*Prompt.all.map{|p| p.attributes['label'].to_sym})
      params.require(:run).permit(:job_id, :user_id)
    end
end
