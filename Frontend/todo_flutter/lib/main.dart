import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
    fileName: 'assets/dev.env',
  ); // plik z BASE_URL / FUNCTIONS_KEY
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskVM()..refresh(),
      child: const TodoApp(),
    ),
  );
}

/* ──────────────────────────────────────────────────────────────────── */
/*                            APP ROOT                                 */
/* ──────────────────────────────────────────────────────────────────── */

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure TODO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const TodoPage(),
    );
  }
}

/* ──────────────────────────────────────────────────────────────────── */
/*                       VIEW-MODEL / PROVIDER                         */
/* ──────────────────────────────────────────────────────────────────── */

class TaskVM extends ChangeNotifier {
  final _api = TaskService();

  final List<Task> tasks = [];
  bool loading = false;

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    tasks
      ..clear()
      ..addAll(await _api.getAll());
    loading = false;
    notifyListeners();
  }

  Future<void> add(String text) async {
    await _api.add(text);
    await refresh();
  }

  Future<void> remove(Task t) async {
    await _api.delete(t.id);
    await refresh();
  }
}

/* ──────────────────────────────────────────────────────────────────── */
/*                               UI                                    */
/* ──────────────────────────────────────────────────────────────────── */

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskVM>();

    return Scaffold(
      appBar: AppBar(title: const Text('Azure TODO')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // ——— input row ———
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Nowe zadanie…',
                      filled: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _add(vm),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj'),
                  onPressed: () => _add(vm),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vm.loading) const LinearProgressIndicator(),

            // ——— list ———
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80, top: 4),
                  itemCount: vm.tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final t = vm.tasks[i];
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: Colors.red.shade400,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => vm.remove(t),
                      child: Card(
                        elevation: 0,
                        child: CheckboxListTile(
                          value: false,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(t.text),
                          onChanged: (_) => vm.remove(t),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _add(TaskVM vm) async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    await vm.add(txt);
    _ctrl.clear();
  }
}
