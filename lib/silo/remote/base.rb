# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Silo

  module Remote

    # This class represents a standard Git remote attached to the Git
    # repository backing the Silo repository
    class Base

      # @return [String] The name of this remote
      attr_reader :name

      # @return [String] The URL of this remote
      attr_reader :url

      # Creates a new remote with the specified name
      #
      # @param [Repository] repo The Silo repository this remote belongs to
      # @param [String] name The name of the remote
      def initialize(repo, name)
        @name = name
        @repo = repo
      end

    end

  end

end
