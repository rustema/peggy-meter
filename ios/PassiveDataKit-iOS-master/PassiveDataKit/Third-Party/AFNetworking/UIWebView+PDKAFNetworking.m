// UIWebView+PDKAFNetworking.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIWebView+PDKAFNetworking.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS

#import "PDKAFHTTPSessionManager.h"
#import "PDKAFURLResponseSerialization.h"
#import "PDKAFURLRequestSerialization.h"

@interface UIWebView (_PDKAFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setURLSessionTask:) NSURLSessionDataTask *af_URLSessionTask;
@end

@implementation UIWebView (_PDKAFNetworking)

- (NSURLSessionDataTask *)af_URLSessionTask {
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, @selector(af_URLSessionTask));
}

- (void)af_setURLSessionTask:(NSURLSessionDataTask *)af_URLSessionTask {
    objc_setAssociatedObject(self, @selector(af_URLSessionTask), af_URLSessionTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIWebView (PDKAFNetworking)

- (PDKAFHTTPSessionManager  *)sessionManager {
    static PDKAFHTTPSessionManager *_af_defaultHTTPSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultHTTPSessionManager = [[PDKAFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _af_defaultHTTPSessionManager.requestSerializer = [PDKAFHTTPRequestSerializer serializer];
        _af_defaultHTTPSessionManager.responseSerializer = [PDKAFHTTPResponseSerializer serializer];
    });

    return objc_getAssociatedObject(self, @selector(sessionManager)) ?: _af_defaultHTTPSessionManager;
}

- (void)setSessionManager:(PDKAFHTTPSessionManager *)sessionManager {
    objc_setAssociatedObject(self, @selector(sessionManager), sessionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PDKAFHTTPResponseSerializer <PDKAFURLResponseSerialization> *)responseSerializer {
    static PDKAFHTTPResponseSerializer <PDKAFURLResponseSerialization> *_af_defaultResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultResponseSerializer = [PDKAFHTTPResponseSerializer serializer];
    });

    return objc_getAssociatedObject(self, @selector(responseSerializer)) ?: _af_defaultResponseSerializer;
}

- (void)setResponseSerializer:(PDKAFHTTPResponseSerializer<PDKAFURLResponseSerialization> *)responseSerializer {
    objc_setAssociatedObject(self, @selector(responseSerializer), responseSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)loadRequest:(NSURLRequest *)request
           progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
            success:(NSString * (^)(NSHTTPURLResponse *response, NSString *HTML))success
            failure:(void (^)(NSError *error))failure
{
    [self loadRequest:request MIMEType:nil textEncodingName:nil progress:progress success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
        NSStringEncoding stringEncoding = NSUTF8StringEncoding;
        if (response.textEncodingName) {
            CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
            if (encoding != kCFStringEncodingInvalidId) {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
            }
        }

        NSString *string = [[NSString alloc] initWithData:data encoding:stringEncoding];
        if (success) {
            string = success(response, string);
        }

        return [string dataUsingEncoding:stringEncoding];
    } failure:failure];
}

- (void)loadRequest:(NSURLRequest *)request
           MIMEType:(NSString *)MIMEType
   textEncodingName:(NSString *)textEncodingName
           progress:(NSProgress * _Nullable __autoreleasing * _Nullable)progress
            success:(NSData * (^)(NSHTTPURLResponse *response, NSData *data))success
            failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(request);

    if (self.af_URLSessionTask.state == NSURLSessionTaskStateRunning || self.af_URLSessionTask.state == NSURLSessionTaskStateSuspended) {
        [self.af_URLSessionTask cancel];
    }
    self.af_URLSessionTask = nil;

    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *dataTask;
    dataTask = [self.sessionManager
            GET:request.URL.absoluteString
            parameters:nil
            progress:nil
            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (success) {
                    success((NSHTTPURLResponse *)task.response, responseObject);
                }
                [strongSelf loadData:responseObject MIMEType:MIMEType textEncodingName:textEncodingName baseURL:[task.currentRequest URL]];

                if ([strongSelf.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
                    [strongSelf.delegate webViewDidFinishLoad:strongSelf];
                }
            }
            failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
    self.af_URLSessionTask = dataTask;
    if (progress != nil) {
        *progress = [self.sessionManager downloadProgressForTask:dataTask];
    }
    [self.af_URLSessionTask resume];

    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

@end

#endif