class TeamMailer < ApplicationMailer
  def team_mail(user)
    @user = user
      mail(to: @user.email, subject: "権限譲渡のお知らせ")
  end
end
