

Pod::Spec.new do |spec|

  spec.name         = "MultipleMediaPicker"
  spec.version      = "0.0.2"
  spec.summary      = "MultipleMediaPicker library."

  spec.description  = <<-DESC
  This cocoapods library provides multiple or single selection media from assets.
                   DESC

  spec.homepage     = "https://github.com/vitali36/MultipleMediaPicker"


  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { "Vitaliy" => "vitali.bulavkin@gmail.com" }

 spec.ios.deployment_target = "11.0"
 spec.swift_version = "4.2"


  spec.source       = { :git => "https://github.com/vitali36/MultipleMediaPicker.git", :tag => "#{spec.version}" }
  spec.resources = 'MultipleMediaPicker/**/*.{xcassets}'


  spec.source_files  = "MultipleMediaPicker/**/*.{h,m,swift}"


end
