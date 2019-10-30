class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, 
         omniauth_providers: %i[facebook]

  has_one :sns_credential


  #DeviseのユーザをSNSからの情報をもとに探して返すメソッド
  def self.find_for_oauth(auth)
  # ログインする用のSNSを探す(authには、OAuth認証先のSNSからのユーザ情報が入っている。)
  sns = SnsCredential.where(uid: auth.uid, provider: auth.provider).first
  # ログインする用のSNSが存在しない場合
    unless sns
    # まずはUserを作る
      user = User.create(
    # Userのemailは、oauth先で登録されているユーザデータのemailで登録する
      email: auth.info.email,
    # PWは、Devise側で適当に生成する 
      password: Devise.friendly_token[0,20]
      )
    # 続いて、作ったユーザをもとに、SNS認証用の情報を作る
      sns = SnsCredential.create(
    # UserのIDに紐付けする用の外部キーを入力
      user_id: user.id,
    # oauth認証用のユーザのID
      uid: auth.uid,
    # oauthをするSNSを指定する（facebookかgoogleか）
      provider: auth.provider
      )
    end
  #ログインする用のSNSが存在する（もしくは上記過程で新規作成した）ならば、sns情報とuserインスタンス変数をreturnする（以下２行）
  return sns.user
  end

end
