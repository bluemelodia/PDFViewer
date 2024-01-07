#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface CDVPDFViewer: CDVPlugin

@property (strong) NSString* callbackId;
@property (strong) NSString* url;

-(void)openPDFWithURL:(CDVInvokedUrlCommand*)command;

@end
