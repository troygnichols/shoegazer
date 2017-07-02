defmodule Ui.EntryView do
  use Ui.Web, :view

  def unix_datetime(num) do
    case DateTime.from_unix(num) do
      {:ok, dt} -> dt
      _ -> "[Unknown]"
    end
  end
end
