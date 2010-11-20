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
  # @see Repository#restore
  # @since 0.1.0
  class FileNotFoundError < StandardError

    # Creates an instance of FileNotFoundError for the given file path
    #
    # @param [String] path The path of the file that does not exist in the
    #        repository
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

  # Raised when trying to access a remote by name that has no been defined for
  # the repository
  #
  # @author Sebastian Staudt
  # @see Remote
  # @since 0.1.0
  class UndefinedRemoteError < StandardError

    # Creates an instance of UndefinedRemoteError for the given name
    #
    # @param [String] name The name of the undefined remote
    def initialize(name)
      super "No remote with name '#{name}' defined."
    end

  end

end
