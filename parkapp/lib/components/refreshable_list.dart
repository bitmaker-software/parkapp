// External imports
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/styles.dart';
import '../utils/translations.dart';

// Refreshable list
class RefreshableList extends StatelessWidget {
  RefreshableList({
    @required Key key,
    @required this.onRefresh,
    @required this.list,
    this.listValues,
    this.listLabels,
    this.onTap,
    this.withButton: false,
    this.withLabel: false,
    this.buttonTitle,
    this.buttonCallback,
  }) : super(key: key);

  final VoidCallback onRefresh;
  final List<String> list;
  final List<String> listValues;
  final List<String> listLabels;
  final ValueChanged<int> onTap;
  final bool withButton;
  final bool withLabel;
  final String buttonTitle;
  final VoidCallback buttonCallback;

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new RefreshIndicator(
        color: themeColor,
        onRefresh: onRefresh,
        child: new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          key: key,
          itemCount: withButton ? list.length + 1 : list.length,
          itemBuilder: (context, index) {
            if(index == list.length){
              return new DecoratedBox(
                decoration: new BoxDecoration(
                  border: new Border(
                    top: new BorderSide(
                      color: themeLightGrey,
                      width: 0.5,
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
                    onPressed: buttonCallback,
                    child: new Text(
                      buttonTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: themeColor,
                      ),
                    ),
                  ),
                ),
              );
            }
            else {
              return new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new DecoratedBox(
                    decoration: new BoxDecoration(
                      border: withLabel ?
                        new Border(
                          top: new BorderSide(
                            color: themeLightGrey,
                            width: 1.0,
                          ),
                          bottom: new BorderSide(
                            color: themeLightGrey,
                            width: 1.0,
                          ),
                        ) :
                        new Border(
                          bottom: new BorderSide(
                            color: themeLightGrey,
                            width: 1.0,
                          ),
                        ),
                    ),
                    child:new FlatButton(
                      onPressed: onTap != null ? () => onTap(index) : null,
                      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 15.0, 12.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            '${list[index]}',
                            style: Theme.of(context).textTheme.subhead.copyWith(
                              color: themeGrey,
                            ),
                          ),
                          new Row(
                            children: <Widget>[
                              listValues != null
                              ? new Text(
                                '${listValues[index]}',
                                style: Theme.of(context).textTheme.display3
                                  .copyWith(
                                    color: themeDarkGrey,
                                  ),
                              )
                              : null,
                              new Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                ),
                                child: new Icon(
                                  Icons.arrow_forward_ios,
                                  color: themeGrey,
                                  size: 15.0,
                                ),
                              ),
                            ].where((widget) => widget != null).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  withLabel
                  ? new Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: new Text(
                      Translations.of(context).text('monthly_subscription'),
                      style: Theme.of(context).textTheme.body1.copyWith(
                        color: themeGrey,
                      ),
                    ),
                  )
                  : null
                ].where((widget) => widget != null).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}