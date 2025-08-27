import 'package:equatable/equatable.dart';
// import 'package:fab_circular_menu/fab_circular_menu.dart'; // Temporarily disabled for compatibility
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:redux/redux.dart';
import 'package:katya/global/assets.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/settings/theme-settings/selectors.dart';
import 'package:katya/views/navigation.dart';

calculatePosition(int copyLength) => copyLength * 3.4;

class FabRing extends StatelessWidget {
  final bool showLabels;
  final Alignment alignment;
  final GlobalKey? fabKey; // Simplified for compatibility

  const FabRing({
    Key? key,
    this.fabKey,
    this.alignment = Alignment.bottomRight,
    this.showLabels = false,
  }) : super(key: key);

  onNavigateToPublicSearch(context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, Routes.searchGroups);
  }

  onNavigateToDraft(context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, Routes.searchUsers);
  }

  onNavigateToCreateGroup(context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, Routes.groupCreate);
  }

  onNavigateToCreateGroupPublic(context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, Routes.groupCreatePublic);
  }

  double actionRingDefaultDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width > 640) return 640;
    if (size.width > 400) return size.width * 0.9;
    return size.width;
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
        distinct: true,
        converter: (Store<AppState> store) => _Props.mapStateToProps(store),
        builder: (context, props) {
          final modifier = alignment == Alignment.bottomRight ? -1.0 : .425;

          return FloatingActionButton(
            key: fabKey,
            heroTag: 'fab_main',
            tooltip: Strings.semanticsOpenActionsRing,
            backgroundColor: props.primaryColor,
            onPressed: () {
              // Show a simple dialog with options for now
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Actions'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.public),
                        title: Text(Strings.labelFabCreatePublic),
                        onTap: () {
                          Navigator.pop(context);
                          onNavigateToCreateGroupPublic(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.group),
                        title: Text('Create Group'),
                        onTap: () {
                          Navigator.pop(context);
                          onNavigateToCreateGroup(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.search),
                        title: Text('Search Groups'),
                        onTap: () {
                          Navigator.pop(context);
                          onNavigateToPublicSearch(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.person_search),
                        title: Text('Search Users'),
                        onTap: () {
                          Navigator.pop(context);
                          onNavigateToDraft(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Icon(
              Icons.bubble_chart,
              size: Dimensions.iconSizeLarge,
              color: Colors.white,
            ),
          );
              // All FAB actions are now handled in the dialog
        },
      );
}

class _Props extends Equatable {
  final Color primaryColor;

  const _Props({
    required this.primaryColor,
  });

  @override
  List<Object> get props => [
        primaryColor,
      ];

  static _Props mapStateToProps(Store<AppState> store) => _Props(
        primaryColor: selectPrimaryColor(store.state.settingsStore.themeSettings),
      );
}
