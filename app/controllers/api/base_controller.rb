# app/controllers/api/base_controller.rb
class Api::BaseController < ApplicationController
  include Authenticatable
  respond_to :json

  private
end
