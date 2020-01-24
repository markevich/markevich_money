# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

defmodule Helpers do
  def get_env(name) do
    case System.get_env(name) do
      nil -> raise "Environment variable #{name} is not set!"
      val -> val
    end
  end
end

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :markevich_money, MarkevichMoney.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :markevich_money, MarkevichMoneyWeb.Endpoint,
  https: [
    port: 443,
    cipher_suite: :strong,
    keyfile: Helpers.get_env("CO2_OFFSET_SSL_KEY_PATH"),
    cacertfile: Helpers.get_env("CO2_OFFSET_SSL_CACERT_PATH"),
    certfile: Helpers.get_env("CO2_OFFSET_SSL_CERT_PATH")
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :markevich_money, MarkevichMoneyWeb.Endpoint, server: true
config :nadia, token: Helpers.get_env("TELEGRAM_TOKEN")
config :markevich_money, mailgun_api_key: Helpers.get_env("MAILGUN_API_KEY")
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.