# Modular

iOS组件化, 参考大搜车组件化方案

通过协议，利用perform实现的iOS组件化方案，逻辑清晰，使用简单方便, 可以下载Demo查看使用

<img src="http://img.souche.com/f2e/c452772148ad575bd0b8c43c01219952.gif" alt="图片替换文本" width="390" height="844" align="bottom" />

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
                method.classMethod(true)
                      .name("push")
                      .selector(selector: #selector(push(str:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "str", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("present")
                      .selector(selector: #selector(present(str:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "str", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("log")
                      .selector(selector: #selector(printLog(logString:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "logString", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("testNorm")
                      .selector(selector: #selector(testNorm(value:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "value", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("multiparameter")
                      .selector(selector: #selector(multiparams(params1: params2: params3: params4: callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "params1", paramType: .String)
                          enumerator.next()?.add(paramName: "params2", paramType: .Array)
                          enumerator.next()?.add(paramName: "params3", paramType: .Map)
                          enumerator.next()?.add(paramName: "params4", paramType: .Number)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
    }
```

OC

```objective-c
+ (void)moduleDescriptionWithDescription:(ModuleDescription * _Nonnull)description {
    description.moduleNameClosure(@"testOC")
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(push:callback:)];
            [moduleMethod name:@"push"];
            [moduleMethod parameterDescription:^(ModuleParameterDes * enumerator) {
                [[enumerator next] addWithParamName:@"dic" paramType:  ModuleParameterTypeMap  isStrict:NO];
                [[enumerator next] addWithParamName:@"callback" paramType: ModuleParameterTypeBlock isStrict:NO];
            }];
        })
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(present:)];
            [moduleMethod name:@"present"];
            [moduleMethod classMethod:YES];
            [moduleMethod parameterDescription:^(ModuleParameterDes * enumerator) {
                [[enumerator next] addWithParamName:@"dic" paramType:  ModuleParameterTypeMap  isStrict:NO];
            }];
        })
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(multiparameterLog:callback:)];
            [moduleMethod name:@"log"];
            [moduleMethod parameterDescription:^(ModuleParameterDes * enumerator) {
                [[enumerator next] addWithParamName:@"dic" paramType:  ModuleParameterTypeMap  isStrict:NO];
                [[enumerator next] addWithParamName:@"callback" paramType: ModuleParameterTypeBlock isStrict:NO];
            }];
        });
}
```

调用

```swift
Module.share.performWithUrl(url:"scheme://push/testSwift?str=1111"){ parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
Module.share.perform(moduleName: "testOC", selectorName: "present", params: [
                "dic": ["key": "value"]
            ]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
Module.share.perform(moduleName:"testSwift", selectorName: "present", params: [
                "str": "present"
            ]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
```

TODO

支持多参数
404界面
等等

