import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_admin_model.dart';
import '../providers/admin_users_provider.dart';

class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminUsersProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add_outlined),
        onPressed: () => _showDialog(context, ref, null),
      ),
      body: usersAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada user.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _UserCard(
                item: list[i],
                onEdit: () => _showDialog(ctx, ref, list[i]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(adminUsersProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    WidgetRef ref,
    UserAdminModel? user,
  ) async {
    final nipCtrl = TextEditingController(text: user?.nip ?? '');
    final namaCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final passwordCtrl = TextEditingController();
    String selectedRole = user?.role ?? 'user';
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(user == null ? 'Tambah User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'NIP *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: user == null
                        ? 'Password *'
                        : 'Password (kosongkan jika tidak diubah)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Role'),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['user', 'admin'].map((r) {
                    return ChoiceChip(
                      label: Text(r),
                      selected: selectedRole == r,
                      onSelected: (_) => setState(() => selectedRole = r),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    if (nipCtrl.text.trim().isEmpty ||
        namaCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty) {
      return;
    }
    if (user == null && passwordCtrl.text.trim().isEmpty) {
      return;
    }

    try {
      if (user == null) {
        await ref
            .read(adminUsersProvider.notifier)
            .store(
              nip: nipCtrl.text.trim(),
              name: namaCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              password: passwordCtrl.text.trim(),
              role: selectedRole,
            );
      } else {
        await ref
            .read(adminUsersProvider.notifier)
            .updateItem(
              id: user.id,
              nip: nipCtrl.text.trim(),
              name: namaCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              password: passwordCtrl.text.trim().isEmpty
                  ? null
                  : passwordCtrl.text.trim(),
              role: selectedRole,
            );
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserAdminModel item;
  final VoidCallback onEdit;
  const _UserCard({required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isAdmin
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Text(
            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: item.isAdmin
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'NIP: ${item.nip}\n${item.email}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.isAdmin
                    ? colorScheme.primary.withAlpha(30)
                    : Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.isAdmin ? colorScheme.primary : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
          ],
        ),
      ),
    );
  }
}
