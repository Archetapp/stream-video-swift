Pod::Spec.new do |spec|
  spec.name = 'StreamVideo'
  spec.version = '0.2.0'
  spec.summary = 'StreamVideo iOS Video Client'
  spec.description = 'StreamVideo is the official Swift client for Stream Video, a service for building video applications.'

  spec.homepage = 'https://getstream.io/video/'
  spec.license = { type: 'BSD-3', file: 'LICENSE' }
  spec.author = { 'getstream.io' => 'support@getstream.io' }
  spec.social_media_url = 'https://getstream.io'

  spec.swift_version = '5.6'
  spec.platform = :ios, '13.0'
  spec.requires_arc = true

  spec.framework = 'Foundation'
  spec.module_name = spec.name
  spec.source = { git: 'https://github.com/GetStream/stream-video-swift.git', tag: spec.version }
  spec.source_files = ["Sources/#{spec.name}/**/*.swift"]
  spec.exclude_files = ["Sources/#{spec.name}/**/*_Tests.swift", "Sources/#{spec.name}/**/*_Mock.swift"]

  spec.dependency('SwiftProtobuf', '~> 1.18.0')
  spec.dependency('WebRTC-SDK', '114.5735.2')
end
