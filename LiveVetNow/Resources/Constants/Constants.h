//
//  Constants.h
//
//  Created by Apple on 11/09/16.
//  Copyright © 2016 iOS. All rights reserved.
//
#import "modelManager.h"
#import "AppDelegate.h"
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCParserConfiguration.h>
#import <DCArrayMapping.h>

#ifndef Constants_h
#define Constants_h


#define kUTCDateFormat @"yyyy-MM-dd"
#define kUTCTimeFormat @"HH:mm"
#define kUTCFormat @"yyyy-MM-dd'T'HH:mm:ssZ"



#define model_manager ((modelManager *)[modelManager ModelManager])
#define kAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define host @"http://elinkindia.com/public/images/"
#define kSubscriptionKeyPubNub @"sub-c-1fca622c-3a64-11e7-b611-0619f8945a4f"
#define kPublisherKeyPubNub @"pub-c-92d55385-c868-4a37-8938-5e8b65610ce0"

#define kSignupStoryboard @"SignUp"
#define kFindYourVetStoryboard @"FindYourVet"
#define kVetProfileForPetOwnerStoryboard @"VetProfileForPetOwner"
#define kPayPalEnvironment PayPalEnvironmentSandbox


#define kFindYourVetStoryboardIdentifier @"findYourVetVC"
#define kVetProfileForPetOwnerStoryboardIdentifier @"vetProfileForPetOwnerVC"

//Internet Message Constants
#define kInternetUnreachableMessage @"Your Internet connection is unavailable."

#define kFindYourVetTableViewCellIdentifier @ "findYourVetCell"
#define kEmailListingTableViewCellIdentifier @ "emailListingCell"
#define kcustomProfileCell @ "customProfileCell"
#define kcustomPetListingCell @ "petListingCell"
#define kcustomUpcomingMeetingCell @ "upomingMeetingCell"
#define kcustomDoctorMyMeetingCell @ "myMeetingCell"

#define kcustomScheduleMeetingCell @ "PetListingCell"
#define kcustomTextViewCell @ "textViewCell"
#define kcustomPetListingViewPopUp @ "petListingViewPopUp"




#define kcustomAddMorePetCell @ "addMorePetCell"

#define kBaseURL @"http://elinkindia.com/api/"


#endif /* Constants_h */
