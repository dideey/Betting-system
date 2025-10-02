defmodule AppWeb.AuthHTML do
  @moduledoc """
  This module contains pages rendered by AuthController.

  See the `auth_html` directory for all templates.
  """
  use AppWeb, :html

  embed_templates "auth_html/*"
end
