# Modular
iOS组件化

通过协议，利用perform实现的iOS组件化方案，逻辑清晰，使用简单方便

实现协议

Swift

```swift
   static func moduleDescription(description: ModuleDescription) {
        description.moduleName("testSwift")
            .method { method in
                method.name("push")
                      .selector(selector: #selector(push))
            }
            .method { method in
                method.name("present")
                      .selector(selector: #selector(present(dic:)))
            }
            .method { method in
                method.name("log")
                       .selector(selector: #selector(printLog(logString:)))
            }
    }
```

OC

```objective-c
+ (void)moduleDescriptionWithDescription:(ModuleDescription * _Nonnull)description {
    description.moduleNameClosure(@"testOC")
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(push:)];
            [moduleMethod name:@"push"];
        })
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(present:)];
            [moduleMethod name:@"present"];
        });
}
```

调用

```swift
Module.share.moduleName(moduleName: "testSwift", performSelectorName: "push", param: [:])
```

TODO

解析Url,通过Url调用模块

添加回调

 等等
