import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../widgets/sight_card.dart';
import 'sight_details_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is FavoritesEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image when no favorites
                  Image.asset(
                    'assets/images/nofavorites.png',
                    width: 400,
                    height: 400,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image not found
                      return Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Favorites Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Start exploring and save your favorite sights',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FavoritesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final sight = state.favorites[index];
                return Hero(
                  tag: 'sight-${sight.id}',
                  child: Material(
                    child: SightCard(
                      sight: sight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SightDetailsScreen(sight: sight),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}