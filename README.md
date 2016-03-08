# About

Mu is a simple, lightweight DSL for jump-starting your web apps in Ruby.

### An example controller
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

Prevent CSRF attacks by including the #verify_authenticity_token in your controller actions.

### An example model
    class Cat < MuRecord::Base
      belongs_to :owner, foreign_key: :owner_id, class_name: "Human"

      self.finalize!
    end

Creating associations is simple because of Mu's convention over configuration philosophy.


### An example of drawing routes in Mu
    MuApplication.router.draw do
      get Regexp.new("^/$"), SimpleController, :index
      get Regexp.new("^/new$"), SimpleController, :new
      post Regexp.new("^/$"), SimpleController, :create
    end

Enjoy custom middleware that serves up static assets and throws helpful errors with stack traces in development.

### Session

Store client user data as cookies using Mu's session dispatch. Simply call `session[:some_key] = val` in your controller.

### Flash

The flash is written into cookies much like the session, but in a special way so that it gets cleared with each request. If you prefer that a flash only persist within the same request, use `flash.now[:some_key] = val`

e.g.

    flash[:some_key] = "Thanks for signing up!"

or:

    flash.now[:some_key] = "Thanks for signing up!"

 ### Database configuration
 Currently only sqlite3 is supported by Mu. To define your app's schema, create a .sql file in the root directory. Ex:

     CREATE TABLE cats (
       id INTEGER PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       owner_id INTEGER,

       FOREIGN KEY(owner_id) REFERENCES human(id)
     );

Then, in your command line:

`cat db.sql | sqlite3 database.db`

 ### Static Assets

Serve static assets like images simply by including them in your app/public folder
