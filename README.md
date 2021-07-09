# Midterm    -    Jason Hess

Hi there. This is my midterm submission of the chat app with AdMob ads.

I essentially had to completely abandon my previous codebase from previous assignments due to an incompatible structure.
With that in mind, this app still has some occasional minor visual bugs as you will see in the screen recording. 

I essentially rewrote the entire application within a day or two, after many days trying to adapt my prior code.

Things that are working: 
    
    -   Firebase API usage              -   Described below
    
    -   Sign in with Google             -   Uses your google account info (email, pic, username, etc.) to create an account.  
    
    -   Sign in Anonymously             -   Creates a user for you that lasts until logout. No custom picture or username. Can edit default name.
    
    -   Cloud Firestore                 -   Stores messages and user info. 
    
    -   Navigation Bar                  -   Drawer at the top left includes buttons for profile, chats, and signing out.
                                            
    -   Profile Picture                 -   Profile picture is currently only shown on the home page, and only for Google accounts.
    
    -   Profile button/home             -   Takes you to the profile page where you can change the display name, and see other info.
    
    -   Sign Out                        -   It will sign you out and take you back to the login screen.
    
    -   Android Platform                -   I did not configure it for iOS as I do not have a setup yet for MacOS. Web does not work with AdMobs. Realized this too late to add iOS.
    
    -   Edit Display Name               -   Can be changed by tapping it under the Profile page. When done typing, pressing enter saves the new string to Firebase and updates displayname.
    
    -   ADMOBS!                         -   Ads are shown in the form of Banner ads at the main screen and an interstitial ad when going from chat to home page. A rewarded ad is available from the drawer, but no point in using.
    
Things that are NOT working:
    
    -   Tests                           -   I did not get integration tests fully functional. I was in the process of making a mock auth setup so it could simulate the necessary features.
                                        
                                        -   These were much more difficult to set up than I anticipated. I was not even able to set up a listview scroll test due to the requirements of logging in.
                                        
                                        -   I am planning to work on and understand these on my own time after this assignment, as I feel like they are powerful and necessary to know for the real world.
                                        
                                        -   The flutter tutorial provided was followed, but it is only somewhat applicable to my app due to login requirements.
                                        
                                        -   As I type this, I realize I could have had it simulate logging in anonymously, but the conversation list would be empty and need to be populated.
                                        
                                        -   Of course, I am able to get tests to pass as long as they do not try to do anything important.
    
    
    
    -   iOS/Web Platform                -   I did not realize until later that AdMobs would break web functionality. I did not have a chance to ensure iOS compatibility and did not set up .plist or anything for it.
                                        
A screen recording is included. 

Thanks,
Jason Hess

To run it, you can extract to any directory and then open it in Android Studio. Or, you can use the screen recording, which shows the entire app in a little over a minute and is pausable.

Things I plan to work on in the future:

    -   Cleaner UI                      -   UI is not very pretty, but I am not a graphic artist nor UI expert. I could certainly improve that in the future.
    
    -   Cleaner code                    -   Code is a little bit of a spaghetti mess, I could separate things into separate files/classes a little bit better in the future.
    
    -   Prettier messages               -   Messages right now are very basic Paragraph/Text objects in a list. Could improve these with profile pictures, bubbles, etc.
    
    -   Integration Tests               -   These are important in actual development.
    
    -   iOS Development