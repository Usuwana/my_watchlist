import 'package:google_fonts/google_fonts.dart';
import '../utils/imports.dart';

class SomethingWentWrong extends StatefulWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  _SomethingWentWrongState createState() => _SomethingWentWrongState();
}

class _SomethingWentWrongState extends State<SomethingWentWrong> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
              child: Container(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  Text("Oops!",
                      style: GoogleFonts.getFont('Montserrat').copyWith(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  Text(
                      "Something went wrong. Please make sure you have an internet connection and restart the app.",
                      style: GoogleFonts.getFont('Montserrat').copyWith(
                        fontSize: 15,
                        color: Colors.black,
                      ))
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
