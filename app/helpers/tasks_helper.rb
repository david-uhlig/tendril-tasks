module TasksHelper
  def task_form_url(task_form)
    task_form.task.persisted? ? task_path(task_form.task) : tasks_path
  end

  def task_form_method(task_form)
    task_form.task.persisted? ? :patch : :post
  end
end
