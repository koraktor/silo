# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

require 'tmpdir'

require 'helper'

class TestRepository < Test::Unit::TestCase

  context 'A new backup repository' do

    setup do
      @dir = Dir.mktmpdir
      Dir.rmdir @dir
    end

    should 'contain a bare Git repository prepared for Kaartong by default' do
      rep = Repository.new @dir
      assert rep.git.is_a? Grit::Repo
      assert rep.prepared?
    end

    should 'contain a plain Git repository when option :prepare is false' do
      rep = Repository.new @dir, :prepare => false
      assert rep.git.is_a? Grit::Repo
      assert !rep.prepared?
    end

    should 'fail when option :create is false and the target directory does not exist' do
      assert_raise Grit::NoSuchPathError do
        Repository.new @dir, :create => false
      end
    end

    should 'fail if the target directory exists but is not an empty Git repository' do
      assert_raise Grit::InvalidGitRepositoryError do
        Repository.new File.dirname(__FILE__)
      end

      assert_raise InvalidRepositoryError do
        Repository.new File.join(File.dirname(File.dirname(__FILE__)), '.git')
      end
    end

  end

  context 'An existing backup repository' do

    setup do
      @repo_dir = Dir.mktmpdir
      `git init --bare #{@repo_dir}`
      ENV['GIT_DIR'] = @repo_dir
      ENV['GIT_WORK_TREE'] = File.expand_path '.'
      FileUtils.touch '.silo'
      `git add .silo`
      `git commit -m "Enabled Silo for this repository"`
      ENV['GIT_WORK_TREE'] = nil
      @repo = Repository.new @repo_dir
    end

    should 'contain a Git repository' do
      assert @repo.git.is_a? Grit::Repo
    end

    should 'be prepared' do
      assert @repo.prepared?
    end

    should 'not allow re-preparing the repository' do
      assert_raise AlreadyPreparedError do
        @repo.prepare
      end
    end

    teardown do
      FileUtils.rm_rf [@repo_dir, '.silo'], :secure => true
    end

  end

end
