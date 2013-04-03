Gem::Specification.new do |s|
  s.name     = 'wick'
  s.version  = '0.1'
  s.summary  = 'Functional reactive programming library'
  s.authors  = ['Aanand Prasad']
  s.email    = 'aanand.prasad@gmail.com'
  s.homepage = 'https://github.com/aanand/wick'
  s.files    = `git ls-files -z examples lib`.split("\0")
  
  s.add_development_dependency('colored')
  s.add_development_dependency('slop')
end

