#import "JumpNavigationPlugin.h"

@implementation JumpNavigationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"jump_navigation"
                                           binaryMessenger:[registrar messenger]];
    JumpNavigationPlugin *instance = [[JumpNavigationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"navigationWithBaiduMap" isEqualToString:call.method] || [@"navigationWithAMap" isEqualToString:call.method] || [@"directionWithBaiduMap" isEqualToString:call.method]) {
        BOOL callBackResult = NO;
        NSString *uri = call.arguments[@"uri"];
        if (uri.length) {
            NSURL *url = [NSURL URLWithString:uri];
            if ([UIApplication.sharedApplication canOpenURL:url]) {
                callBackResult = [UIApplication.sharedApplication openURL:url];
            }
        }
        if (result) {
            result([NSNumber numberWithBool:callBackResult]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
