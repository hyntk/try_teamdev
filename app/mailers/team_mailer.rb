class TeamMailer < ApplicationMailer
  def team_mail(assign)
    @user = assign.users

    @user.each do |user|
      mail(to: user.email, subject: "権限譲渡のお知らせ")
    end
  end
end
