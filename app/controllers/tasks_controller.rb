class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher_role

  def index
    @tasks = Task.all
  end

  def show
    task
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.create(task_params.merge(
      creator_id: current_user.id,
      task_type: Task::TASK_TYPE_IOFILES))

    if @task.present?
      api = GraderApi.new
      response = api.add_task(@task)

      if response["status"] == 0
        @task.update_attribute(:external_key, response["task_id"])
        redirect_to task_path(@task), notice: "New task '#{ @task.title } created."
      else
        flash[:alert] = "Failed to upload task data. Message: %s" % [response["message"]]
        render 'new'
      end
    else
      flash[:alert] = "Failed to create new task"
      render 'new'
    end
  end

  def edit
    task
  end

  def update
    if task.update_attributes(task_params)
      api = GraderApi.new
      response = api.update_task(task)

      if response["status"] == 0
        task.update_attribute(:external_key, response["task_id"])
        redirect_to task_path(task), notice: "Task '#{ task.title } was updated."
      else
        flash[:alert] = "Failed to upload task data. Message: %s" % [response["message"]]
        render 'edit'
      end
    else
      flash[:alert] = "Failed to update task '#{ task.title }'"
      render 'edit'
    end
  end

  def destroy
    task.destroy

    redirect_to tasks_path, notice: "Task was deleted successfully"
  end

  def solve
    task
    @run = nil
  end

  def do_solve
    result = SolveTask.new(task, current_user, params).call

    if result.status
      redirect_to solve_task_path(task), notice: result.message
    else
      redirect_to solve_task_path(task), alert: result.message
    end
  end

  def runs
    @task_runs = task.task_runs.newest_first
  end

  protected

  def task
    @task ||= Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :markdown_description, :visible, :memory_limit_kb, :time_limit_ms)
  end
end