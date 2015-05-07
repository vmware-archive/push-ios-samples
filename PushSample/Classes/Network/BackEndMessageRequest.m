//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <PCFPush/PCFPushDebug.h>
#import "BackEndMessageRequest.h"
#import "Settings.h"

static CGFloat BACK_END_PUSH_MESSAGE_TIMEOUT_IN_SECONDS   = 60.0;

@interface BackEndMessageRequest ()

@property (nonatomic, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *urlConnection;

@end

@implementation BackEndMessageRequest

- (void) sendMessage
{
    self.urlRequest = [self getRequest];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];    
}

- (NSMutableURLRequest*) getRequest
{
    NSURL *url = [NSURL URLWithString:BACK_END_PUSH_MESSAGE_API];
    NSTimeInterval timeout = BACK_END_PUSH_MESSAGE_TIMEOUT_IN_SECONDS;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self getURLRequestBodyData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self addBasicAuthToURLRequest:request appUuid:self.appUuid apiKey:self.apiKey];
    return request;
}

- (void)addBasicAuthToURLRequest:(NSMutableURLRequest *)request
                         appUuid:(NSString *)appUuid
                          apiKey:(NSString *)apiKey
{
    NSString *authString = [self base64String:[NSString stringWithFormat:@"%@:%@", appUuid, apiKey]];
    NSString *authToken = [NSString stringWithFormat:@"Basic  %@", authString];
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
}

- (NSString*) base64String:(NSString *)normalString
{
    NSData *plainData = [normalString dataUsingEncoding:NSUTF8StringEncoding];
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {

        return [plainData base64EncodedStringWithOptions:0];

    } else {
        return [plainData base64Encoding];
    }
}

- (NSData*) getURLRequestBodyData
{
    NSDictionary *requestDictionary = [self getRequestDictionary];

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&error];
    if (error) {
        PCFPushCriticalLog(@"Error upon serializing object to JSON: %@", error);
        return nil;
    } else {
        return jsonData;
    }
}

- (NSDictionary*) getRequestDictionary
{
    id message;
    if (self.category) {
        id ios = @{ @"category" : @"ACTIONABLE" };
        id custom = @{ @"ios" : ios };
        message = @{ @"body" : self.messageBody, @"custom" : custom };
    } else {
        message = @{ @"body" : self.messageBody};
    }

    id target;
    if (self.tags) {
        target = @{@"platform" : @"ios", @"tags" : self.tags.allObjects};
    } else {
        target = @{@"platform" : @"ios", @"devices" : self.targetDevices};
    }

    return @{ @"message" : message, @"target" : target };
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    PCFPushLog(@"Got error when trying to push message via back-end server: %@", error);
}

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        PCFPushLog(@"Got error when trying to push message via back-end server: server response is not an NSHTTPURLResponse.");
        return;
    }

    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse*)response;

    if (![self isSuccessfulResponseCode:httpURLResponse]) {
        PCFPushLog(@"Got HTTP failure status code when trying to push message via back-end server: %d", httpURLResponse.statusCode);
        return;
    }

    PCFPushLog(@"Back-end server has accepted message for delivery.");
}

- (NSCachedURLResponse*) connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (BOOL) isSuccessfulResponseCode:(NSHTTPURLResponse*)response
{
    return (response.statusCode >= 200 && response.statusCode < 300);
}

@end
