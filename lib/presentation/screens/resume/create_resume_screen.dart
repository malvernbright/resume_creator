import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/resume_entity.dart';
import '../../../domain/entities/common_entities.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/resume/resume_bloc.dart';
import '../../bloc/resume/resume_event.dart';
import '../../bloc/resume/resume_state.dart';

class CreateResumeScreen extends StatefulWidget {
  final Resume? resume; // For editing existing resume

  const CreateResumeScreen({super.key, this.resume});

  @override
  State<CreateResumeScreen> createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends State<CreateResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers for basic info
  late final TextEditingController _titleController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _githubController;
  late final TextEditingController _summaryController;

  // Lists for complex fields
  List<Experience> _experiences = [];
  List<Education> _education = [];
  List<Skill> _skills = [];
  List<Achievement> _achievements = [];
  List<Project> _projects = [];
  List<Language> _languages = [];
  List<Reference> _references = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _titleController = TextEditingController(text: widget.resume?.title ?? '');
    _fullNameController = TextEditingController(
      text: widget.resume?.fullName ?? '',
    );
    _emailController = TextEditingController(text: widget.resume?.email ?? '');
    _phoneController = TextEditingController(text: widget.resume?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.resume?.address ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.resume?.website ?? '',
    );
    _linkedInController = TextEditingController(
      text: widget.resume?.linkedIn ?? '',
    );
    _githubController = TextEditingController(
      text: widget.resume?.github ?? '',
    );
    _summaryController = TextEditingController(
      text: widget.resume?.summary ?? '',
    );

    // Load existing data if editing
    if (widget.resume != null) {
      _experiences = List.from(widget.resume!.experiences);
      _education = List.from(widget.resume!.education);
      _skills = List.from(widget.resume!.skills);
      _achievements = List.from(widget.resume!.achievements);
      _projects = List.from(widget.resume!.projects);
      _languages = List.from(widget.resume!.languages);
      _references = List.from(widget.resume!.references);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _saveResume() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final resume = Resume(
        id: widget.resume?.id ?? _uuid.v4(),
        userId: authState.user.id,
        title: _titleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        linkedIn: _linkedInController.text.trim().isEmpty
            ? null
            : _linkedInController.text.trim(),
        github: _githubController.text.trim().isEmpty
            ? null
            : _githubController.text.trim(),
        summary: _summaryController.text.trim(),
        experiences: _experiences,
        education: _education,
        skills: _skills,
        achievements: _achievements,
        projects: _projects,
        languages: _languages,
        references: _references,
        createdAt: widget.resume?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.resume == null) {
        context.read<ResumeBloc>().add(CreateResume(resume));
      } else {
        context.read<ResumeBloc>().add(UpdateResume(resume));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResumeBloc, ResumeState>(
      listener: (context, state) {
        if (state is ResumeOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(context).pop();
        } else if (state is ResumeError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.resume == null ? 'Create Resume' : 'Edit Resume'),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveResume),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Resume Title *',
                  hintText: 'e.g., Software Engineer Resume',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkedInController,
                decoration: const InputDecoration(
                  labelText: 'LinkedIn',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(
                  labelText: 'GitHub',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Professional Summary *',
                  hintText: 'Brief overview of your professional background',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a summary';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Additional sections with add buttons
              _buildListSection(
                title: 'Experience',
                items: _experiences,
                emptyMessage: 'No work experience added yet',
                onAdd: () => _showAddExperienceDialog(),
              ),

              const SizedBox(height: 24),

              _buildListSection(
                title: 'Education',
                items: _education,
                emptyMessage: 'No education added yet',
                onAdd: () => _showAddEducationDialog(),
              ),

              const SizedBox(height: 24),

              _buildListSection(
                title: 'Skills',
                items: _skills,
                emptyMessage: 'No skills added yet',
                onAdd: () => _showAddSkillDialog(),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveResume,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.resume == null ? 'Create Resume' : 'Update Resume',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildListSection({
    required String title,
    required List items,
    required String emptyMessage,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(_getItemTitle(item)),
                subtitle: Text(_getItemSubtitle(item)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      if (item is Experience)
                        _experiences.removeAt(index);
                      else if (item is Education)
                        _education.removeAt(index);
                      else if (item is Skill)
                        _skills.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  String _getItemTitle(dynamic item) {
    if (item is Experience) return item.position;
    if (item is Education) return item.degree;
    if (item is Skill) return item.name;
    return '';
  }

  String _getItemSubtitle(dynamic item) {
    if (item is Experience) return item.company;
    if (item is Education) return item.institution;
    if (item is Skill) return item.level;
    return '';
  }

  void _showAddExperienceDialog() {
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool isCurrent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Current Position'),
                  value: isCurrent,
                  onChanged: (value) {
                    setDialogState(() {
                      isCurrent = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (positionController.text.isNotEmpty &&
                    companyController.text.isNotEmpty) {
                  setState(() {
                    _experiences.add(
                      Experience(
                        id: _uuid.v4(),
                        position: positionController.text,
                        company: companyController.text,
                        startDate: startDate ?? DateTime.now(),
                        endDate: isCurrent ? null : (endDate ?? DateTime.now()),
                        description: descriptionController.text,
                        isCurrent: isCurrent,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEducationDialog() {
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
    final fieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: institutionController,
              decoration: const InputDecoration(labelText: 'Institution'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fieldController,
              decoration: const InputDecoration(labelText: 'Field of Study'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (degreeController.text.isNotEmpty &&
                  institutionController.text.isNotEmpty) {
                setState(() {
                  _education.add(
                    Education(
                      id: _uuid.v4(),
                      degree: degreeController.text,
                      institution: institutionController.text,
                      fieldOfStudy: fieldController.text,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog() {
    final nameController = TextEditingController();
    String level = 'Intermediate';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Skill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Skill Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    level = value ?? 'Intermediate';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _skills.add(
                      Skill(
                        id: _uuid.v4(),
                        name: nameController.text,
                        level: level,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
