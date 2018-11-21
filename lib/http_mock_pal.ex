defmodule HttpMockPal do
  @moduledoc """
  otp entry point
  """
  use Application
  import Enum

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = configurations()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HttpMockPal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp configurations() do
    :http_mock_pal
    |> Application.get_env(:routers, [])
    |> reduce([], fn {router_module, opts}, acc ->
      with {:ok, port} <- Keyword.fetch(opts, :port) do
        [{router_module, port} | acc]
      else
        _ -> acc
      end
    end)
    |> map(fn {router_module, port} ->
      Plug.Cowboy.child_spec(scheme: :http, plug: router_module, options: [port: port])
    end)
  end
end
