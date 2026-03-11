Pod::Spec.new do |spec|
    spec.name          = 'zetrix_vc_flutter'
    spec.version       = '1.0.0'
    spec.summary       = 'A Flutter plugin for platform-specific Zetrix VC(VP Generation) functionality with BBS Signature.'
    spec.description   = 'This plugin adds platform-specific functionality to Zetrix VC(VP Generation)  on iOS.'
    spec.homepage      = 'https://example.com/zetrix'
    spec.source        = { :git => 'https://github.com/Zetrix-Chain/zetrix-vc-flutter.git' }
    spec.license       = { :type => 'MIT', :file => 'LICENSE' }
    spec.author        = { 'Author Name' => 'email@example.com' }
    spec.ios.deployment_target = '12.0'

    # Source files including private headers
    spec.source_files = 'Classes/**/*.{h,m}'

    # Public headers that should be exposed to the plugin
    spec.public_header_files = 'Classes/**/*.h'

    # Static libraries - BBS signatures and Bulletproof range proofs
    spec.vendored_libraries = 'Frameworks/libbbs.a', 'Frameworks/libbulletproof.a'

    # Add the correct header search paths
    spec.pod_target_xcconfig = {
        'HEADER_SEARCH_PATHS' => [
          '$(PODS_TARGET_SRCROOT)/Classes'
        ],
        'LIBRARY_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/Frameworks',
    }

    spec.dependency 'Flutter'
    # Add additional resources if required by your `.xcodeproj` or static library
end

