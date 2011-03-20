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

    updated = files.select { |filename, mtime| self.last_mtime < mtime }

    # nothing to update or initially run
    unless updated.empty? || self.last_mtime.to_i == 0 then
      p updated if options[:verbose]

      hook :updated, updated
    end

    updated.map { |f,m| test_files_for f }.flatten.uniq.each do |filename|
      self.files_to_test[filename] # creates key with default value
    end

    if updated.empty? then
      nil
    else
      files.values.max
    end
  end

end
