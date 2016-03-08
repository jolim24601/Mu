MuApplication.router.draw do
  get Regexp.new("^/$"), SimpleController, :index
  get Regexp.new("^/new$"), SimpleController, :new
  post Regexp.new("^/$"), SimpleController, :create
end
