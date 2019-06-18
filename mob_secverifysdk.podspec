Pod::Spec.new do |s|
	s.name                = "mob_secverifysdk"
	s.version             = "1.0.0"
	s.summary             = '秒验，一键登录'
	s.license             = 'Copyright © 2019-2029 mob.com'
	s.author              = { "mob" => "mobproducts@163.com" }
	s.homepage            = 'http://www.mob.com'
	s.source              = { :git => "https://github.com/MobClub/SecVerify-for-iOS.git", :tag => s.version.to_s }
	s.platform            = :ios, '8.0'
	s.libraries           = "c++"
	s.vendored_frameworks = 'SDK/SecVerify/SecVerify.framework', 'SDK/SecVerify/PlatformSDK/Mobile/TYRZSDK.framework', 'SDK/SecVerify/PlatformSDK/Telecom/EAccountApiSDK.framework', 'SDK/SecVerify/PlatformSDK/Union/OAuth.framework'
	s.resources 		  = 'SDK/SecVerify/SecVerify.bundle', 'SDK/SecVerify/PlatformSDK/Mobile/TYRZResource.bundle', 'SDK/SecVerify/PlatformSDK/Union/sdk_oauth.bundle'
	s.xcconfig  		  =  {'OTHER_LDFLAGS' => '-ObjC' }
	s.dependency 'MOBFoundation'
end
