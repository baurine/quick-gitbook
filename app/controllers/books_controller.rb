class BooksController < ApplicationController
  def show
    @user = params[:user]
    @repo = params[:repo]
    puts "#{@user} ---- #{@repo}"
  end
end
