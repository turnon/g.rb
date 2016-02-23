Gem::Specification.new do |s|
  s.name = %q{greb}
  s.version = "0.0.4"
  s.date = %q{2016-02-21}
  s.authors = ["Zp Yuan"]
  s.summary = %q{like grep}
  s.files = Dir.glob("bin/*") + Dir.glob("lib/*")
  s.require_paths = ["lib"]
  s.executables = ["greb"]
  s.add_dependency 'rchardet'
end
