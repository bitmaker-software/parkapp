// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/translations.dart';
import '../components/app_bars.dart';
import '../utils/styles.dart';

// This class builds the Edit Account screen of the application.
class EditAccount extends StatefulWidget {
  EditAccount({
    Key key,
  }) : super(key: key);

  @override
  EditAccountState createState() {
    return EditAccountState();
  }
}

class EditAccountState extends State<EditAccount> {
  // Declarations.
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form.
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  final _editAccountFormKey = GlobalKey<FormState>();
  bool _autoValidate;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _autoValidate = false;
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      // Dismiss keyboard and un-focus fields.
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: new ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          new TitleAppBar(
            title: Translations.of(context).text('edit_account'),
          ),
          new Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              bottom: 7.0,
            ),
            child: new CircleAvatar(
              radius: 42.0,
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new FlatButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  print('Do stuff!');
                },
                child: new Text(
                  Translations.of(context).text('change_photo'),
                  style: Theme.of(context).textTheme.body2.copyWith(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF3BB2B8),
                  ),
                ),
              ),
            ],
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 22.0, 15.0, 30.0),
            child: new Form(
              key: _editAccountFormKey,
              autovalidate: _autoValidate,
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Text(
                        Translations.of(context).text('account_name'),
                        style: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeDarkGrey,
                          ),
                      ),
                      new Theme(
                        data: Theme.of(context).copyWith(
                          hintColor: themeLightGrey,
                          primaryColor: themeColor,
                        ),
                        child: new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(
                              left: 35.0,
                            ),
                            child: new TextFormField(
                              style: Theme.of(context).textTheme.subhead
                                .copyWith(
                                  color: themeGrey,
                                ),
                              decoration: new InputDecoration(
                                hintText: Translations.of(context)
                                  .text('account_name_placeholder'),
                                hintStyle: Theme.of(context)
                                  .inputDecorationTheme.hintStyle
                                  .copyWith(
                                    color: themeLightGrey,
                                  ),
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
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        Translations.of(context).text('account_email'),
                        style: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeDarkGrey,
                          ),
                      ),
                      new Theme(
                        data: Theme.of(context).copyWith(
                          hintColor: themeLightGrey,
                          primaryColor: themeColor,
                        ),
                        child: new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(
                              left: 35.0,
                            ),
                            child: new TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: Theme.of(context).textTheme.subhead
                                  .copyWith(
                                color: themeGrey,
                              ),
                              decoration: new InputDecoration(
                                hintText: Translations.of(context)
                                  .text('account_email_placeholder'),
                                hintStyle: Theme.of(context)
                                  .inputDecorationTheme.hintStyle
                                  .copyWith(
                                    color: themeLightGrey,
                                  ),
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
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        Translations.of(context).text('account_password'),
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: themeDarkGrey,
                        ),
                      ),
                      new Theme(
                        data: Theme.of(context).copyWith(
                          hintColor: themeLightGrey,
                          primaryColor: themeColor,
                        ),
                        child: new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                            ),
                            child: new TextFormField(
                              obscureText: true,
                              autocorrect: false,
                              style: Theme.of(context).textTheme.subhead
                                  .copyWith(
                                color: themeGrey,
                              ),
                              decoration: new InputDecoration(
                                hintText: Translations.of(context)
                                  .text('account_password_placeholder'),
                                hintStyle: Theme.of(context)
                                  .inputDecorationTheme.hintStyle
                                  .copyWith(
                                    color: themeLightGrey,
                                  ),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(
              right: 40.0,
              left: 40.0,
              bottom: 15.0,
            ),
            child: new SizedBox(
              width: double.infinity,
              height: 50.0,
              child: new FlatButton(
                color: themeColor,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                splashColor: themeColor[400],
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  final form = _editAccountFormKey.currentState;
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
                  Translations.of(context).text('save_account'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          new DecoratedBox(
            decoration: new BoxDecoration(
              border: new Border(
                top: new BorderSide(
                  color: themeLightGrey,
                  width: 1.0,
                ),
                bottom: new BorderSide(
                  color: themeLightGrey,
                  width: 1.0,
                ),
              ),
            ),
            child: new SizedBox(
              width: double.infinity,
              height: 50.0,
              child: new FlatButton(
                splashColor: Colors.red[200],
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  print('Do stuff!');
                },
                child: new Text(
                  Translations.of(context).text('delete_account'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}