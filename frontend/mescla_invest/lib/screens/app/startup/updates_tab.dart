/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/startup/startup_news_model.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

class TabUpdates extends StatefulWidget {
  final String startupId;

  const TabUpdates({super.key, required this.startupId});

  @override
  State<TabUpdates> createState() => _TabUpdatesState();
}

class _TabUpdatesState extends State<TabUpdates> {
  List<StartupNewsModel> _news = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    try {
      final data = await StartupService.getStartupNews(
        startupId: widget.startupId,
      );
      if (mounted) setState(() => _news = data);
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.verdeMescla),
        ),
      );
    }

    if (_news.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nenhuma atualização publicada.',
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    return Column(
      children: _news.map(_buildNewsCard).toList(),
    );
  }

  Widget _buildNewsCard(StartupNewsModel news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.verdeMescla.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.newspaper_rounded,
                  color: AppColors.verdeMescla,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  news.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            news.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (news.createdAt != null) ...[
            const SizedBox(height: 10),
            Text(
              formatDate(news.createdAt),
              style: const TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
