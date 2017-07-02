defmodule Ui.Views.Shared do

  def next_page(_conn = %{params: %{"page"=>current_page}}) do
    String.to_integer(current_page) + 1
  end
  def next_page(_conn), do: 2

  def prev_page(_conn = %{params: %{"page"=>current_page}}) do
    String.to_integer(current_page) - 1
  end

  def per_page(_conn = %{params: %{"per_page"=>per_page}}), do: per_page
  def per_page(_conn), do: 10

  def twitter_url(twitter_id) do
    screen_name = GenServer.call(:db, :screen_name)
    "https://twitter.com/#{screen_name}/status/#{twitter_id}"
  end

  def unix_datetime(num, format \\ nil) do
    case DateTime.from_unix(num) do
      {:ok, dt} -> dt |> format_datetime(format)
      _ -> "[Unknown]"
    end
  end

  def format_datetime(datetime, nil), do: datetime

  def format_datetime(datetime, format) do
    case Timex.format(datetime, format, :strftime) do
      {:ok, formatted} -> formatted
      _ -> datetime
    end
  end

  def yes_no(true) do
    {:safe, ~s[<span class="badge badge-pill badge-success">Yes</span>]}
  end
  def yes_no(false) do
    {:safe, ~s[<span class="badge badge-pill badge-danger">No</span>]}
  end
end
