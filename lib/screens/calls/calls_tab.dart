import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/call_provider.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        final calls = callProvider.calls;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: calls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_outlined, size: 80, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('No calls yet',
                          style: TextStyle(
                              fontSize: 20,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Your call history will appear here',
                          style: TextStyle(color: AppColors.textHint)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: calls.length,
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    final isMissed = call.status == Constants.callStatusMissed;
                    final displayName = call.direction == Constants.callDirectionIncoming
                        ? call.callerName
                        : call.receiverName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isMissed
                                ? AppColors.callRed.withOpacity(0.2)
                                : AppColors.callGreen.withOpacity(0.2),
                            child: Icon(
                              isMissed
                                  ? Icons.call_missed_rounded
                                  : call.direction == Constants.callDirectionOutgoing
                                      ? Icons.call_made_rounded
                                      : Icons.call_received_rounded,
                              color: isMissed ? AppColors.callRed : AppColors.callGreen,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isMissed ? FontWeight.w600 : FontWeight.w400,
                                        color: isMissed
                                            ? AppColors.callRed
                                            : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  isMissed
                                      ? 'Missed call'
                                      : call.direction == Constants.callDirectionOutgoing
                                          ? 'Outgoing call'
                                          : 'Incoming call',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.call_rounded, color: AppColors.callGreen),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'calls_fab',
            onPressed: () {
              Navigator.pushNamed(context, '/new-call');
            },
            backgroundColor: AppColors.callGreen,
            child: const Icon(Icons.phone_rounded, color: Colors.white),
          ),
        );
      },
    );
  }
}
