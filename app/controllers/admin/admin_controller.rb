class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin_user!
  helper_method :sort_column, :sort_direction

  def dashboard
    @members = current_economy.members
  end

  def authenticate_admin_user!
    unless current_user && current_user.is_admin?
      redirect_to root_path, alert: "You are not authorized to access this page" 
    end
  end

  def sort_column
    resource_class.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end