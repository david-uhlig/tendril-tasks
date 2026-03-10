class RefactorNewTaskApplicationNotifier < ActiveRecord::Migration[8.1]
  OLD_CLASS_NAME = "NewTaskApplicationNotifier"
  NEW_CLASS_NAME = "TaskApplicationReceivedNotification"

  def up
    Noticed::Event.where(type: OLD_CLASS_NAME).update_all(type: NEW_CLASS_NAME)
    Noticed::Notification.where(type: "#{OLD_CLASS_NAME}::Notification").update_all(type: "#{NEW_CLASS_NAME}::Notification")
  end

  def down
    Noticed::Event.where(type: NEW_CLASS_NAME).update_all(type: OLD_CLASS_NAME)
    Noticed::Notification.where(type: "#{NEW_CLASS_NAME}::Notification").update_all(type: "#{OLD_CLASS_NAME}::Notification")
  end
end
