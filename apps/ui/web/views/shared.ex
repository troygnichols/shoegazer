defmodule Ui.Views.Shared do

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
    {:safe, ~s[<span class="badge badge-success">Yes</span>]}
  end
  def yes_no(false) do
    {:safe, ~s[<span class="badge badge-danger">No</span>]}
  end
end
