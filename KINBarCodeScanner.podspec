

Pod::Spec.new do |s|

  s.name         = "KINBarCodeScanner"
  s.version      = "0.0.2"
  s.summary      = "Simple barcode scanning for your apps."

  s.description  = <<-DESC
                   KINCodeScammer is a simple bar code scanner module for your apps.
                   DESC

  s.homepage     = "https://github.com/dfmuir/KINBarCodeScanner"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "David F. Muir V" => "dfmuir@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/dfmuir/KINBarCodeScanner.git", :tag => s.version.to_s }
  s.source_files  = 'KINBarCodeScanner', 'KINBarCodeScanner/**/*.{h,m}'
  s.resources = "Assets/*.png"
  s.frameworks = 'AVFoundation'
  s.requires_arc = true

end
