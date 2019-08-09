class AgendasController < ApplicationController
  before_action :authenticate_user!,only: %i[destroy]
  before_action :set_agenda, only: %i[destroy]
  before_action :delete_authentication, only: %i[destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: 'アジェンダ作成に成功しました！'
    else
      render :new
    end
  end

  def destroy
    @team = Team.find(@agenda.team_id)
    @users = @team.members
    @agenda.destroy
    # AgendaMailer.agenda_mail(@users).deliver
    @users.each do |user|
      AgendaMailer.agenda_mail(user).deliver
    end

    redirect_to dashboard_url, notice: 'アジェンダ削除に成功しました！'
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

  def authenticate_team_owner
    # @team = Team.find(params[:team])
    current_user.assigns.team_id.each do |i|
      @current_user_team_id = current_user.assigns.team_id
    end
    if @agenda.team_id != @current_user_team_id
      # redirect_to teams_url, notice: 'オーナー以外は編集できません、、'
      # flash.now[:error] = 'オーナー以外は編集できません、、'
      redirect_to @team,notice: 'オーナー以外は編集できません、、'
    end
  end

  def delete_authentication
    @team = Team.find(@agenda.team_id)
    if @team.owner != current_user && @agenda.user != current_user
      redirect_to dashboard_url, notice: 'アジェンダのオーナーかアジェンダ作成者のチームオーナーでないと削除できません、、'
    end
  end
end
