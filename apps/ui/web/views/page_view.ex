defmodule Ui.PageView do
  use Ui.Web, :view

  def player_mark_watched_checked(conn) do
    IO.puts "cookies: #{inspect conn.cookies}"
    case conn.cookies["video_mark_watched"] do
      "true" -> "checked"
      _ -> ""
    end
  end

  def autoplay(_conn = %{params: %{"autoplay"=>_}}), do: "yes"
  def autoplay(_conn), do: "no"

end
