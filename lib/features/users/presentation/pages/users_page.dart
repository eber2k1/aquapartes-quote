import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/system_user.dart';
import '../../domain/repositories/users_repository.dart';
import '../../users_module.dart';
import 'user_form_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UsersRepository _repository = getUsersRepository();

  List<SystemUser>? _users;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _repository.loadUsers();
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm([SystemUser? user]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UserFormPage(initialUser: user)),
    );

    if (changed == true && mounted) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppEmptyState(message: _errorMessage!),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _loadUsers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_users == null || _users!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppEmptyState(
              message: 'Aun no hay usuarios registrados en el sistema.',
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => _openForm(),
              child: const Text('Crear Usuario'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 80,
        ),
        itemCount: _users!.length,
        itemBuilder: (context, index) {
          final user = _users![index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            child: InkWell(
              onTap: () => _openForm(user),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: user.isActive
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: user.isActive
                                      ? null
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.role == 'admin'
                                ? Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer
                                : user.role == 'manager'
                                ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer.withAlpha(128),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: user.role == 'admin'
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer
                                      : user.role == 'manager'
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (!user.isActive) ...[
                          const SizedBox(height: 8),
                          Text(
                            'INACTIVO',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
