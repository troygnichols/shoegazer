defmodule Ui.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", entry: get_entry()
  end

  def next_video(conn, params) do
    maybe_mark_entry_listened(params)
    conn
    |> update_cookies(params)
    |> redirect to: page_path(conn, :index, autoplay: "yes")
  end

  defp get_entry do
    GenServer.call(:db, {:earliest_entry, listened: false})
  end

  defp maybe_mark_entry_listened(%{"video_mark_watched"=>_, "entry_id"=>id}) do
    GenServer.call(:db, {:mark_entry_listened, id})
  end
  defp maybe_mark_entry_listened(_), do: nil

  defp update_cookies(conn, %{"video_mark_watched"=>_}) do
    conn |> put_resp_cookie("video_mark_watched", "true")
  end
  defp update_cookies(conn, _params) do
    conn |> put_resp_cookie("video_mark_watched", "false")
  end

end
