Pod::Spec.new do |s|
    s.name         = "SModular"
    s.version      = "0.0.9"
    s.ios.deployment_target = '12.0'
    s.summary      = "SModular"
    s.homepage     = "https://github.com/gu0315/Modular"
    s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
    s.author             = { "顾钱想" => "228383741@qq.com" }
    s.social_media_url   = "https://www.jianshu.com/p/0ea1a4c49fba"
    s.source       = { :git => "https://github.com/gu0315/Modular.git", :tag => s.version }
    s.source_files  = "Modular/Sources/**/*"
    s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

    s.swift_version = "5.0"
    s.swift_versions = ['5.0', '5.1']
end

