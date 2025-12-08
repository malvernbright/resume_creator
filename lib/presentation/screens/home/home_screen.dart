import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/resume/resume_bloc.dart';
import '../../bloc/resume/resume_event.dart';
import '../../bloc/resume/resume_state.dart';
import '../resume/resume_list_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  void _loadResumes() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ResumeBloc>().add(LoadResumes(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Creator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ResumeBloc, ResumeState>(
        builder: (context, state) {
          if (state is ResumeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ResumesLoaded) {
            if (state.resumes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.description,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No resumes yet',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Create your first resume to get started'),
                  ],
                ),
              );
            }
            return ResumeListScreen(resumes: state.resumes);
          } else if (state is ResumeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Welcome! Start creating resumes.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create resume screen
          // Will be implemented with the full UI
        },
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
      ),
    );
  }
}
