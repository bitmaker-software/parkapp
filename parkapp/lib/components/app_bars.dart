// External imports.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

//Internal imports.
import '../components/gradients.dart';

// AppBar generator with title and other widgets
class BigAppBar extends StatelessWidget implements PreferredSizeWidget {
  BigAppBar({
    Key key,
    @required this.title,
    this.bottomWidget,
    this.backgroundImage,
    this.avatar,
  }) : super(key: key);

  final String title;
  final Widget bottomWidget;
  final CachedNetworkImage backgroundImage;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
          ),
          child: new CircleAvatar(
            radius: 18.0,
            child: new Image.asset(avatar ?? 'lib/assets/avatar.png'),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
      flexibleSpace: new CustomBarGradient(
        backgroundImage: backgroundImage,
        child: new Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 30.0,
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child: new Text(
                  title,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              bottomWidget,
            ].where((widget) => widget != null).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(211.0);
}

// AppBar generator with title and other widgets
class SliverBigAppBar extends StatelessWidget {
  SliverBigAppBar({
    Key key,
    @required this.title,
    @required this.titleOpacity,
    this.bottomWidget,
    this.backgroundImage,
    this.avatar,
  }) : super(key: key);

  final String title;
  final double titleOpacity;
  final Widget bottomWidget;
  final CachedNetworkImage backgroundImage;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return new SliverAppBar(
      expandedHeight: 211.0,
      pinned: true,
      forceElevated: true,
      title: new Opacity(
        opacity: titleOpacity,
        child: new Padding(
          padding: new EdgeInsets.only(
            left: ModalRoute.of(context).canPop ||
              Theme.of(context).platform == TargetPlatform.iOS ?
              0.0 : 14.0,
          ),
          child: new Text(
            title,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ),
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      actions: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
          ),
          child: new CircleAvatar(
            radius: 18.0,
            child: new Image.asset(avatar ?? 'lib/assets/avatar.png'),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
      flexibleSpace: new CustomBarGradient(
        backgroundImage: backgroundImage,
        child: new FlexibleSpaceBar(
          background: new SafeArea(
            child: new Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Align(
                    alignment: Alignment.centerLeft,
                    child: new Text(
                      title,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  bottomWidget,
                ].where((widget) => widget != null).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// AppBar generator with title
class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  TitleAppBar({
    Key key,
    @required this.title,
    this.avatar,
  }) : super(key: key);

  final String title;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
          ),
          child: new CircleAvatar(
            radius: 18.0,
            child: new Image.asset(avatar ?? 'lib/assets/avatar.png'),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
      flexibleSpace: new CustomBarGradient(
        child: new Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 30.0,
          ),
          child: new Align(
            alignment: Alignment.bottomLeft,
            child: new Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ),
              child: new Text(
                title,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(116.0);
}

// AppBar generator with title
class SliverTitleAppBar extends StatelessWidget {
  SliverTitleAppBar({
    Key key,
    @required this.title,
    @required this.titleOpacity,
    this.bottomWidget,
    this.avatar,
  }) : super(key: key);

  final String title;
  final double titleOpacity;
  final Widget bottomWidget;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return new SliverAppBar(
      expandedHeight: 116.0,
      pinned: true,
      forceElevated: true,
      title: new Opacity(
        opacity: titleOpacity,
        child: new Padding(
          padding: new EdgeInsets.only(
            left: ModalRoute.of(context).canPop ||
                Theme.of(context).platform == TargetPlatform.iOS ?
            0.0 : 14.0,
          ),
          child: new Text(
            title,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ),
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      actions: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
          ),
          child: new CircleAvatar(
            radius: 18.0,
            child: new Image.asset(avatar ?? 'lib/assets/avatar.png'),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
      flexibleSpace: new CustomBarGradient(
        child: new FlexibleSpaceBar(
          background: new SafeArea(
            child: new Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
              ),
              child: new Align(
                alignment: Alignment.bottomLeft,
                child: new Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                  ),
                  child: new Text(
                    title,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// AppBar generator without title
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget{
  SimpleAppBar({
    Key key,
    @required this.title,
    this.actionButton,
    this.avatar,
  }) : super(key: key);

  final String title;
  final Widget actionButton;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return new AppBar(
      title: new Padding(
        padding: new EdgeInsets.only(
          left: ModalRoute.of(context).canPop ||
            Theme.of(context).platform == TargetPlatform.iOS ?
            0.0 : 14.0,
        ),
        child: new Text(
          title,
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      actions: <Widget>[
        actionButton
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

// AppBar generator with tabs
class TabsAppBar extends StatelessWidget implements PreferredSizeWidget {
  TabsAppBar({
    Key key,
    @required this.tabController,
    @required this.action,
    @required this.tabs,
    this.avatar,
  }) : super(key: key);

  final TabController tabController;
  final String action;
  final List<String> tabs;
  final Image avatar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        new FlatButton(
          textColor: Colors.white,
          onPressed: () => print('Do Stuff'),
          child: new Text(
            action,
            style: Theme.of(context).textTheme.body2.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
          ),
          child: new CircleAvatar(
            radius: 18.0,
            child: new Image.asset(avatar ?? 'lib/assets/avatar.png'),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context).canPop ?
      new Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: new BackButton(),
      ) : null,
      flexibleSpace: new CustomBarGradient(
        child: new Padding(
          padding: const EdgeInsets.only(
            left: 14.0,
            right: 14.0,
          ),
          child: new Align(
            alignment: Alignment.bottomLeft,
            child: new TabBar(
              controller: tabController,
              indicatorWeight: 4.0,
              labelStyle: Theme.of(context).textTheme.button,
              tabs: tabs.map((String tab) {
                return new Tab(
                  text: tab,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(116.0);
}