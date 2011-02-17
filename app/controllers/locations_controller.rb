class LocationsController < ApplicationController

  def index
    @locations = Location.all
  end

  def edit
    @locations = Location.find(params[:id])
    @libraries = Library.where("name ILIKE '%#{@locations.name}%'")
  end

  def update
    @library = Library.find(params[:post][:library_id])
    Location.find(params[:id]).update_attributes(:address => @library.address,
                                                :telephone => @library.telephone,
                                                :fax => @library.fax,
                                                :email => @library.email,
                                                :website => @library.website)
    flash[:notice] = "Successfully updated location."
    redirect_to locations_path
  end
end
