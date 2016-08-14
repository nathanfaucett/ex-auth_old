defmodule Auth.Services.User.AuthorizedPassword do
  alias Comeonin.Bcrypt
  import Auth.Gettext


  def prop_types do
    %{
      "locale" => PropTypes.required(PropTypes.string),
      "email" => PropTypes.required(PropTypes.string),
      "password" => PropTypes.required(PropTypes.string)
    }
  end

  def call(params) do
    errors = PropTypes.check(params, prop_types, "#{__MODULE__}")

    if errors != nil do
      {:error, errors}
    else
      Gettext.put_locale(Auth.Gettext, Map.get(params, "locale"))

      email = Map.get(params, "email")
      user = Auth.Repo.get_by(Auth.Models.User, email: email)

      if !user do
        {:error, %{"errors" => [RuntimeError.exception(gettext("user_not_found"))]}}
      else
        password = Map.get(params, "password")

        if Bcrypt.checkpw(password, Map.get(user, :encrypted_password)) == true do
          {:ok, user}
        else
          {:error, %{"errors" => [RuntimeError.exception(gettext("invalid_password"))]}}
        end
      end
    end
  end
end