class UserAuthenticationsController < Devise::OmniauthCallbacksController
  before_filter :youtube, if: -> { request_is_youtube? }
  def gplus; create;  end
  def github; create; end

  def youtube
    token = request.env['omniauth.auth']['credentials']['token']
    current_user.update(youtube_id: Youtube.channel_id(token)) unless current_user.youtube_id?
    redirect_to(request.env['omniauth.origin'] || root_path)
  end

  def create
    auth_params = request.env["omniauth.auth"]
    provider = AuthenticationProvider.where(name: auth_params['provider']).first
    authentication = provider.user_authentications.where(uid: auth_params["uid"]).first
    existing_user = current_user || User.where('email = ?', auth_params['info']['email']).first

    if authentication
      sign_in_with_existing_authentication(authentication.user)
    elsif existing_user
      create_authentication_and_sign_in(auth_params, existing_user, provider)
    else
      create_user_and_authentication_and_sign_in(auth_params, provider)
    end
  end

  def destroy
    provider = AuthenticationProvider.find_by_name(params[:provider])
    UserAuthentication.destroy_all(user_id: current_user.id, authentication_provider_id: provider.id)
    redirect_to edit_user_registration_path, notice: 'Successfully removed profile.'
  end

  private

  def request_is_youtube?
    request.env['omniauth.params']['youtube']
  end

  def sign_in_with_existing_authentication(user)
    sign_in(:user, user)
    redirect_to root_path, notice: 'Signed in successfully.'
  end

  def create_authentication_and_sign_in(auth_params, user, provider)
    UserAuthentication.create_from_omniauth(auth_params, user, provider)
    sign_in_with_existing_authentication(user)
  end

  def create_user_and_authentication_and_sign_in(auth_params, provider)
    user = User.create_from_omniauth(auth_params)
    if user.valid?
      create_authentication_and_sign_in(auth_params, user, provider)
    else
      redirect_to new_user_registration_url, error: user.errors.full_messages.first
    end
  end
end