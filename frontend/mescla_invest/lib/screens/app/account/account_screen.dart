/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/user_model.dart';
import 'package:mescla_invest/screens/app/account/account_info_section.dart';
import 'package:mescla_invest/screens/app/account/avatar_section.dart';
import 'package:mescla_invest/screens/app/account/logout_section.dart';
import 'package:mescla_invest/screens/app/account/security_section.dart';
import 'package:mescla_invest/screens/app_root.dart';

class UserAccountScreen extends StatelessWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: authUserDataProvider,
      builder: (context, user, _) {
        return RefreshIndicator(
          onRefresh: () async {
            (context as Element).markNeedsBuild();
          },
          color: AppColors.verdeMescla,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.fundoEscuro,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: AvatarSection(user: user),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0.5),
                  child: Container(height: 0.5, color: Colors.white10),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const AccountSectionHeader(label: 'Dados Pessoais'),
                    const SizedBox(height: 14),

                    const AccountInfoSection(),
                    const SizedBox(height: 32),

                    const AccountSectionHeader(label: 'Segurança'),
                    const SizedBox(height: 14),

                    const SecuritySection(),
                    const SizedBox(height: 32),

                    const AccountSectionHeader(label: 'Conta'),
                    const SizedBox(height: 14),

                    const LogoutSection(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountSectionHeader extends StatelessWidget {
  final String label;
  const AccountSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
      ),
    );
  }
}
