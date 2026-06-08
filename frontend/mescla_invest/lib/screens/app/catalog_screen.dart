/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636 
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
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
  final int _limit = 10;
  int _offset = 0;
  int _fetchToken = 0;

  Timer? _debounce;

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
    _debounce?.cancel();
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
    final token = ++_fetchToken; // incrementa a cada chamada

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

      // Se um fetch mais novo já foi iniciado, descarta este resultado
      if (token != _fetchToken) return;

      if (mounted) {
        setState(() {
          _startups.addAll(newStartups);
          _offset = _startups.length;
          if (newStartups.length < _limit) _hasMore = false;
        });
      }
    } catch (err, stack) {
      if (token != _fetchToken) return;
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted && token == _fetchToken) {
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterTags(),
                    const SizedBox(height: 16),
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _startups.isEmpty && !_hasMore
            ? 1
            : _startups.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (_startups.isEmpty && !_hasMore) {
            return const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(
                child: Text(
                  'Nenhuma startup encontrada.',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            );
          }
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
        onChanged: (value) {
          setState(() => _searchName = value);
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            _fetchStartups(reset: true);
          });
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StartupStageFilter.values.map((stage) {
          bool isSelected = _selectedStage == stage;
          return GestureDetector(
            onTap: () {
              if (_selectedStage != stage) {
                setState(() => _selectedStage = stage);
                _fetchStartups(reset: true);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla
                    : AppColors.campoEscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stage.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
