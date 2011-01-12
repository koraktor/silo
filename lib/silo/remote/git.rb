# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'silo/remote/base'

module Silo

  module Remote

    # This class represents a standard Git remote attached to the Git
    # repository backing the Silo repository
    #
    # @see Repository
    class Git < Base

      # Creates a new Git remote
      #
      # @param [Repository] repo The Silo repository this remote belongs to
      # @param [String] name The name of the remote
      # @param [String] url The URL of the remote Git repository. This may use
      #        any protocol supported by Git (+git:+, +file:+, +http(s):+)
      def initialize(repo, name, url)
        super repo, name

        @url = url
      end

      # Adds this remote as a mirror to the backing Git repository
      def add
        @repo.git.git.remote({}, 'add', '--mirror', @name, @url)
      end

      # Pushes the current history of the repository to the remote repository
      # using `git push`
      def push
        @repo.git.git.push({}, @name)
      end

      # Removes this remote from the backing Git repository
      def remove
        @repo.git.git.remote({}, 'rm', @name)
      end

    end

  end

end
