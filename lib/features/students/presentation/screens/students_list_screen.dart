import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';

import '../providers/students_provider.dart';

class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Scaffold(
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Meus Alunos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar aluno...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(searchStudentsProvider.notifier).updateQuery(value);
              },
            ),
          ),
        ),
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum aluno encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(student.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/student-detail/${student.uid}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(studentsListProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/register-student');
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Cadastrar Aluno'),
      ),
    );
  }
}
