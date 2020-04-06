module ApplicationHelper

  def full_title(page_title = "")
    base_title = "Task Management System"

    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def check_user_is_admin
    unless admin?
      flash[:warning] = I18n.t "application.only_admin"
      redirect_to root_path
    end
  end
end