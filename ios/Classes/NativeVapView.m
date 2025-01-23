#import "NativeVapView.h"
#import "UIView+VAP.h"
#import "QGVAPWrapView.h"
#import <Flutter/Flutter.h>

@interface NativeVapView : NSObject <FlutterPlatformView, VAPWrapViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

@implementation NativeVapViewFactory {
    NSObject<FlutterPluginRegistrar> *_registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
    }
    return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
    return [[NativeVapView alloc] initWithFrame:frame
                                 viewIdentifier:viewId
                                      arguments:args
                                binaryMessenger:_registrar.messenger];
}

@end

@implementation NativeVapView {
    UIView *_view;
    QGVAPWrapView *_wrapView;
    BOOL playStatus;
    FlutterMethodChannel *_methodChannel;
    FlutterEventChannel *_eventChannel;
    FlutterEventSink _eventSink;
}
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    if (self) {
        playStatus = NO;
        _view = [[UIView alloc] initWithFrame:frame];

        // Initialize MethodChannel with a static name
        NSString *methodChannelName = @"flutter_vap_controller";
        _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:messenger];
        [_methodChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            [self handleMethodCall:call result:result];
        }];

        // Initialize EventChannel
        NSString *eventChannelName = [NSString stringWithFormat:@"flutter_vap_event_channel_%lld", viewId];
        _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:messenger];
        __weak typeof(self) weakSelf = self;
        [_eventChannel setStreamHandler:self];
    }
    return self;
}
// - (instancetype)initWithFrame:(CGRect)frame
//                viewIdentifier:(int64_t)viewId
//                     arguments:(id _Nullable)args
//               binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
//     self = [super init];
//     if (self) {
//         playStatus = NO;
//         _view = [[UIView alloc] initWithFrame:frame];

//         // Initialize MethodChannel
//         NSString *methodChannelName = [NSString stringWithFormat:@"flutter_vap_controller_%lld", viewId];
//         _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:messenger];
//         [_methodChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
//             [self handleMethodCall:call result:result];
//         }];

//         // Initialize EventChannel
//         NSString *eventChannelName = [NSString stringWithFormat:@"flutter_vap_event_channel_%lld", viewId];
//         _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:messenger];
//         __weak typeof(self) weakSelf = self;
//         [_eventChannel setStreamHandler:self];
//     }
//     return self;
// }

#pragma mark - FlutterPlatformView

- (UIView *)view {
    return _view;
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

#pragma mark - Method Call Handling

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"playPath" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"path"];
        if (path) {
            [self playByPath:path withResult:result];
        } else {
            result([FlutterError errorWithCode:@"INVALID_ARGUMENT"
                                       message:@"Path is null"
                                       details:nil]);
        }
    } else if ([@"playAsset" isEqualToString:call.method]) {
        NSString *asset = call.arguments[@"asset"];
        if (asset) {
            NSString *assetPath = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
            if (assetPath) {
                [self playByPath:assetPath withResult:result];
            } else {
                result([FlutterError errorWithCode:@"ASSET_NOT_FOUND"
                                           message:@"Asset not found"
                                           details:nil]);
            }
        } else {
            result([FlutterError errorWithCode:@"INVALID_ARGUMENT"
                                       message:@"Asset is null"
                                       details:nil]);
        }
    } else if ([@"stop" isEqualToString:call.method]) {
        [self stopPlayback];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Playback Control

- (void)playByPath:(NSString *)path withResult:(FlutterResult)result {
    if (playStatus) {
        result([FlutterError errorWithCode:@"ALREADY_PLAYING"
                                   message:@"A video is already playing"
                                   details:nil]);
        return;
    }

    playStatus = YES;
    _wrapView = [[QGVAPWrapView alloc] initWithFrame:_view.bounds];
    _wrapView.center = _view.center;
    _wrapView.contentMode = QGVAPWrapViewContentModeAspectFit;
    _wrapView.autoDestoryAfterFinish = YES;
    [_view addSubview:_wrapView];
    [_wrapView vapWrapView_playHWDMP4:path repeatCount:0 delegate:self];

    // Optionally, you can notify Flutter that playback has started
    if (_eventSink) {
        _eventSink(@{@"status": @"started"});
    }
}

- (void)stopPlayback {
    if (_wrapView) {
        [_wrapView removeFromSuperview];
        _wrapView = nil;
    }
    playStatus = NO;

    // Notify Flutter that playback has stopped
    if (_eventSink) {
        _eventSink(@{@"status": @"stopped"});
    }
}

#pragma mark - VAPWrapViewDelegate

- (void)vapWrap_viewDidStartPlayMP4:(VAPView *)container {
    playStatus = YES;

    // Notify Flutter that playback has started
    if (_eventSink) {
        _eventSink(@{@"status": @"started"});
    }
}

- (void)vapWrap_viewDidFailPlayMP4:(NSError *)error {
    playStatus = NO;

    if (_eventSink) {
        _eventSink(@{
                           @"status": @"failure",
                           @"errorMsg": error.localizedDescription ?: @"Unknown error"
                   });
    }
}

- (void)vapWrap_viewDidStopPlayMP4:(NSInteger)lastFrameIndex view:(VAPView *)container {
    playStatus = NO;

    // Notify Flutter that playback has stopped
    if (_eventSink) {
        _eventSink(@{@"status": @"stopped"});
    }
}

- (void)vapWrap_viewDidFinishPlayMP4:(NSInteger)totalFrameCount view:(VAPView *)container {
    playStatus = NO;

    if (_eventSink) {
        _eventSink(@{@"status": @"complete"});
    }
}

@end