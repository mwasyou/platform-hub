class UsersController < ApiJsonController

  before_action :find_user, only: [ :show, :make_admin, :revoke_admin ]

  authorize_resource

  # GET /users
  def index
    @users = User.order(:name)

    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # GET /users/search/:q
  def search
    render json: User.search(params[:q])
  end

  # POST /users/:id/make_admin
  def make_admin
    @user.make_admin!

    AuditService.log(
      context: audit_context,
      action: 'make_admin',
      auditable: @user
    )

    head :no_content
  end

  # POST /users/:id/revoke_admin
  def revoke_admin
    @user.revoke_admin!

    AuditService.log(
      context: audit_context,
      action: 'revoke_admin',
      auditable: @user
    )
    
    head :no_content
  end

  private

  def find_user
    @user = User.find params[:id]
  end

end
