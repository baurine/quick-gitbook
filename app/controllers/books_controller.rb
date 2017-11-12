require 'net/http'
require 'open3'

class BooksController < ApplicationController
  def index
    render plain: 'coming soon'
  end

  def show
    @user = params[:user]
    @repo = params[:repo]
    @error = []

    # step 1: check whether @user is enable
    # you can enable all users repo or just yourself repo
    # you can config it in an .yml file
    allowed_users = USERS_WHITELIST['users']
    if !allowed_users.include?('*') && !allowed_users.include?(@user)
      @error << "Sorry, the user #{@user} is not allowed."
      return
    end

    # step 2: check "https://github.com/#{@user}/#{@repo}/blob/master/SUMMARY.md" exists?
    summary_url = "https://github.com/#{@user}/#{@repo}/blob/master/SUMMARY.md"
    uri = URI(summary_url)
    res = Net::HTTP.get_response(uri)
    unless res.is_a?(Net::HTTPSuccess)
      @error << "Error: #{res.message}."
      @error << "This repo doesn't exist in github or doesn't contain a SUMMARY.md file."
      return
    end

    # step 3: check folder "public/books/#{@user}" exists? if not, create it
    Dir.chdir(Rails.public_path)
    user_path = "books/#{@user}"
    FileUtils.mkdir_p(user_path) unless Dir.exists?(user_path)
    Dir.chdir(user_path)

    # step 4: clone or update repo, rebuild book if need
    re_build = true
    if Dir.exists?(@repo)
      Dir.chdir(@repo)
      `get checkout master`
      `git fetch origin`
      re_build = false if `git rev-parse HEAD` == `git rev-parse origin/master`
      if re_build
        `git checkout origin/master`
        `git branch -f master HEAD`
        `git checkout master`
      end
    else
      # git clone
      repo_url = "git@github.com:#{@user}/#{@repo}.git"
      `git clone #{repo_url}`
      Dir.chdir(@repo)
    end
    re_build = true unless Dir.exists?('_book')
    # gitbook build
    # `gitbook build` if re_build
    if re_build
      # http://blog.honeybadger.io/capturing-stdout-stderr-from-shell-commands-via-ruby/
      # https://blog.bigbinary.com/2012/10/18/backtick-system-exec-in-ruby.html
      stdout, stderr, status = Open3.capture3("gitbook build")
      if status.exitstatus != 0
        (render plain: stderr + stdout) && return
      end
    end

    # final
    book_url = "/books/#{@user}/#{@repo}/_book/"
    redirect_to book_url
  end
end
