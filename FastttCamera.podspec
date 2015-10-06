Pod::Spec.new do |s|
  s.name             = "FastttCamera"
  s.version          = "0.3.4"
  s.summary          = "A fast, straightforward implementation of AVFoundation camera with customizable real-time photo filters."
  s.homepage         = "https://github.com/IFTTT/FastttCamera"
  s.license          = 'MIT'
  s.author           = { 
                          "Laura Skelton" => "laura@ifttt.com",
                          "Jonathan Hersh" => "jonathan@ifttt.com",
                          "Max Meyers" => "max@ifttt.com",
                          "Devin Foley" => "devin@ifttt.com" 
                       }
  s.source           = { :git => "https://github.com/IFTTT/FastttCamera.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/skelovenko'
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
