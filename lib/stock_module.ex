defmodule StockModule do
  @moduledoc """
  Documentation for `StockModule`.
  """

  @doc """
  Fetch price information for given `stock_symbol` from Alpha Vantage API using the provided `api_key` for the last `interval` minutes.

  Returns a list of prices with the following pattern: `[open_price, high_price, low_price, close_price]`.

  ## Examples

      iex> StockModule.fetch_current_prices "IBM", "demo"

  """
  def fetch_current_prices stock_symbol, interval, api_key do
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY_EXTENDED&symbol=#{stock_symbol}&interval=#{interval}min&slice=year1month1&apikey=#{api_key}"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        chuncked_body_list = parse_body_to_chuncked_list body
        try do
          extract_current_prices(chuncked_body_list)
        rescue _err -> IO.puts("API returned an empty body. Please, review your request and make sure you are providing valid arguments.") end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts reason
    end
  end

  defp parse_body_to_chuncked_list body do
    body
    |> String.split(",")
    |> Enum.chunk_every(6)
  end

  defp extract_current_prices(chuncked_body_list) do
    [_head, current_prices | _tail] = chuncked_body_list
    [open, high, low, close | _tail] = current_prices
    [open, high, low, close]
  end


end
