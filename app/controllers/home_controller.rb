class HomeController < ApplicationController
  respond_to :json, :html

  skip_before_filter :verify_authenticity_token, :only => [:result]
  protect_from_forgery :except => :result

  SECRET_TOKEN_SANITY_ENV = ENV["SECRET_TOKEN_SANITY"]

  def index
    result = { success: true}
    respond_with result
  end

  def result 
    if params[:token] == SECRET_TOKEN_SANITY_ENV
      puts "hello           "
      trigger_ci_build
    end
    render nothing: true
  end

private
  def trigger_ci_build
    prepare_git_working_dir
    repo = Git.clone(sanity_features_github_url, 'sanity_features', :path => git_working_dir_base)
    message = touch_readme
    repo.add(all: true)
    repo.commit(message)
    repo.push("origin")
  end

  def git_working_dir_base
    Rails.root.join('tmp')
  end

  def git_working_dir
    File.join(git_working_dir_base, 'sanity_features')
  end

  def prepare_git_working_dir
    FileUtils.rm_rf(git_working_dir)
    FileUtils.mkdir_p(git_working_dir)
  end

  def sanity_features_github_url
    Rails.logger.info("https://#{ENV['GITHUB_AUTH_TOKEN']}@github.com/workato/sanity_features.git")
    "https://#{ENV['GITHUB_AUTH_TOKEN']}@github.com/workato/sanity_features.git"
  end

  def touch_readme
    "Build at #{Time.now}".tap do |message|
      File.open(File.join(git_working_dir, 'README.md'), 'w') do |file|
        file.puts(message)
      end
    end
  end
end
