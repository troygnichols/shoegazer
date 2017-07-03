defmodule Ui.Router do
  use Ui.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Ui do
    pipe_through :browser # Use the default browser stack

    # TODO: put behind basic auth
    get "/", PageController, :index
    post "/next_video", PageController, :next_video

    resources "/entries", EntryController, only: [:index, :show, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ui do
  #   pipe_through :api
  # end
end
