import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/core/widgets/user_avatar.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mudar Senha'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nova senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setDialogState(
                        () => obscureConfirm = !obscureConfirm,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v != newPasswordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref
                      .read(authProvider.notifier)
                      .changePassword(newPasswordController.text);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Senha alterada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Erro ao mudar senha: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );

    newPasswordController.dispose();
    confirmController.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .updateUserProfile(_nameController.text, _emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Usuário')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              name: user.name,
              photoUrl: user.photoUrl,
              radius: 60,
            ),
            const SizedBox(height: 16),
            Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(user.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Por favor, insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Salvar Alterações'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Mudar Senha'),
                    onPressed: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
