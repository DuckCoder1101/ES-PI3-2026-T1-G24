/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636 
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/widgets/layout/header.dart';
import 'package:mescla_invest/constants/colors.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<StartupModel> _startups = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 10;

  StartupStageFilter _selectedStage = StartupStageFilter.all;
  String _searchName = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchStartups(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        !_isLoading &&
        _hasMore) {
      _fetchStartups();
    }
  }

  Future<void> _fetchStartups({bool reset = false}) async {
    if (reset) {
      setState(() {
        _offset = 0;
        _hasMore = true;
        _startups = [];
        _isLoading = true;
      });
    } else {
      if (_isMoreLoading) return;
      setState(() => _isMoreLoading = true);
    }

    try {
      final newStartups = await StartupService.getStartupsList(
        offset: _offset,
        limit: _limit,
        stageFilter: _selectedStage,
        nameFilter: _searchName,
      );

      if (mounted) {
        setState(() {
          _startups.addAll(newStartups);
          _offset = _startups.length;

          if (newStartups.length < _limit) {
            _hasMore = false;
          }
        });
      }
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fundoEscuro,
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildFilterTags(),
                    const SizedBox(height: 24),
                    Text(
                      '${_startups.length} STARTUPS ENCONTRADAS',
                      style: const TextStyle(
                        color: AppColors.verdeMescla,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.verdeMescla,
                              ),
                            )
                          : _buildListView(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () => _fetchStartups(reset: true),
      color: AppColors.verdeMescla,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _startups.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _startups.length) {
            return _buildStartupCard(_startups[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.verdeMescla),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (value) {
          setState(() => _searchName = value);
          _fetchStartups(reset: true);
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.white38, size: 20),
          hintText: 'Buscar startups...',
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          suffixIcon: _searchName.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchName = "");
                    _fetchStartups(reset: true);
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterTags() {
    final Map<String, StartupStageFilter> filters = {
      'Todas': StartupStageFilter.all,
      'Nova': StartupStageFilter.nova,
      'Em Operação': StartupStageFilter.em_operacao,
      'Em expansão': StartupStageFilter.em_expansao,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          bool isSelected = _selectedStage == entry.value;
          return GestureDetector(
            onTap: () {
              if (_selectedStage != entry.value) {
                setState(() => _selectedStage = entry.value);
                _fetchStartups(reset: true);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla
                    : AppColors.campoEscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStartupCard(StartupModel startup) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        "/startups/startup-details",
        arguments: startup.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                image: startup.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(startup.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D4F1E), Color(0xFF1E1E1E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    startup.shortDescription,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startup.stage.label,
                        style: const TextStyle(
                          color: AppColors.verdeMescla,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.token,
                            size: 15,
                            color: AppColors.verdeMescla,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            formatCurrency(startup.tokenPrice),
                            style: const TextStyle(
                              color: AppColors.verdeMescla,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tokens disponíveis: ${startup.totalTokensAvailable}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),

                      if (startup.isInvestor)
                        Text(
                          "INVESTIDOR",
                          style: TextStyle(
                            color: AppColors.verdeMescla,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
