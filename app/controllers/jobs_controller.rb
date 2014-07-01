class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show

  end

  # GET /jobs/1/run
  def run
    @job = Job.find(params[:id])
  end

  def execute
    @job = Job.where(id: params[:id]).first

    # Queue up the job
    # job_class = Module.const_get(job_spec['class'])
    # uuid      = job_class.create(job_params)

    sleep 2
    if uuid
      redirect "/job_monitor/#{uuid}"
    else
      # flash[:error] = "Executing Job #{@job.name} failed"
      redirect "/jobs"
    end
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  def share_to
    @job  = Job.where(id: params[:job_id])
    @user = User.where(id: params[:user_id])
    @user.jobs << @job
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
        current_user.jobs << @job
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:name,
                                  :job_type,
                                  :spec,
                                  :description,
                                  :core,
                                  dependencies_attributes: [:id, :description, :lib, :_destroy],
                                  prompts_attributes: [:id, :label, :field_type, :_destroy])
    end
end
