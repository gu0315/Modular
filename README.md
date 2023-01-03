# Modular
iOS组件化, 参考大搜车组件化方案

通过协议，利用perform实现的iOS组件化方案，逻辑清晰，使用简单方便, 可以下载Demo查看使用

截图
![](http://img.souche.com/f2e/c452772148ad575bd0b8c43c01219952.gif)

安装

```
pod 'SModular'
```

使用

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
Module.share.invokeWithModuleName("testSwift", selectorName: "log", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20
            ], callback: nil)
Module.share.invokeWithUrl("scheme://push/testSwift?code=1111", callback: nil)
```

TODO

参数检验
404界面
等等
