

Pod::Spec.new do |spec|

  spec.name         = "MultipleMediaPicker"
  spec.version      = "0.0.1"
  spec.summary      = "MultipleMediaPicker library."

  spec.description  = <<-DESC
  This cocoapods library provides multiple or single selection media from assets.
                   DESC

  spec.homepage     = "https://github.com/vitali36/MultipleMediaPicker"


  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { "Vitaliy" => "vitali.bulavkin@gmail.com" }

 spec.ios.deployment_target = "12.1"
 spec.swift_version = "4.2"


  spec.source       = { :git => "https://github.com/vitali36/MultipleMediaPicker.git", :tag => "#{spec.version}" }


  spec.source_files  = "MultipleMediaPicker/**/*.{h,m,swift}"


end
