class AgendaMailer < ApplicationMailer
  def agenda_mail(users)
    @users = users
    mail(to: @users.email, subject: "アジェンダが削除されました！！")
    # @users.each do |user|
    #   mail(to: user.email, subject: "アジェンダが削除されました！！")
    # end
  end
end
