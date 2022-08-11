class UsersController < ApplicationController

  def create
    if current_token.is_firebase_token?
      user = User.find_or_create_by(firebase_user_id: current_token.firebase_data['user_id']) do |created|
        unless created.token
          created.token = Token.create
        end
        created.email = get_email_from_firebase_data
      end
      return render json: user.to_h.merge({ token: { id: user.token.id, value: user.token.value } })
    end

    permitted = params.permit(:email, :name)
    user = User.create!(permitted)
    debugger
    return render nothing: true, status: 400 unless user.valid?

    render json: user.to_h.merge({ token: Token.create })
  rescue ActiveRecord::RecordNotUnique
    render json: { message: "Can't create user. Already exists" }, status: 403
  rescue ActiveRecord::ActiveRecordError, ActiveModel::ForbiddenAttributesError => e
    render json: { message: "Can't create user." }, status: 400

  end

  def update
    user = User.find(params[:id])
    user.update(params.permit(:name, :email, :lang, :time_unit))

    return render nothing: true, status: 400 unless user.valid?

    render json: user.to_h, status: :ok
  rescue ActiveRecord::ActiveRecordError, ActiveModel::ForbiddenAttributesError => e
    render json: { message: "Can't update User" }, status: 403
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
    render json: { message: 'success' }, status: :ok
  end

  def show
    @user = User.find(params[:id])
    render json: @user.to_h, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'User does not exist' }, status: 403
  end

  def login
    user = if current_token.is_firebase_token?
             current_token.user_from_firebase_data
           else
             current_login_user
           end

    console.log('user: ', user)
    
    raise EntityNotFound, 'User' unless user

    unless user.token
      token = Token.create
      user.token = token
    end

    render json: user.to_h.merge({ token: { id: user.token.id, value: user.token.value } })
  end

  private

  def current_login_user
    raise EntityNotFound, 'User' unless current_token.user.present?

    current_token.user
  end

  def get_email_from_firebase_data
    if current_token.firebase_data['email_verified']
      current_token.firebase_data['email']
    else
      current_token.firebase_data.dig('firebase', 'identities', 'email')&.first
    end
  end
end