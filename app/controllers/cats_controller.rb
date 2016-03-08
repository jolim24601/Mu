require_relative '../models/cat'

class CatsController < ControllerBase
  def index
    @cats = Cat.all
  end

  def create
    verify_authenticity_token
    @cat = Cat.new(name: params["name"], owner_id: params["owner_id"])
    @cat.save

    render :show
  end

  def show
    @cat = Cat.find(params["id"].to_i)
  end

  def new
  end
end
