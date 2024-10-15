import 'package:dapp/custom_exception/custom_exception.dart';
import 'package:dapp/global_state/providers/group_service_provider.dart';
import 'package:dapp/model/group_profile_model.dart';
import 'package:dapp/services/group_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupListCard extends ConsumerWidget {
  final GroupProfile groupProfile;

  const GroupListCard({super.key, required this.groupProfile});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupService = ref.watch(groupServiceProvider);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: () {
          context.goNamed('groupProfile',
              pathParameters: {'groupID': groupProfile.groupID});
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(groupProfile.groupImagePath),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupProfile.groupName,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text('${groupProfile.membersCount} Members'),
                    Text('Balance: ${groupProfile.deposit}',
                        style: const TextStyle(
                            color: Colors.teal, fontSize: 18.0)),
                    /* Text(
                      'Latest transaction: ${groupProfile.latestTransactionDate}'), */
                  ],
                ),
              ),
              PopupMenuButton<String>(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14.0))),
                onSelected: (String value) {
                  _disbandGroup(value, groupService, context);
                },
                itemBuilder: (BuildContext context) {
                  return {'Disband'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Center(child: Text(choice)),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _disbandGroup(String selectedValue, GroupService groupService,
      BuildContext context) async {
    try {
      if (selectedValue == 'Disband') {
        await groupService.disbandGroup(
            groupProfile.groupName, groupProfile.contractAddress);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group Disbanded Successfully')),
        );
      }
    } on RpcException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction failed: ${e.message}'),
      ));
    } on GeneralException catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An unexpected error occurred. Please try again.'),
      ));
    } catch (e) {
      if (!context.mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred.'),
      ));
    }
  }
}
