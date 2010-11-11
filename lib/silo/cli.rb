# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

require 'rubygems'
require 'rubikon'

module Silo

  # This class is a Rubikon application that implements the command-line
  # interface for Silo
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class CLI < Rubikon::Application::Base

    set :help_banner, 'Usage: silo'

    default do
      puts "This is Silo. A Git-based backup utility.\n\n"
      call :help
    end

    command :init, 0..1, 'Initialize a Silo repository' do
      args[0] = File.dirname(__FILE__) if args[0].nil?
      puts "Initializing Silo repository in #{File.expand_path args[0]}..."
      Repository.new args[0]
    end

  end

end
