// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';

// This class lets you add a new credit card to the payment methods.
class AddCard extends StatefulWidget {
  AddCard({
    Key key,
  }) : super(key: key);

  @override
  AddCardState createState() {
    return AddCardState();
  }
}

class AddCardState extends State<AddCard> {
  // Declarations.
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form.
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  final _addCardFormKey = GlobalKey<FormState>();
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
            title: Translations.of(context).text('add_card'),
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
            child: new Form(
              key: _addCardFormKey,
              autovalidate: _autoValidate,
              child: new Theme(
                data: Theme.of(context).copyWith(
                  hintColor: themeLightGrey,
                ),
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      keyboardType: TextInputType.number,
                      style: Theme.of(context).textTheme.body2
                        .copyWith(
                          color: themeGrey,
                        ),
                      decoration: new InputDecoration(
                        labelText: Translations.of(context)
                          .text('card_number'),
                        labelStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeColor,
                          ),
                        hintText: '0000 0000 0000 0000',
                        hintStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeLightGrey,
                          ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return Translations.of(context)
                            .text('error_card_number');
                        }
                        final RegExp nameExp = new RegExp(
                          r'^(?:4\d{3}|5[1-5]\d{2}|6011|3[47]\d{2})([-\s]?)'
                          r'\d{4}\1\d{4}\1\d{3,4}$'
                        );
                        if (!nameExp.hasMatch(value)) {
                          // The card is invalid.
                          return Translations.of(context)
                            .text('error_valid_card_number');
                        }
                      },
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(
                              right: 10.0,
                            ),
                            child: new TextFormField(
                              keyboardType: TextInputType.datetime,
                              style: Theme.of(context).textTheme.body2
                                .copyWith(
                                  color: themeGrey,
                                ),
                              decoration: new InputDecoration(
                                labelText: Translations.of(context)
                                  .text('expiry_date'),
                                labelStyle: Theme.of(context).textTheme.body2
                                  .copyWith(
                                    color: themeColor,
                                  ),
                                hintText: Translations.of(context)
                                  .text('expiry_date_placeholder'),
                                hintStyle: Theme.of(context).textTheme.body2
                                  .copyWith(
                                    color: themeLightGrey,
                                  ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return Translations.of(context)
                                    .text('error_expiry_date');
                                }
                                final RegExp nameExp = new RegExp(
                                  r'^(0[1-9]|10|11|12)/20[1-9]{2}$'
                                );
                                if (!nameExp.hasMatch(value)) {
                                  // The expiry date is invalid.
                                  return Translations.of(context)
                                    .text('error_valid_expiry_date');
                                }
                              },
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                            ),
                            child: new TextFormField(
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.body2
                                .copyWith(
                                  color: themeGrey,
                                ),
                              decoration: new InputDecoration(
                                labelText: Translations.of(context)
                                  .text('security_code'),
                                labelStyle: Theme.of(context).textTheme.body2
                                  .copyWith(
                                    color: themeColor,
                                  ),
                                hintText: 'CVV',
                                hintStyle: Theme.of(context).textTheme.body2
                                  .copyWith(
                                    color: themeLightGrey,
                                  ),
                                errorMaxLines: 2,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return Translations.of(context)
                                    .text('error_security_code');
                                }
                                final RegExp nameExp = new RegExp(
                                  r'^[0-9]{3}$'
                                );
                                if (!nameExp.hasMatch(value)) {
                                  // The security code is invalid.
                                  return Translations.of(context)
                                    .text('error_valid_security_code');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    new TextFormField(
                      keyboardType: TextInputType.text,
                      style: Theme.of(context).textTheme.body2
                        .copyWith(
                          color: themeGrey,
                        ),
                      decoration: new InputDecoration(
                        labelText: Translations.of(context)
                          .text('country'),
                        labelStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeColor,
                          ),
                        hintText: 'Portugal',
                        hintStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                            color: themeLightGrey,
                          ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return Translations.of(context)
                            .text('error_country');
                        }
                        final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
                        if (!nameExp.hasMatch(value)) {
                          // The country is invalid.
                          return Translations.of(context)
                            .text('error_valid_country');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 0.0),
            child: new Column(
              children: <Widget>[
                new SizedBox(
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
                      final form = _addCardFormKey.currentState;
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
                      Translations.of(context).text('save_card'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: new ButtonTheme(
                    height: 25.0,
                    child: new FlatButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        print('Do stuff!');
                      },
                      child: new Text(
                        Translations.of(context).text('create_account_now'),
                        style: Theme.of(context).textTheme.body1.copyWith(
                          decoration: TextDecoration.underline,
                          color: Color(0xFF3BB2B8),
                        ),
                      ),
                    ),
                  ),
                ),
                new Text(
                  Translations.of(context).text('account_info_card'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.body2.copyWith(
                    color: themeGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
