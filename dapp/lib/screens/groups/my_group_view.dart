import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/global_state/providers/group_profile_state_provider.dart';
import 'package:dapp/widgets/empty_message_card.dart';
import 'package:dapp/widgets/group_list_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyGroupView extends ConsumerStatefulWidget {
  const MyGroupView({super.key});

  @override
  ConsumerState<MyGroupView> createState() => _MyGroupViewState();
}

class _MyGroupViewState extends ConsumerState<MyGroupView> {
  @override
  void initState() {
    super.initState();
    final groupProfileNotifier = ref.read(groupProfileStateProvider.notifier);
    if (groupProfileNotifier.isEmpty) {
      groupProfileNotifier.loadGroupProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    Map<String, GroupProfile> groupsMapping =
        ref.watch(groupProfileStateProvider);
    List<GroupProfile> groupProfiles = groupsMapping.values.toList();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('contact');
            },
            icon: const Icon(Icons.import_contacts_sharp),
            tooltip: 'View Contacts',
            iconSize: 28.0,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: deviceSize.width,
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('addGroup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromRGBO(35, 217, 157, 1.0), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text('New Group', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            if (groupProfiles.isEmpty)
              emptyMessageCard('You are not in any groups')
            else
              ...groupProfiles.map(
                  (groupProfile) => GroupListCard(groupProfile: groupProfile)),
            const SizedBox(height: 130.0),
          ],
        ),
      ),
    );
  }
}
