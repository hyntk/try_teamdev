class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy authority]
  before_action :authenticate_team_owner, only: %i[update authority]


  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'チーム更新に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'チーム削除に成功しました！'
  end

  def authority
    user_id = params[:user_id]
    @user = User.find(user_id)
    if @team.update(owner_id:user_id)
      TeamMailer.team_mail(@user).deliver
      redirect_to @team, notice: 'チームオーナーの権限移譲に成功しました！'
    else
      flash.now[:error] = 'チームオーナーの権限移譲に失敗しました、、'
      render :edit
    end
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

  def authenticate_team_owner
    # @team = Team.find(params[:team])
    if @team.owner != current_user
      # redirect_to teams_url, notice: 'オーナー以外は編集できません、、'
      # flash.now[:error] = 'オーナー以外は編集できません、、'
      redirect_to @team,notice: 'オーナー以外は編集できません、、'
    end
  end    
end
