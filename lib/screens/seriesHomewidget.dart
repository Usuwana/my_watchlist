import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:my_watchlist/auth_gate.dart';
import '../../../../screens/about.dart';
import '../utils/imports.dart';
import 'package:url_launcher/url_launcher.dart';

class SeriesHomeWidget extends StatefulWidget {
  const SeriesHomeWidget({Key? key}) : super(key: key);

  @override
  _SeriesHomeWidgetState createState() => _SeriesHomeWidgetState();
}

class _SeriesHomeWidgetState extends State<SeriesHomeWidget> {
  int _selectedIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  List<Widget> _widgetOptions = <Widget>[
    OnAir(),
    PopularSeries(),
    TopRatedSeries(),
    LikedSeries()
  ];
  String _linkedIn = 'https://my.linkedin.com/in/tatendausuwana';
  String tmdb = "https://www.themoviedb.org/";

  @override
  void initState() {
    super.initState();
  }

  void _launchEmail() async {
    if (!await launch(
        'mailto:tatemapu@gmail.com?subject=This is Subject Title'))
      throw 'Could not launch mail';
  }

  void _launchURL() async {
    if (!await launch(_linkedIn)) throw 'Could not launch $_linkedIn';
  }

  void _launchTMDB() async {
    if (!await launch(tmdb)) throw 'Could not launch $tmdb';
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  final _advancedDrawerController = AdvancedDrawerController();
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _deleteUser(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool reAuthSuccess = false;

      while (!reAuthSuccess) {
        // Keep prompting until re-authentication succeeds or user cancels
        try {
          // Securely prompt the user for their password
          final password = await _getPasswordFromUser(context);

          if (password == null) {
            // User canceled the dialog, exit the loop
            break;
          }

          // Re-authenticate the user with the provided password
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );

          await user.reauthenticateWithCredential(credential);
          reAuthSuccess =
              true; // Exit the loop if re-authentication is successful

          // Now delete the user
          await user.delete();
          print('User deleted successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account deleted successfully')),
          );

          // Redirect to login page or exit the app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthGate()),
          );
        } catch (e) {
          if (e is FirebaseAuthException && e.code == 'wrong-password') {
            // Inform the user that the password was incorrect and prompt again
            _showErrorDialog(context, 'Incorrect password. Please try again.');
          } else {
            print('Error during re-authentication: $e');
            _showErrorDialog(
                context, 'Failed to delete account. Try again later.');
            break; // Exit the loop if it's another type of error
          }
        }
      }
    }
  }

// Function to securely get the user's password and handle error feedback
  Future<String?> _getPasswordFromUser(BuildContext context) async {
    String? password;
    String? errorMessage;

    // Keep showing the dialog until a valid password is provided or user cancels
    while (password == null) {
      password = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController passwordController = TextEditingController();

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Re-enter Password'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(),
                        errorText: errorMessage, // Show error message if set
                      ),
                      obscureText: true, // Hide the password
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(null); // Close without returning a password
                    },
                  ),
                  TextButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      if (passwordController.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Password cannot be empty';
                        });
                      } else {
                        Navigator.of(context).pop(passwordController
                            .text); // Return the entered password
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      // If user canceled, break out of the loop
      if (password == null) break;
    }

    return password;
  }

// Show an error dialog with a custom message
  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the error dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: true,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
              leading: IconButton(
                color: Colors.blueGrey,
                iconSize: 30,
                onPressed: _handleMenuButtonPressed,
                icon: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _advancedDrawerController,
                  builder: (_, value, __) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: Icon(
                        value.visible ? Icons.clear : Icons.menu,
                        key: ValueKey<bool>(value.visible),
                      ),
                    );
                  },
                ),
              ),
              iconTheme: IconThemeData(color: Colors.blueGrey, size: 30),
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Center(
                child: Image.asset(
                  'assets/app_logo.png',
                  scale: 10,
                ),
              )),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.blueGrey,
          key: _bottomNavigationKey,
          backgroundColor: Colors.white,
          items: <Widget>[
            Icon(MyFlutterApp.trending, size: 50),
            Icon(MyFlutterApp.popular, size: 50),
            Icon(MyFlutterApp.rated, size: 50),
            Icon(MyFlutterApp.like, size: 50)
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/app_logo.png',
                  ),
                ),
                ListTile(
                  title: Text('Movies'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MovieHomeWidget(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Series'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SeriesHomeWidget(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('About the application'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => About(),
                      ),
                    );
                  },
                ),
                ListTile(title: Text('About the developer'), onTap: _launchURL),
                ListTile(title: Text('Send us feedback'), onTap: _launchEmail),
                ListTile(
                    title: Text('Delete Account'),
                    onTap: () {
                      _getPasswordFromUser(context);
                      _deleteUser(context);
                    }),
                ListTile(title: Text('Sign Out'), onTap: _signOut),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                        ),
                        Text('Powered by '),
                        IconButton(
                            onPressed: _launchTMDB,
                            icon: Image.asset(
                              "assets/tmdb.png",
                              scale: 5,
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
