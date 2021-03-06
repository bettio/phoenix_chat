defmodule PhoenixChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      PhoenixChatWeb.Endpoint,
      {Phoenix.PubSub.PG2, name: :chans},
      {DynamicSupervisor, strategy: :one_for_one, name: PhoenixChat.ChannelsSupervisor},
      PhoenixChat.Channels,
      PhoenixChat.IRC.Server,
      {DynamicSupervisor, strategy: :one_for_one, name: PhoenixChat.IRC.Connection.Supervisor},
      {Registry, name: PhoenixChat.UserRegistry, keys: :unique}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
