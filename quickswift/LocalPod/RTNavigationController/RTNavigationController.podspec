Pod::Spec.new do |s|

    s.name = 'RTNavigationController'
    s.version = '5.3.3'
    s.license = { :type => 'MIT' }
    s.homepage = 'https://www.iwecon.cc'
    s.authors = 'Pansitong iWw'
    s.ios.deployment_target = '10.0'
    s.summary = <<-DESC
    RTNavigationController fork from https://github.com/rickytan/RTNavigationController
    
    More and more apps use custom navigation bar for each different view controller, instead of one common, gloabal navigation bar.
    This project just help develops to solve this problem in a tricky way, develops use this navigation controller in a farmilar way just like you used to be, and
    you can have each view controller a individual navigation bar.
    DESC
    
    s.source = { :git => 'https://github.com/iWECon/RTNavigationController.git', :tag => s.version }
    s.source_files = [
        'Sources/*.{h,m}',
    ]
    s.resource_bundles = {
        'RTNavigationController' => ["Sources/RTNavigationController/*.xcassets"]
    }
    s.public_header_files = [
        'Sources/include/*.h'
    ]
    
    s.cocoapods_version = '>= 1.10.0'
    s.frameworks = 'UIKit', 'Foundation'
end
