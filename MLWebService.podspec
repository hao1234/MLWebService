Pod::Spec.new do |spec|

  spec.name         = "MLWebService"
  spec.version      = "0.0.2"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/hao1234/MLWebService"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "vuhao125@gmail.com" => "[email protected]" }

  spec.ios.deployment_target = "9.0"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/hao1234/MLWebService.git", :tag => "#{spec.version}" }
  spec.source_files  = "MLWebService/**/*.{h,m,swift}"
  spec.dependency 'SwiftyJSON', '~> 4.2'
end