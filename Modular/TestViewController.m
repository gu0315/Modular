//
//  TestViewController.m
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

#import "TestViewController.h"
#import "Modular-Swift.h"
@interface TestViewController ()<ModuleProtocol>

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.numberOfLines = 0;
    [self.view addSubview:lab];
    lab.text = self.str;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)push:(NSDictionary *)dic callback:(void(^ __nullable)( NSDictionary * _Nullable moduleInfo))callback {
    TestViewController *vc = [[TestViewController alloc] init];
    callback(@{@"key":@"value"});
    UIViewController *topVc = [TestViewController applicationTopVC];
    [topVc.navigationController pushViewController:vc animated:YES];
}

+ (void)present:(NSDictionary *)dic {
    TestViewController *vc = [[TestViewController alloc] init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        vc.str =  @"{}";
    } else {
        vc.str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    UIViewController *topVc = [self applicationTopVC];
    [topVc presentViewController:vc animated:YES completion:nil];
}

- (void)multiparameterLog:(NSDictionary *)dic callback:(void(^ __nullable)( NSDictionary * _Nullable moduleInfo))callback {
    NSLog(@"dic==%@\nparameter1==%@", dic, callback);
    callback(@{@"哈哈":@"value"});
}



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
@end
