import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/screens/contacts/add_contact_view.dart';
import 'package:dapp/screens/contacts/my_contact_view.dart';
import 'package:dapp/screens/groups/expense/add_expense_view.dart';
import 'package:dapp/screens/groups/add_group_view.dart';
import 'package:dapp/screens/groups/expense/select_category_view.dart';
import 'package:dapp/screens/groups/expense/select_payer_view.dart';
import 'package:dapp/screens/groups/expense/select_currency_view.dart';
import 'package:dapp/screens/groups/expense/select_split_method_view.dart';
import 'package:dapp/screens/groups/group_profile_view.dart';
import 'package:dapp/screens/home_view.dart';
import 'package:dapp/screens/manage_transaction_view.dart';
import 'package:dapp/screens/groups/my_group_view.dart';
import 'package:dapp/screens/my_portfolio_view.dart';
import 'package:dapp/wrapper/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  //Declare named constructor
  AppNavigation._();

  static String initRoute = '/home';

  //Private navigators key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _rootNavigatorGroups =
      GlobalKey<NavigatorState>(debugLabel: 'shellGroups');
  static final _rootNavigatorTransaction =
      GlobalKey<NavigatorState>(debugLabel: 'shellTransaction');
  static final _rootNavigatorPortfolio =
      GlobalKey<NavigatorState>(debugLabel: 'shellPortfolio');

  //Go Router configuration
  static final GoRouter router = GoRouter(
    initialLocation: initRoute,
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainWrapper(
              navigationShell: navigationShell,
            );
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(navigatorKey: _rootNavigatorGroups, routes: [
              GoRoute(
                  path: '/groups',
                  name: 'Groups',
                  builder: (context, state) {
                    return const MyGroupView();
                  },
                  routes: [
                    GoRoute(
                      path: 'contact',
                      name: 'contact',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const MyContactView(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                      path: 'addContact',
                      name: 'addContact',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const AddContactView(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                      path: 'addGroup',
                      name: 'addGroup',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const AddGroupView(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                      path: 'groupProfile/:groupID',
                      name: 'groupProfile',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: GroupProfileView(
                            groupID: state.pathParameters['groupID']!),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                        path: 'addExpense',
                        name: 'addExpense',
                        pageBuilder: (context, state) {
                          final GroupProfile groupProfile =
                              state.extra as GroupProfile;
                          return CustomTransitionPage<void>(
                            key: state.pageKey,
                            child: AddExpenseView(groupProfile: groupProfile),
                            transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          );
                        }),
                    GoRoute(
                      path: 'selectCategory',
                      name: 'selectCategory',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const SelectCategoryView(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                      path: 'selectCurrency',
                      name: 'selectCurrency',
                      pageBuilder: (context, state) =>
                          CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: const SelectCurrencyView(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    GoRoute(
                        path: 'selectPayer',
                        name: 'selectPayer',
                        pageBuilder: (context, state) {
                          final List<String> selectedMembers =
                              state.extra as List<String>;
                          return CustomTransitionPage<void>(
                            key: state.pageKey,
                            child: SelectPayerView(
                                selectedMembers: selectedMembers),
                            transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          );
                        }),
                    GoRoute(
                        path: 'selectSplitMethod',
                        name: 'selectSplitMethod',
                        pageBuilder: (context, state) =>
                            CustomTransitionPage<void>(
                              key: state.pageKey,
                              child: const SelectSplitMethodView(),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            )),
                  ])
            ]),
            StatefulShellBranch(navigatorKey: _rootNavigatorHome, routes: [
              GoRoute(
                path: '/home',
                name: 'Home',
                builder: (context, state) {
                  return const HomeView();
                },
                /* routes: [
                  GoRoute(
                    path: 'subHome',
                    name: 'subHome',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: const SubHomeView(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                    ),
                  ),
                ], 

                //On other pages
                onPressed: (){
                  context.goNamed('subHome')
                }
                
                */
              )
            ]),
            StatefulShellBranch(
                navigatorKey: _rootNavigatorTransaction,
                routes: [
                  GoRoute(
                    path: '/transaction',
                    name: 'Transaction',
                    builder: (context, state) {
                      return const ManageTransactionView();
                    },
                  )
                ]),
            StatefulShellBranch(navigatorKey: _rootNavigatorPortfolio, routes: [
              GoRoute(
                path: '/portfolio',
                name: 'Portfolio',
                builder: (context, state) {
                  return const MyPortfolioView();
                },
              )
            ])
          ])
    ],
  );
}
