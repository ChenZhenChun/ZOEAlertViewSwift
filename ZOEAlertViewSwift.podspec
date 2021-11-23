Pod::Spec.new do |s|
#name必须与文件名一致
s.name              = "ZOEAlertViewSwift"

#更新代码必须修改版本号
s.version           = "1.0.0"
s.summary           = "It is a ZOEAlertViewSwift used on iOS, which implement by swift5.x"
s.description       = <<-DESC
It is a ZOEAlertViewSwift used on iOS, which implement by swift5.x.
DESC
s.homepage          = "https://github.com/ChenZhenChun/ZOEAlertViewSwift"
s.license           = 'MIT'
s.author            = { "ChenZhenChun" => "346891964@qq.com" }

#submodules 是否支持子模块
s.source            = { :git => "https://github.com/ChenZhenChun/ZOEAlertViewSwift.git", :tag => s.version, :submodules => true}
s.platform          = :ios, '9.0'
s.requires_arc = true

#source_files路径是相对podspec文件的路径

#ZOECommon模块
s.subspec 'ZOECommon' do |ss|
ss.source_files = 'ZOEAlertViewSwift/ZOECommon/*.{swift}'
end

#ZOEAlertView模块
s.subspec 'ZOEAlertView' do |ss|
ss.source_files = 'ZOEAlertViewSwift/ZOEAlertView/*.{swift}'
ss.dependency 'ZOEAlertViewSwift/ZOECommon'
ss.user_target_xcconfig = {'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'=>'YES'}
end

#ZOEActionSheet模块
s.subspec 'ZOEActionSheet' do |ss|
ss.source_files = 'ZOEAlertViewSwift/ZOEActionSheet/*.{swift}'
ss.dependency 'ZOEAlertViewSwift/ZOECommon'
end

s.frameworks = 'Foundation', 'UIKit'

# s.ios.exclude_files = 'Classes/osx'
# s.osx.exclude_files = 'Classes/ios'
# s.public_header_files = 'Classes/**/*.h'

end
