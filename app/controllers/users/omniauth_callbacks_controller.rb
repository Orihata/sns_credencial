class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    callback_from :facebook
  end

  def google_oauth2
    callback_from :google
  end

  private

  # 上記"facebook" "google_oauth2"というコールバックメソッドでやってることについて説明します（facebook,google共通処理）
  def callback_from(provider)

    #callback_fromの引数（facebookとかgoogleとか）をstring型にします
    provider = provider.to_s

    # Userモデルにて、"self.find_for_oauth(auth)"っていうメソッドを定義しました
    # =>「SNSの情報をもとに、deviseのユーザを探して、それを返す」というメソッドでしたね

    @user = User.find_for_oauth(request.env['omniauth.auth'])
    
    # もしさっきのメソッドでユーザがみつかったならば、そのユーザでログインする（「ログインしました」画面に飛ぶ）
    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: provider.capitalize)
      sign_in_and_redirect @user, event: :authentication

    # ユーザが存在しなかったならば、取ってきたoauth認証情報を「devise.facebook_data」セッションに渡して、
    # Deviseでの新規登録画面にリダイレクトします（そっから先は自分でDeviseの機能を使ってアカウントを作ってねということ）
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end