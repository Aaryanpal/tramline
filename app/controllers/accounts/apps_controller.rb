class Accounts::AppsController < ApplicationController
  before_action :set_app, only: %i[show index edit update]
  before_action :set_vcs_integration, only: [:show, :create_release_branch, :create_pull_request]

  def new
    @app = current_organization.apps.new
  end

  def create
    @app = current_organization.apps.new(app_params)

    respond_to do |format|
      if @app.save
        format.html { redirect_to accounts_organization_app_path(current_organization, @app), notice: "App was successfully created." }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @app.update(app_params)
        format.html { redirect_to accounts_organization_app_path(current_organization, @app), notice: "App was successfully updated." }
        format.json { render :show, status: :ok, location: @app }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_release_branch
    random_str = (0...8).map { rand(65..90).chr }.join

    begin
      Integrations::Github::Api
        .new(ENV["GITHUB_APP_ID"], @version_control_integration.installation_id)
        .create_branch!(@version_control_integration.active_repo, @app.working_branch, "release-v#{random_str}")
    rescue Octokit::UnprocessableEntity => e
      flash[:errors] = e.errors
      render :show, status: :unprocessable_entity
    end
  end

  def create_pull_request
    title = "PR generated by Tramline"
    body = "Automatically generated by Tramline. Good luck."

    begin
      Integrations::Github::Api
        .new(ENV["GITHUB_APP_ID"], @version_control_integration.installation_id)
        .create_pr!(@version_control_integration.active_repo, @app.working_branch, params[:pr_head], title, body)

      redirect_to accounts_organization_app_path(current_organization, @app), notice: "Successfully created a PR!"
    rescue Octokit::UnprocessableEntity => e
      flash.clear
      flash[:custom_errors] = e.errors.to_json
      render :show, status: :unprocessable_entity
    end
  end

  def edit

  end

  def show
  end

  def index
  end

  private

  def set_vcs_integration
    set_app
    @version_control_integration = @app.integrations.first
  end

  def set_app
    @app = current_organization.apps.friendly.find(params[:id])
  end

  def app_params
    params.require(:app).permit(:name, :description, :bundle_identifier, :working_branch)
  end
end
