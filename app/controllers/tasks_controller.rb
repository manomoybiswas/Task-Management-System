class TasksController < ApplicationController
  include TasksHelper
  before_action :authenticate_user!
  before_action :check_user_is_hr, only: [:print]
  before_action :check_user_is_hr?, except: [:index, :show]
  before_action :category_list, :employee_list, only: [:new, :create, :edit, :update]
  before_action :set_task, except: [:index, :submit_subtask, :create, :new] 
  before_action :index
  # before_action :set_priority_task

  def index
    # @priority= params[:priority]
    # unless @priority == "All"
      unless current_user.admin || current_user.hr
          @Tasks_list =  current_user.tasks
      else
          @Tasks_list =  Task.all    
      end
    # else
    #   unless current_user.admin || current_user.hr
    #     @Tasks_list =  current_user.tasks
    #   else
    #     @Tasks_list =  Task.all
    #   end
    # end
  end
  
  # def index
  #   unless current_user.admin || current_user.hr
  #     @Tasks_list =  current_user.tasks
  #   else
  #     @Tasks_list =  Task.all
  #   end
  # end

  def submit_task
    unless SubTask.all_subtasks_submitted(@task)
      flash[:warning] = I18n.t "task.submit_task.failed"
      redirect_to request.referrer
      return
    end

    @task.submit = true
    @task.save
    flash[:success] = I18n.t "task.submit_task.success"
    redirect_to request.referrer
  end
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    @subtask.submit = true
    @subtask.save
    flash[:success] = I18n.t "task.submit_subtask.success", subtask: @subtask.name
    redirect_to task_path(@subtask.task_id)
  end
  def approve
    unless @task.submit
      flash[:warning] = "Employee not Submitted the task yet."
      redirect_to request.referrer
      return
    end
    @task.approved = true
    @task.save(validate: false)
    flash[:success] = I18n.t "task.approve.success"
    redirect_to request.referrer
  end

  def download
    send_file ("#{Rails.root}/public#{@task.document.url.rpartition("?").first}"),
    filename: @task.document_file_name,
    type: @task.document_content_type,
    disposition: 'attachment'
  end

  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    @task.assign_task_by = current_user.id
    @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true
    end
    if @task.save
      Notification.create(recipient: @task.user, user: current_user, action: "assigned", notifiable: @task)
      flash[:success]= I18n.t "task.success", taskname: @task.task_name, taskid: @task.id
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.faild"
      render "new"
    end
  end


  def edit
  end

  def update
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true unless @task.submit
    else
      @task.recurring_task = false
    end
    @task.submit_date = task_params[:submit_date].to_datetime

    if @task.update(task_params)
      flash[:success] = I18n.t "task.update_success", taskname: @task.task_name
      redirect_to task_path(@task)
    else
      flash[:danger] = I18n.t "task.failed"
      render "edit"
    end
  end

  def show
  end

  def destroy
    taskname= " id: " + @task.id.to_s + " " + @task.task_name 
    @task.destroy
    flash[:success] = I18n.t "task.destroy", task: taskname
    redirect_to tasks_path
  end

  private
  def category_list
    @categories ||= Category.all
  end
  def employee_list
    @users ||= User.all_except(current_user)
  end
  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat, :document,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy))
  end
  def set_task 
    @task = Task.find(params[:id])
  end
  # def set_priority_task
  #   @priority_task= Task.find_by_priority(params[:priority])
  # end
end
