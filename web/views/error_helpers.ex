# Copyright 2016 Ingage Partners
#
# This file is part of Contributr.
#
# Contributr is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Contributr is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

defmodule Contributr.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.errors[field] do
      content_tag :span, translate_error(error), class: "help-block"
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
     # Because error messages were defined within Ecto, we must
     # call the Gettext module passing our Gettext backend. We
     # also use the "errors" domain as translations are placed
     # in the errors.po file.
     # Ecto will pass the :count keyword if the error message is
     # meant to be pluralized.
     # On your own code and templates, depending on whether you
     # need the message to be pluralized or not, this could be
     # written simply as:
     #
     #     dngettext "errors", "1 file", "%{count} files", count
     #     dgettext "errors", "is invalid"
     #
     if count = opts[:count] do
       Gettext.dngettext(Contributr.Gettext, "errors", msg, msg, count, opts)
     else
       Gettext.dgettext(Contributr.Gettext, "errors", msg, opts)
     end
   end

  
  def translate_error(msg) do
    Gettext.dgettext(Contributr.Gettext, "errors", msg)
  end
end
