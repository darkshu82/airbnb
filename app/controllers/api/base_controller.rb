# app/controllers/api/base_controller.rb
class Api::BaseController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  private
end
