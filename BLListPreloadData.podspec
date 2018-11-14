

Pod::Spec.new do |s|


  s.name         = "BLListPreloadData"
  s.version      = "1.0.0"
  s.summary      = "预加载框架"

 s.description  = <<-DESC
Hope userful to you!
                   DESC

  s.homepage     = "https://github.com/Balopy/BLListPreloadData"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #


  s.license      = "MIT (LICENSE)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }



  s.author             = { "wangchunlong" => "wangchunlong@268xue.com" }


   s.platform     = :ios
   s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/Balopy/BLListPreloadData.git", :tag => "#{s.version}" }



  s.source_files  = "BLPreloadDemo/MVVM_Demo/MNetRequest/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

 
   s.frameworks = "UIKit", "Foundation"

end
