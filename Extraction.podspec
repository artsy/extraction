Pod::Spec.new do |s|
  s.name         = "Extraction"
  s.version      = "0.1.0"
  s.summary      = "UI components shared between Eigen and Emission."
  s.homepage     = "https://github.com/artsy/Extraction"
  s.license      = "MIT"
  s.author       = { "Eloy Durán" => "eloy.de.enige@gmail.com" }

  s.source       = { :git => "https://github.com/artsy/Extraction.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec 'ARSwitchView' do |ss|
    ss.source_files = 'Extraction/Classes/ARSwitchView'
    ss.dependency 'Artsy+UIFonts', '>= 1.1.0'
    ss.dependency 'FLKAutoLayout'
  end
end
