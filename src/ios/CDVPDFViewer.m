#import "CDVPDFViewer.h"
#import <Cordova/CDVPlugin.h>
#import ”PDFViewer-Swift.h“

@implementation CDVPDFViewer

-(void)openPDFWithURL:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    /// Extract the URL from the arguments passed in by JavaScript's exec function.
    NSString* url = [command.arguments objectAtIndex:0];
    NSLog(@"You made it! %@", url);

    PDFViewController *pdfVC = [[PDFViewController alloc] init];
    [pdfVC loadPDFWithURL: url];

    if (url != nil && url.length > 0) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR];
    }

    /// Execute the exec method's success or failure callbacks on the JavaScript side.
    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

@end


