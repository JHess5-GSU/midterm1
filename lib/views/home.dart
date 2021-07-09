import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger_clone/helperfunctions/sharedpref_helper.dart';
import 'package:messenger_clone/services/auth.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:messenger_clone/views/chatscreen.dart';
import 'package:messenger_clone/views/signin.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:messenger_clone/ad_helper.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {
  bool isSearching = false;
  String myName, myProfilePic, myUserName, myEmail;
  Stream usersStream, chatRoomsStream;

  Future<InitializationStatus> _initGoogleMobileAds() async {
    return MobileAds.instance.initialize();
  }


  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          this._rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(

                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profileUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(name), Text(email)])
          ],
        ),
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
      _loadRewardedAd();
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd.load();
      _loadRewardedAd();

    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text("Midterm Chat"),
        centerTitle: true,
        actions: [

          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),

      drawer: Drawer(

        child: ListView(

          padding: EdgeInsets.all(10),
          children: <Widget>[

            Container(
              padding: EdgeInsets.only(top: 75),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: Text('Profile'),
                ),
              ),
            ),

            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: Text('Chats'),
                ),
              ),
            ),

            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    showLogOutAlertDialog(context);
                  },
                  child: Text('Logout'),
                ),
              ),
            ),

            _HomeState()._isRewardedAdReady ? Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _HomeState()._rewardedAd.show(
                        onUserEarnedReward: (_, reward){}
                    );

                  },
                  child: Text('SHOW ME A DUMB REWARDED AD!'),
                ),
              ),
            ) : Container(),
          ],
        ),
      ),

      body: FutureBuilder<void>(

        future: _initGoogleMobileAds(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                    onTap: () {
                      isSearching = false;
                      searchUsernameEditingController.text = "";
                      setState(() {});
                    },
                    child: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_back)),
                  )
                      :
                  Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                                controller: searchUsernameEditingController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search for Username"),
                              )),
                          GestureDetector(
                              onTap: () {
                                if (searchUsernameEditingController.text !=
                                    "") {
                                  onSearchBtnClick();
                                }
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    ),

                  ),
                ],
              ),

              (_isBannerAdReady) ?
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),

                  )
              )
                  : Container(),

              Divider(),

              Container(
                height: MediaQuery.of(context).size.height-240,
              child: isSearching ? searchUsersList() : chatRoomsList(),
              ),
            ],
          ),
        );
      },
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print(
        "${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                profilePicUrl,
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 115,
                  child: Text(
                  name,
                  style: TextStyle(fontSize: 20), softWrap: false, overflow: TextOverflow.ellipsis
                  ),
                ),
                SizedBox(height: 3),
                Container(
                  width: MediaQuery.of(context).size.width - 115,
                child: Text(widget.lastMessage, softWrap: false, overflow: TextOverflow.ellipsis)
                ),
              ],
            ),
            Divider(height: 10),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      drawer: MyDrawer(),

      body: ListView(
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (true) ...[


                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
                      child: Center(
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "${FirebaseAuth.instance.currentUser.displayName}",
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 25),
                          onSubmitted: (String value) {FirebaseAuth.instance.currentUser.updateDisplayName(value); FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).update({
                            'displayName': value,
                          });;},
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    height: 5,

                    indent: 20,
                    endIndent: 20,
                  ),

                  Center(child: Text("Tap Above to Change Profile Name", style: TextStyle(color: Colors.grey, fontSize: 15)),),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Email: ${FirebaseAuth.instance.currentUser.email}",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),


                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Bio: Hi, I almost know what I'm doing.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "Instagram: jason.hess",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "More stuff will go here later, I promise.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Text(
                          "This is just to show that the profile page scrolls whenever it needs to. I quite like this class at the moment. I've learned a lot.",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 20)
                      ),
                    ),
                  ),

                  Divider(
                    height: 40,
                    thickness: 3,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              ],
            ),

        ],

      ),

    );
  }
}

class MyDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.all(10),
        children: <Widget>[

          Container(
            padding: EdgeInsets.only(top: 75),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Text('Profile'),
              ),
            ),
          ),

          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                child: Text('Chats'),
              ),
            ),
          ),

          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {
                  showLogOutAlertDialog(context);
                },
                child: Text('Logout'),
              ),
            ),
          ),

          _HomeState()._isRewardedAdReady ? Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {
                  Navigator.pop(context);
                    _HomeState()._rewardedAd.show(
                    onUserEarnedReward: (_, reward){}
                  );

                },
                child: Text('SHOW ME A DUMB REWARDED AD!'),
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }
}

showLogOutAlertDialog(BuildContext context) {

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Yes"),
    onPressed: () {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          SignIn()), (Route<dynamic> route) => false);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Confirm Logout"),

    backgroundColor: Colors.grey,
    content: Text("Are you sure you wish to log out?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}