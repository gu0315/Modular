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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)push:(NSDictionary *)dic {
    UIViewController *vc = [[TestViewController alloc] init];
    UIViewController *topVc = [UIViewController applicationTopVC];
    [topVc.navigationController pushViewController:vc animated:YES];
}

- (void)present:(NSDictionary *)dic {
    UIViewController *vc = [[TestViewController alloc] init];
    UIViewController *topVc = [UIViewController applicationTopVC];
    [topVc presentViewController:vc animated:YES completion:nil];
}

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


@end
