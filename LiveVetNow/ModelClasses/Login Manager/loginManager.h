//
//  loginManager.h
//

#import <Foundation/Foundation.h>

@interface loginManager : NSObject

@property(nonatomic,strong)NSString *accessToken;
-(void)login:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)registerUser:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;
-(void)fetchLocationswithCompletionBlock:(void (^)(BOOL,NSArray*))completionBlock;
-(void)logout;
-(void)uploadImage:(NSDictionary *)dict withCompletionBlock:(void (^)(BOOL,NSString*,NSString*))completionBlock;
-(void)setLoginData:(id)json withCompletionBlock:(void (^)(BOOL))completionBlock;

@end
