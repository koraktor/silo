# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

require 'rubygems'
require 'tmpdir'

require 'grit'

module Silo

  # Represents a Silo repository
  #
  # This provides the core features of Silo to initialize a repository and work
  # with it.
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class Repository

    # @return [Grit::Repo] The Grit object to access the Git repository
    attr_reader :git

    # Creates a new repository instance on the given path
    #
    # @param [Hash] options A hash of options
    # @option options [Boolean] :create (true) Creates the backing Git
    #         repository if it does not already exist
    # @option options [Boolean] :prepare (true) Prepares the backing Git
    #         repository for use with Silo if not already done
    #
    # @raise [Grit::InvalidGitRepositoryError] if the path exists, but is not a
    #        valid Git repository
    # @raise [Grit::NoSuchPathError] if the path does not exist and option
    #        :create is +false+
    # @raise [InvalidRepositoryError] if the path contains another Git
    #        repository that does not contain data managed by Silo.
    def initialize(path, options = {})
      options = {
        :create  => true,
        :prepare => true
      }.merge options

      @path = File.expand_path path

      if File.exist?(path)
        if Dir.new(path).count > 2
          unless File.exist?(File.join(path, 'HEAD')) &&
                 File.stat(File.join(path, 'objects')).directory? &&
                 File.stat(File.join(path, 'refs')).directory?
            raise Grit::InvalidGitRepositoryError.new(path)
          end
        end
        @git = Grit::Repo.new(path, { :is_bare => true })
      else
        if options[:create]
          @git = Grit::Repo.init_bare(path, {}, { :is_bare => true })
        else
          raise Grit::NoSuchPathError.new(path)
        end
      end

      if !prepared? && @git.commit_count > 0
        raise InvalidRepositoryError.new(path)
      end

      prepare if options[:prepare] && !prepared?
    end

    # Prepares the Git repository backing this Silo repository for use with
    # Silo
    #
    # @raise [AlreadyPreparedError] if the repository has been already prepared
    def prepare
      raise AlreadyPreparedError.new(@path) if prepared?
      Dir.mktmpdir do |tmp_dir|
        ENV['GIT_WORK_TREE'] = tmp_dir
        FileUtils.touch File.join(tmp_dir, '.silo')
        @git.add '.silo'
        @git.commit_index 'Enabled Silo for this repository'
        ENV['GIT_WORK_TREE'] = nil
      end
    end

    # Return whether the Git repository backing this Silo repository has
    # already been prepared for use with Silo
    #
    # @return The preparation status of the backing Git repository
    def prepared?
      !(@git.tree/'.silo').nil?
    end

  end

end
