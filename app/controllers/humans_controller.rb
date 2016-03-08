require_relative '../models/human'

class HumansController < ControllerBase
  def new
  end

  def index
    @humans = Human.all
  end

  def create
    verify_authenticity_token
    @human = Human.new(fname: params["fname"], lname: params["lname"])
    @human.save

    render :show
  end

  def show
    @human = Human.find(params["id"].to_i)
  end
end
