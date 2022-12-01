

Pod::Spec.new do |s|
    s.name         = "Modular"
    s.version      = "1.0.0"
    s.ios.deployment_target = 13.0'
    s.summary      = "A delightful setting interface framework."
    s.homepage     = "https://github.com/gu0315/Modular"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "gu0315" => "guqianxiang@souche.com" }
    s.source       = { :git => "https://github.com/gu0315/Modular.git", :tag => s.version }
    s.source_files  = "Modular/Sources"
    s.swift_version = "5.0"
    s.requires_arc = true
end
