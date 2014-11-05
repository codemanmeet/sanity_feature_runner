class HomeController < ApplicationController
  respond_to :json, :html

  def index
    result = { success: true}
    respond_with result
  end
end
