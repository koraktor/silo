# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'pathname'

# Provides extensions to the Pathname class provided by Ruby's standard
# Library
class Pathname

  # Appends a path to this path and expands it
  #
  # @param [#to_s] path The path to append
  # @return [Pathname] The generated path
  def /(path)
    (self + path).expand_path
  end

end
