Pod::Spec.new do |s|

  s.name         = "LiveStreamSDK"
  s.version      = "0.0.1"
  s.summary      = "LiveStream SDK under iOS for Sina Cloud."
  s.homepage     = "http://www.sinacloud.com"

  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author       = { "liuley" => "liuley@163.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/leyleo/LiveStream_SDK_iOS.git", :tag => "0.0.1" }

  s.source_files  = "LiveStreamSDK","LiveStreamSDK/**/*.{h,m}"
  s.public_header_files = "LiveStreamSDK/**/*.h"

  s.framework  = "SystemConfiguration"

  s.requires_arc = true

  s.dependency "Reachability"

end
