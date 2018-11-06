// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../utils/styles.dart';

// This class builds the Login Account screen of the application.
class LoginAccount extends StatefulWidget {
  LoginAccount({
    Key key,
  }) : super(key: key);

  @override
  LoginAccountState createState() {
    return LoginAccountState();
  }
}

class LoginAccountState extends State<LoginAccount> {
  // Declarations.
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form.
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  final _loginAccountFormKey = GlobalKey<FormState>();
  bool _rememberMe;
  bool _autoValidate;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _rememberMe = false;
    _autoValidate = false;
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Green,
      child: new GestureDetector(
        // Dismiss keyboard and un-focus fields.
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: new ListView(
          padding: const EdgeInsets.only(
            top: 60.0,
          ),
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: new Align(
                alignment: Alignment.topLeft,
                child: new Text(
                  Translations.of(context).text('login'),
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 40.0,
                bottom: 20.0,
              ),
              child: new Form(
                key: _loginAccountFormKey,
                autovalidate: _autoValidate,
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: new Theme(
                        // Just to change the underline colors.
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.white,
                          hintColor: Colors.white70,
                        ),
                        child: new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: new InputDecoration(
                            labelText: Translations.of(context)
                                .text('account_email'),
                            hintText: Translations.of(context)
                                .text('account_email_placeholder'),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return Translations.of(context)
                                .text('error_account_email');
                            }
                            // This is just a regular expression for
                            // email addresses.
                            final RegExp emailExp = new RegExp(
                                "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                                    "\\@" +
                                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                                    "(" +
                                    "\\." +
                                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                                    ")+"
                            );
                            if (!emailExp.hasMatch(value)) {
                              // The email is invalid.
                              return Translations.of(context)
                                .text('error_valid_account_email');
                            }
                          },
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                        left: 30.0,
                        right: 30.0,
                      ),
                      child: new Theme(
                        // Just to change the underline colors.
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.white,
                          hintColor: Colors.white70,
                        ),
                        child: new TextFormField(
                          obscureText: true,
                          autocorrect: false,
                          decoration: new InputDecoration(
                            labelText: Translations.of(context)
                                .text('account_password'),
                            hintText: Translations.of(context)
                                .text('account_password_placeholder'),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return Translations.of(context)
                                .text('error_account_password');
                            }
                            if(value.length < 6) {
                              return Translations.of(context)
                                .text('error_valid_account_password');
                            }
                          },
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              new Checkbox(
                                value: _rememberMe,
                                activeColor: themeColor,
                                onChanged: (value) {
                                  FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                  setState(() {
                                    _rememberMe = value;
                                  });
                                },
                              ),
                              new GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: new Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: new Text(
                                    Translations.of(context).text('remember'),
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(
                              right: 10.0,
                            ),
                            child: new FlatButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () {
                                FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                                print('Do stuff!');
                              },
                              child: new Text(
                                Translations.of(context)
                                  .text('forgot_password'),
                                style: Theme.of(context).textTheme.body2
                                  .copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
              ),
              child: new SizedBox(
                width: double.infinity,
                height: 50.0,
                child: new FlatButton(
                  color: Colors.white,
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    final form = _loginAccountFormKey.currentState;
                    if(form.validate()){
                      print('Save user!');
                      if(_rememberMe) {
                        print('Persist user!');
                      }
                    }
                    else {
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  },
                  child: new Text(
                    Translations.of(context).text('login'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: themeColor,
                    ),
                  ),
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                bottom: 10.0,
              ),
              child: new Text(
                Translations.of(context).text('dont_have_account'),
                textAlign: TextAlign.center,
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new FlatButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    print('Do stuff!');
                  },
                  child: new Text(
                    Translations.of(context).text('click_create'),
                    style: Theme.of(context).textTheme.body2.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}