import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/modules/account/account_detail/cubit/account_detail_cubit.dart';
import 'package:movie_app/modules/account/account_detail/cubit/account_state.dart';

class AccountDetailScreen extends StatelessWidget {
  final int accountId;
  final String? sessionId;
  const AccountDetailScreen({
    super.key,
    required this.accountId,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailCubit, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AccountError) {
          return Center(child: Text(state.message));
        }
        if (state is AccountLoaded) {
          final accountDetail = state.account;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (accountDetail.avatar?.tmdb?.avatarPath != null)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://image.tmdb.org/t/p/w200${accountDetail.avatar!.tmdb!.avatarPath}',
                      ),
                    ),
                  ),
                _buildInfoRow('ID', accountDetail.id.toString()),
                _buildInfoRow('Username', accountDetail.username),
                _buildInfoRow('Name', accountDetail.name),
                _buildInfoRow('Language', accountDetail.iso_639_1),
                _buildInfoRow('Country', accountDetail.iso_3166_1),
                _buildInfoRow(
                  'Include Adult',
                  accountDetail.includeAdult ? 'Yes' : 'No',
                ),
              ],
            ),
          );
        }
        return Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<AccountDetailCubit>().getAccountDetail(
                accountId: accountId,
                seasionId: sessionId,
              );
            },
            child: const Text('Load Account Details'),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
