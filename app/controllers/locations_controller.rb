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

  def custom
    @selected_text = params.first #hash on the form {"SOCA TOGO - JAGO" => nil, "action" => "cutom", "controller" =>  "locations"}
    @attributes = Library.where(:name => @selected_text).to_json.sub('[{"library":', '').sub('}]', '')
    render :text => @attributes
  end

end
