Pod::Spec.new do |s|
  s.name         = "Fly"
  s.version      = "1.0.0"
  s.summary      = "Execution control of chained closures (next, cancel, complete, error, back, retry, restart)."
  s.homepage     = "https://github.com/xxxAIRINxxx/Fly"
  s.license      = 'MIT'
  s.author       = { "Airin" => "xl1138@gmail.com" }
  s.source       = { :git => "https://github.com/xxxAIRINxxx/Fly.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.platform     = :ios, '8.0'

  s.source_files = 'Source/*.swift'
end
