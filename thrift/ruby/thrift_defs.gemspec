Gem::Specification.new do |s|
  s.name        = 'thrift_defs'
  s.version     = '0.1.0'
  s.date        = '2019-04-27'
  s.summary     = 'Thrift compiler-generated classes for the Voter Verifier.'
  s.description = s.summary
  s.authors     = ['Matteo Banerjee', 'Bryan Eslinger']
  s.licenses      = ['Apache-2.0']
  s.require_paths = ['lib']
  s.files         = `git ls-files lib`.split("\n")
  s.add_dependency 'thrift'
end
