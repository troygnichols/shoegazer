defmodule Ui.WatchController do
  use Ui.Web, :controller

  def watch(conn, %{"entry_id"=>id}) do
    entry = get_entry(id)
    conn |> render "watch.html", entry: entry
  end

  def next_video(conn, params = %{"autoplay"=>autoplay}) do
    maybe_mark_entry_listened(params)
    entry = get_next_entry(params)
    conn
    |> update_cookies(params)
    |> redirect to: watch_path(conn, :watch, entry.id, make_params(params))
  end

  def prev_video(conn, params) do
    entry = get_prev_entry(params)
    conn
    |> redirect to: watch_path(conn, :watch, entry.id, make_params(params))
  end

  defp make_params(req_params) do
    new_params = case req_params["autoplay"] do
      "yes" -> [autoplay: "yes"]
      _ -> []
    end
  end

  defp get_entry(id) do
    GenServer.call(:db, {:fetch_entry, :id, id})
  end

  defp get_next_entry(%{"entry_id"=>id}) do
    GenServer.call(:db, {:next_entry, id, []})
  end

  defp get_prev_entry(%{"entry_id"=>id}) do
    GenServer.call(:db, {:prev_entry, id})
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
