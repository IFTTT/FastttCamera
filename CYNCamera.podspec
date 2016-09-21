Pod::Spec.new do |s|
  s.name             = "CYNCamera"
  s.version          = "0.0.1"
  s.summary          = "Cynny fork of FastttCamera project."
  s.homepage         = "https://github.com/maross/CYNCamera"
  s.license          = 'MIT'
  s.author           = { 
                          "Laura Skelton" => "laura@ifttt.com",
                          "Jonathan Hersh" => "jonathan@ifttt.com",
                          "Max Meyers" => "max@ifttt.com",
                          "Devin Foley" => "devin@ifttt.com",
                          "Marco Rossi" => "marco.rossi@cynny.com" 
                       }
  s.source           = { :git => "https://github.com/maross/CYNCamera.git", :tag => s.version.to_s }
  s.social_media_url = ''
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.compiler_flags   = '-fmodules'
  s.frameworks       = 'UIKit', 'AVFoundation', 'CoreMotion'

  s.subspec 'Default' do |ss|
    ss.source_files     = 'FastttCamera/*.{h,m}'
  end

  s.subspec 'Filters' do |ss|
    ss.dependency         'GPUImage', '~> 0.1.0'
    ss.dependency         'FastttCamera/Default'
    ss.source_files     = 'FastttCamera/Filters/*.{h,m}'
  end

  s.default_subspec = 'Default'
end
