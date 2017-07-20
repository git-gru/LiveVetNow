//
//  modelManager.m
//

#import "modelManager.h"

@implementation modelManager
//@synthesize login_Manager,request_Manager;

static modelManager *ModelManager = nil;

+ (modelManager *)ModelManager {
    if (nil != ModelManager) {
        return ModelManager;
    }
    
    
    static dispatch_once_t pred; // Lock
    dispatch_once(&pred, ^{ // This code is called at most once per app
        ModelManager = [[modelManager alloc] init];
    });
    
    return ModelManager;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init {
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
        self.profileManager = [ProfileManager new];
        self.vetManager = [VetManager new];
        self.notificationManager= [[NotificationManager alloc] init];
        self.chatVendor=[[PubnubChatClient alloc] init];
        self.login_Manager=[[loginManager alloc] init];
        self.request_Manager = [[RequestManager alloc] init];
        self.tokbox_Manager = [[TokBoxManager alloc]init];
        self.appointment_Manager = [[AppointmentManager alloc]init];
        self.petManager = [PetManager new];
        self.emailManager = [EmailManager new];
    }
    return self;
}


@end
