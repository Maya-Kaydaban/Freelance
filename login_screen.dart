import 'package:end_project/ForgetPassword/forget_password_screen.dart';
import 'package:end_project/Services/global_methods.dart';
import 'package:end_project/Services/global_variable.dart';
import 'package:end_project/SignUpPage/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  bool _isloading = false;
  late Animation<double> _animation;
  late AnimationController _animationController;
  final FocusNode _passFocusNode = FocusNode();
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final TextEditingController _emailTextController =
      TextEditingController(text: '');
  final TextEditingController _passTextController =
      TextEditingController(text: '');
  bool _obscuretext = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    _animationController.dispose();
    _passTextController.dispose();
    _emailTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(
            (animationStatus) {
              if (animationStatus == AnimationStatus.completed) {
                _animationController.reset();
                _animationController.forward();
              }
            },
          );
    _animationController.forward();
    super.initState();
  }

  void _loginForm(String email, String password) async {
    final isvalid = _loginFormKey.currentState!.validate();
    if (isvalid) {
      setState(() {
        _isloading = true;
      });
      try {
        final credential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isloading = false;
        });
        if (e.code == 'user-not-found') {
          GlobalMethods.showErrorDialog(
              ctx: context, error: "No user found for that email.");
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          GlobalMethods.showErrorDialog(
              ctx: context, error: "Wrong password provided for that user.");
          print('Wrong password provided for that user.');
        } else {
          GlobalMethods.showErrorDialog(ctx: context, error: e.toString());
        }
      }
    }
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            loginUrlImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 80, left: 80),
                    child: Image.asset("assets/images/login.png"),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return "Please Enter a Valid email Address";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: _passFocusNode,
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passTextController,
                            obscureText: !_obscuretext,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 7) {
                                return "please enter a valid password";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintText: "PassWord",
                                hintStyle: const TextStyle(color: Colors.white),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscuretext = !_obscuretext;
                                    });
                                  },
                                  child: Icon(
                                      color: Colors.white,
                                      _obscuretext
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                )
                                ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordScreen()));
                                },
                                child: const Text(
                                  "Forget Password ?",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            onPressed: () {
                              _loginForm(
                                  _emailTextController.text
                                      .trim()
                                      .toLowerCase(),
                                  _passTextController.text.trim());
                            },
                            color: Colors.cyan,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Center(
                            child: RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: "Do not have an account ??",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const TextSpan(text: "  "),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupPage())),
                                  text: "Signup",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold)),
                            ])),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
