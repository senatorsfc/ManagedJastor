Pod::Spec.new do |s|
  s.name         = "ManagedJastor"
  s.version      = "0.2.5"
  s.summary      = "Auto translates NSDictionary to instances of Objective-C NSManagedObject classes, supporting nested types and arrays."
  s.homepage     = "https://github.com/senatorsfc/ManagedJastor"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Francis Carriere" => "senatorsfc@gmail.com" }
  s.source       = { :git => "https://github.com/senatorsfc/ManagedJastor.git", :tag => "0.2.4" }
  s.source_files = 'ManagedJastor/*.{h,m}'
end
