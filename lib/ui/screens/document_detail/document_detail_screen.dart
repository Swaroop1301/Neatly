import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/documents_provider.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final int docId;
  const DocumentDetailScreen({super.key, required this.docId});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _attemptedOpen = false;

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentByIdProvider(widget.docId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: docAsync.when(
          loading: () => const CircularProgressIndicator(color: Colors.white),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white)),
          data: (doc) {
            if (doc == null) {
              return const Text('Document not found', style: TextStyle(color: Colors.white));
            }
            if (!_attemptedOpen) {
              _attemptedOpen = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  final result = await OpenFile.open(doc.filePath);
                  if (result.type != ResultType.done && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open file: ${result.message}')),
                    );
                  }
                } finally {
                  if (mounted && context.canPop()) {
                    context.pop();
                  }
                }
              });
            }
            return const CircularProgressIndicator(color: Colors.white);
          },
        ),
      ),
    );
  }
}
