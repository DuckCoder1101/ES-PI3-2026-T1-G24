import 'package:flutter/material.dart';
import 'package:mescla_invest/models/startup.dart';
import 'package:mescla_invest/widgets/layout/header.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  List<StartupModel> _startups = [];
  bool _isLoading = true;

  // Estados de Filtro
  StartupStageFilter _selectedStage = StartupStageFilter.all;
  String _searchName = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserModel.getFullUserData();
      // Busca startups usando os filtros atuais
      final startups = await StartupModel.getStartups(
        offset: 0,
        limit: 10,
        stageFilter: _selectedStage,
        nameFilter: _searchName,
      );

      if (mounted) {
        setState(() {
          _user = user;
          _startups = startups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Função para atualizar apenas a lista quando o filtro mudar
  Future<void> _refreshList() async {
    setState(() => _isLoading = true);
    final data = await StartupModel.getStartups(
      offset: 0,
      limit: 10,
      stageFilter: _selectedStage,
      nameFilter: _searchName,
    );
    if (mounted) {
      setState(() {
        _startups = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(user: _user),
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
                          : ListView.builder(
                              itemCount: _startups.length,
                              itemBuilder: (context, index) {
                                final startup = _startups[index];
                                return GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    "/dashboard/startup-details",
                                    arguments: startup.id,
                                  ),
                                  child: _buildStartupCard(
                                    title: startup.name,
                                    description: startup.shortDescription,
                                    status: startup.stage.name,
                                    tokens: "${startup.totalTokens} tokens",
                                    imageUrl: startup.galleryPaths.isNotEmpty
                                        ? startup.galleryPaths[0]
                                        : null,
                                  ),
                                );
                              },
                            ),
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
          _refreshList();
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
                    _refreshList();
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
      'Em expansão': StartupStageFilter.em_espansao,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          bool isSelected = _selectedStage == entry.value;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedStage = entry.value);
              _refreshList();
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

  Widget _buildStartupCard({
    required String title,
    required String description,
    required String status,
    required String tokens,
    String? imageUrl,
  }) {
    return Container(
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
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: imageUrl == null
                  ? const LinearGradient(
                      colors: [Color(0xFF2D4F1E), Color(0xFF1E1E1E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Text(
                      'capa da startup',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadge(status.replaceAll('_', ' ')),
                    Text(
                      tokens,
                      style: const TextStyle(
                        color: Colors.white38,
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
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label.toLowerCase(),
        style: const TextStyle(
          color: AppColors.verdeMescla,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
