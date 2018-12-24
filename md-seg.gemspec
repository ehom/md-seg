Gem::Specification.new do |s|
  s.name    = %q{md-seg}
  s.version = %q{0.0.4}
  s.date    = %q{2018-12-24}
  s.summary = %q{md-seg}
  s.description = %q{A tool to segment paragraphs in GitHub MD files}
  s.authors  =  [ "erwin.hom" ]
  s.email   = 'erwin.hom@puppet.com'
  s.files   = [ "lib/md-seg.rb", 
                "lib/md-seg/document.rb", 
                "lib/md-seg/paragraph.rb", 
                "lib/md-seg/paragraph/assembler.rb" ,
                "lib/md-seg/paragraph/disassembler.rb" ]
  s.homepage = 'http://ehom.github.io'
  s.license  = 'Apache-2.0'
end
