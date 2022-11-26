//
//  Test.m
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

#import "Test.h"
#import "Modular-Swift.h"
@interface Test()<ModuleProtocol>

@end

@implementation Test

+ (void)moduleDescriptionWithDescription:(ModuleDescription * _Nonnull)description {
    description.moduleNameClosure(@"NSObject")
        .methodClosure(^(ModuleMethod * moduleMethod) {
            [moduleMethod selectorWithSelector: @selector(testBridge:)];
            [moduleMethod name:@"open1"];
        });
}


- (void)testBridge:(NSDictionary *)dic {
    NSLog(@"testBridge-----------%@", dic);
}
@end
