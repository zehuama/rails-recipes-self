class Admin::EventRegistrationsController < AdminController
  before_action :find_event

  def index
    @q = @event.registrations.ransack(params[:q])
    @registrations = @q.result.includes(:ticket).order("id DESC").page(params[:page]).per(10)

    if Array(params[:statuses]).any?
      @registrations = @registrations.by_status(params[:statuses])
    end

    if Array(params[:ticket_ids]).any?
      @registrations = @registrations.by_ticket(params[:ticket_ids])
    end

    if params[:registration_id].present?
      @registrations = @registrations.where(:id => params[:registration_id].split(","))
    end

    if params[:start_on].present?
      @registrations = @registrations.where("created_at >= ?", Date.parse(params[:start_on]).beginning_of_day)
    end

    if params[:end_on].present?
      @registrations = @registrations.where("created_at <= ?", Date.parse(params[:end_on]).end_of_day)
    end

    if params[:status].present? && Registration::STATUS.include?(params[:status])
      @registrations = @registrations.by_status(params[:status])
    end

    if params[:ticket_id].present?
      @registrations = @registrations.by_ticket(params[:ticket_id])
    end
  end

  def new
  end

  def create
    @registration = @event.registrations.new
    if registration.save
      redirect_to step2_admin_event_registrations_path(@event)
    else
      render "new"
    end
  end

  def edit
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def update
    @registration = @event.registrations.find_by_uuid(params[:id])
    if @registration.update(registration_params)
      redirect_to admin_event_registrations_path(@event, @registration)
    else
      render "edit"
    end
  end


    # def create
    #   @registration = @event.registrations.new
    #   @registration.ticket = @event.tickets.find( params[:registration][:ticket_id] )
    #   @registration.status = "pending"
    #   @registration.current_step = 1
    #
    #   if @registration.save
    #     redirect_to step2_admin_event_registration_path(@event, @registration)
    #   else
    #     flash.now[:alert] = @registration.errors[:base].join("、")
    #     render "new"
    #   end
    # end

    # def show
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    # end
    #
    # def step1
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    # end
    #
    # def step1_update
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    #   @registration.current_step = 1
    #
    #   if @registration.update(registration_params)
    #     redirect_to step2_admin_event_registration_path(@event, @registration)
    #   else
    #     render "step1"
    #   end
    # end
    #
    # def step2
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    # end
    #
    # def step2_update
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    #   @registration.current_step = 2
    #
    #   if @registration.update(registration_params)
    #     redirect_to step3_admin_event_registration_path(@event, @registration)
    #   else
    #     render "step2"
    #   end
    # end
    #
    # def step3
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    # end
    #
    # def step3_update
    #   @registration = @event.registrations.find_by_uuid(params[:id])
    #   @registration.status = "confirmed"
    #   @registration.current_step = 3
    #
    #   if @registration.update(registration_params)
    #     flash[:notice] = "报名成功"
    #     redirect_to admin_event_registrations_path(@event)
    #   else
    #     render "step3"
    #   end
    # end

  def destroy
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.destroy
    redirect_to admin_event_registrations_path(@event)
  end

  protected

  def find_event
    @event = Event.find_by_friendly_id!(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(:status, :ticket_id, :name, :email, :cellphone, :website, :bio)
  end
end
