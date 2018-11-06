// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../utils/styles.dart';

// This class builds the Register Account screen of the application.
class CreateAccount extends StatefulWidget {
  CreateAccount({
    Key key,
  }) : super(key: key);

  @override
  CreateAccountState createState() {
    return CreateAccountState();
  }
}

class CreateAccountState extends State<CreateAccount> {
  // Declarations.
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form.
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  final _createAccountFormKey = GlobalKey<FormState>();
  bool _termsConditions;
  bool _termsConditionsError;
  bool _autoValidate;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _termsConditions = false;
    _termsConditionsError = false;
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
                  Translations.of(context).text('create_account'),
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
                key: _createAccountFormKey,
                autovalidate: _autoValidate,
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: new Theme(
                        // Just to change the underline colors.
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.white,
                          hintColor: Colors.white70,
                        ),
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            labelText: Translations.of(context)
                              .text('account_name'),
                            hintText: Translations.of(context)
                              .text('account_name_placeholder'),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return Translations.of(context)
                                .text('error_account_name');
                            }
                            final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
                            if (!nameExp.hasMatch(value)) {
                              // The name is invalid.
                              return Translations.of(context)
                                .text('error_valid_account_name');
                            }
                          },
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
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
                        children: <Widget>[
                          new Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: _termsConditionsError
                                ? Colors.red[700]
                                : Colors.white,
                            ),
                            child: new Checkbox(
                              value: _termsConditions,
                              activeColor: themeColor,
                              onChanged: (value) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                setState(() {
                                  _termsConditionsError = false;
                                  _termsConditions = value;
                                });
                              },
                            ),
                          ),
                          new FlatButton(
                            padding: const EdgeInsets.all(0.0),
                            splashColor: Colors.white10,
                            onPressed: () {
                              FocusScope.of(context)
                                .requestFocus(new FocusNode());
                              print('Do stuff!');
                            },
                            child: new Text(
                              Translations.of(context).text('terms_conditions'),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _termsConditionsError
                     ? new Padding(
                       padding: const EdgeInsets.symmetric(
                         horizontal: 30.0,
                       ),
                       child: new Align(
                         alignment: Alignment.centerLeft,
                         child: new Text(
                           Translations.of(context).text('accept_terms_conditions'),
                           style: Theme.of(context).textTheme.caption.copyWith(
                             color: Colors.red[700],
                           ),
                         ),
                       ),
                     )
                     : null,
                  ].where((widget) => widget != null).toList(),
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
                  splashColor: themeColor[200],
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    final form = _createAccountFormKey.currentState;
                    if(!_termsConditions){
                      setState(() {
                        _termsConditionsError = true;
                      });
                    }
                    if(form.validate()){
                      print('Save user!');
                    }
                    else {
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  },
                  child: new Text(
                    Translations.of(context).text('create_account'),
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
                Translations.of(context).text('already_have_account'),
                textAlign: TextAlign.center,
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new FlatButton(
                  splashColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    print('Do stuff!');
                    },
                  child: new Text(
                    Translations.of(context).text('click_login'),
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
