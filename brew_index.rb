PREFIX = "ruby193-rubygem-"
PREFIX_DEP = "ruby193-rubygem("

require 'yaml'
require 'pp'

$: << "./lib"
require 'bundler'
require './spec/support/builders'
require './spec/support/indexes'

include Spec::Builders

LOOKUP = {0 => "", 2 => "<", 4 => ">", 8 => "=", 10 => "<=", 12 => ">="}

packages = YAML.load_file(File.expand_path("./packages.yml"))

index = build_index do
  packages.each do |package|
    name    = package["package_name"].split(PREFIX).last
    version = package["version"]

    gem name, [version] do
      package["dependencies"].each do |d|
        next unless d["name"].start_with?(PREFIX_DEP)

        dep_name    = d["name"].split(PREFIX_DEP).last.chomp(")")
        dep_oper    = LOOKUP[d["flags"] & 0xFF]  # Lower order byte is the version operator
        dep_version = "#{dep_oper} #{d["version"]}".strip
        dep_version = ">= 0" if dep_version.empty?

        dep dep_name, dep_version
      end
    end
  end
end

pp index
