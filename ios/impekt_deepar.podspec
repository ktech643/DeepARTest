Pod::Spec.new do |s|
  s.name             = 'impekt_deepar'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin project integrating DeepAR SDK.'
  s.description      = <<-DESC
A new Flutter plugin project that integrates the DeepAR SDK for liveness check and AR effects.
                       DESC
  s.homepage         = 'https://www.impekt.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'impekt' => 'support@impekt.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  
  # DeepAR SDK Dependency (You need to provide the correct Pod for DeepAR)
  s.dependency 'DeepAR' 

  # Platform setting (make sure to match your minimum version)
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
 s.resources = ['Assets/**']

#  s.resource_bundles = {
#   'effects' => ['Assets/**'] # Adjust to actual asset path
# }
  
end
