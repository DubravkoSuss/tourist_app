import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sights/sights_bloc.dart';
import '../../widgets/sight_card.dart';
import 'sight_details_screen.dart';
import '../../widgets/loading_widget.dart';
import '../../../domain/repositories/sights_repository.dart';
import '../../../injection_container.dart'; // Import to access repository

class SightsTab extends StatefulWidget {
  const SightsTab({super.key});

  @override
  State<SightsTab> createState() => _SightsTabState();
}

class _SightsTabState extends State<SightsTab> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    context.read<SightsBloc>().add(LoadSightsEvent());
  }

  // Upload function
  Future<void> _uploadDataToFirebase() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Get repository from dependency injection
      final repository = sl<SightsRepository>();



      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Successfully uploaded 9 Zagreb sights to Firebase!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Reload sights from Firebase
        context.read<SightsBloc>().add(LoadSightsEvent());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Sights'),
        centerTitle: true,
        actions: [
          // TEMPORARY UPLOAD BUTTON - Remove after uploading once
          IconButton(
            icon: _isUploading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.upload),
            onPressed: _isUploading ? null : _uploadDataToFirebase,
            tooltip: 'Upload to Firebase',
          ),
        ],
      ),
      body: BlocBuilder<SightsBloc, SightsState>(
        builder: (context, state) {
          if (state is SightsLoading) {
            return const LoadingWidget(
              message: 'Loading sights...',
            );
          }

          if (state is SightsInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          else if (state is SightsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          else if (state is SightsError) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/error_image.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error_outline,
                            size: 100,
                            color: Colors.red[300],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Oops! Something Went Wrong',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<SightsBloc>().add(LoadSightsEvent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          else if (state is SightsEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/empty_sights.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.explore_off,
                            size: 100,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Sights to Explore',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Check back later for new places to discover!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<SightsBloc>().add(LoadSightsEvent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          else if (state is SightsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SightsBloc>().add(LoadSightsEvent());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.sights.length,
                itemBuilder: (context, index) {
                  final sight = state.sights[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Hero(
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
                    ),
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }
}