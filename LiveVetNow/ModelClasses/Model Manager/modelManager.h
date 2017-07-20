//
//  modelManager.h
//

#import <Foundation/Foundation.h>
#import "PubnubChatClient.h"
#import "NotificationManager.h"
#import "ProfileManager.h"
#import "loginManager.h"
#import "TokBoxManager.h"
#import "PetManager.h"
#import "RequestManager.h"
#import "VetManager.h"
#import "AppointmentManager.h"
#import "EmailManager.h"

@interface modelManager : NSObject {

}

@property (strong,nonatomic) PubnubChatClient * chatVendor;
@property (strong,nonatomic) ProfileManager *profileManager;
@property (strong,nonatomic) NotificationManager *notificationManager;
@property (strong,nonatomic) VetManager *vetManager;
@property (strong,nonatomic)loginManager *login_Manager;
@property (strong,nonatomic)RequestManager *request_Manager;
@property (strong,nonatomic)TokBoxManager *tokbox_Manager;
@property (strong,nonatomic)AppointmentManager *appointment_Manager;
@property (strong,nonatomic)PetManager *petManager;
@property (strong,nonatomic)EmailManager *emailManager;

+ (modelManager *)ModelManager;

@end
