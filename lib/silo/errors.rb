# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

module Silo

  # Raised when trying to initialize a Silo repository in a path where another
  # Silo repository already exists.
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class AlreadyPreparedError < StandardError
  end

  # Raised when trying to restore files from a repository that do not exist.
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  # @see Repository#restore
  class FileNotFoundError < StandardError

    def initialize(path)
      super "File not found: '#{path}'"
    end

  end

  # Raised when trying to initializa a Silo repository in a path where another
  # Git repository exists, that contains non-Silo data.
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class InvalidRepositoryError < StandardError
  end

end
