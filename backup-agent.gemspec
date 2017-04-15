# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path("../lib/backup-agent/version", __FILE__)

Gem::Specification.new do |s|
  s.name            = "backup-agent"
  s.version         = "2.0.0"
  s.authors         = ["Yaroslav Konoplov"]
  s.email           = ["eahome00@gmail.com"]
  s.summary         = "Easy AWS S3 backup"
  s.description     = "Easy AWS S3 backup"
  s.homepage        = "http://github.com/yivo/backup-agent"
  s.license         = "MIT"

  s.files           = `git ls-files -z`.split("\x0")
  s.test_files      = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  s.require_paths   = ["lib"]

  s.add_dependency "aws-sdk",                "~> 2"
  s.add_dependency "activesupport",          ">= 3.0", "< 6.0"
  s.add_dependency "method-not-implemented", "~> 1.0"
end
