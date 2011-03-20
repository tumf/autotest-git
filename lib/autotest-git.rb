#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require "autotest"
require "git"

class AutotestGit < Autotest
  def git_update?
    git = Git.open(".")
    sha = git.object("HEAD").sha
    return false if sha == @sha
    @sha = sha
    true
  end

  def find_files_to_test files = find_files
    return nil unless git_update?
    puts "updated"

    super files
  end

  def self.runner
    style = options[:style] || AutotestGit.autodiscover
    target = AutotestGit

    unless style.empty? then
      mod = "autotest/#{style.join "_"}"
      puts "loading #{mod}"
      begin
        require mod
      rescue LoadError
        abort "AutotestGit style #{mod} doesn't seem to exist. Aborting."
      end
      target = AutotestGit.const_get(style.map {|s| s.capitalize}.join)
    end

    target
  end
end
