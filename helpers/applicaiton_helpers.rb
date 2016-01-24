module ApplicationHelpers
  def authenticated?
    !session[:ig_access_token].nil?
  end

  def authenticate!
    redirect '/' unless authenticated?
  end

  def current_user
    insta_client.user if insta_client
  end

  def insta_client
    @insta_client = Instagram.client(access_token: session[:ig_access_token]) if authenticated?
  end
end
