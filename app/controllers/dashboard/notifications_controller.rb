class Dashboard::NotificationsController < Dashboard::SecureController
  before_action :set_notification, only: [:show, :destroy, :mark_as_read, :mark_as_unread]

  def index
    @notifications = current_user.notifications
                                .recent
                                .includes(:user)
                                .page(params[:page])
                                .per(20)

    @unread_count = current_user.notifications.unread.count
  end

  def show
    @notification.mark_as_read! if @notification.unread?
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: 'Notification deleted.'
  end

  def mark_as_read
    @notification.mark_as_read!
    respond_to do |format|
      format.json { render json: { status: 'read' } }
      format.html { redirect_to notifications_path }
    end
  end

  def mark_as_unread
    @notification.mark_as_unread!
    respond_to do |format|
      format.json { render json: { status: 'unread' } }
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    respond_to do |format|
      format.json { render json: { status: 'all_read' } }
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
    end
  end

  def dropdown_content
    @notifications = current_user.notifications
                                .recent
                                .limit(10)
                                .includes(:user)

    @unread_count = current_user.notifications.unread.count

    render partial: 'dropdown_content'
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end