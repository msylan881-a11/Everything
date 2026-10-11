import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(const NaqshApp());

class NaqshApp extends StatelessWidget {
  const NaqshApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      title: 'NAQSH AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF8F7FB),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF8F7FB)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE4DFED)),
          ),
        ),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: EditorPage()),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _picker = ImagePicker();
  final _prompt = TextEditingController();
  final _apiBase = const String.fromEnvironment(
    'NAQSH_API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );
  XFile? _image;
  bool _busy = false;
  String? _message;

  Future<void> _pick(ImageSource source) async {
    try {
      final selected = await _picker.pickImage(source: source, imageQuality: 95);
      if (selected != null && mounted) {
        setState(() { _image = selected; _message = null; });
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'تعذر فتح الصور أو الكاميرا. تحقق من الأذونات.');
    }
  }

  Future<void> _submit() async {
    if (_image == null) {
      setState(() => _message = 'اختر صورة أولًا.');
      return;
    }
    if (_prompt.text.trim().length < 3) {
      setState(() => _message = 'اكتب وصفًا واضحًا للتعديل المطلوب.');
      return;
    }
    setState(() { _busy = true; _message = null; });
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_apiBase/v1/edits'));
      request.fields['prompt'] = _prompt.text.trim();
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final body = await streamed.stream.bytesToString();
      dynamic decoded;
      try { decoded = jsonDecode(body); } catch (_) { decoded = null; }
      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        setState(() => _message = 'وصل رد الخادم.');
      } else {
        final detail = decoded is Map ? decoded['detail'] : null;
        setState(() => _message = detail?.toString() ?? 'تعذر تنفيذ الطلب (${streamed.statusCode}).');
      }
    } catch (_) {
      setState(() => _message = 'تعذر الاتصال بالخادم. تأكد من تشغيله وصحة عنوان API.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _prompt.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAQSH AI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .3)),
        actions: [
          IconButton(
            tooltip: 'السجل',
            onPressed: () => _info('سجل التصاميم', 'سيُفعّل السجل بعد إعداد الحسابات وقاعدة البيانات.'),
            icon: const Icon(Icons.history_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF49347F), Color(0xFF8E75CB)],
                  begin: Alignment.topRight, end: Alignment.bottomLeft,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                  SizedBox(height: 12),
                  Text('خلّي فكرتك تصميمًا', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('ارفع صورتك واكتب التعديل الذي تريده بالعربية.', style: TextStyle(color: Colors.white, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('١. اختر الصورة'),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _busy ? null : () => _pick(ImageSource.gallery),
              child: Container(
                height: 235,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDCD5EB)),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 54, color: Color(0xFF6750A4)),
                          SizedBox(height: 12),
                          Text('اضغط لاختيار صورة', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text('JPG أو PNG أو WebP', style: TextStyle(color: Colors.black54)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Image.file(File(_image!.path), fit: BoxFit.contain),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined), label: const Text('المعرض'),
              )),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined), label: const Text('الكاميرا'),
              )),
            ]),
            const SizedBox(height: 24),
            const _SectionTitle('٢. ماذا تريد أن نعدّل؟'),
            const SizedBox(height: 10),
            TextField(
              controller: _prompt,
              minLines: 4, maxLines: 7,
              decoration: const InputDecoration(
                hintText: 'مثال: وضّح الصورة، حسّن الإضاءة، غيّر الخلفية إلى خلفية احترافية، وحافظ على الشعار والنص.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('تحسين الجودة', 'حسّن وضوح الصورة وجودتها مع الحفاظ على التفاصيل الأصلية.'),
              _chip('تغيير الخلفية', 'غيّر الخلفية إلى خلفية احترافية مناسبة، مع الحفاظ على العنصر الأساسي.'),
              _chip('مقاس مربع', 'اجعل أبعاد الصورة مربعة مع الحفاظ على المحتوى المهم.'),
              _chip('تحسين الإضاءة', 'حسّن الإضاءة والألوان بشكل طبيعي دون تغيير النص أو الشعار.'),
            ]),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_busy ? 'جارٍ إرسال الطلب...' : 'إنشاء التصميم', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(15)),
                child: Text(_message!),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'يجب ربط مزوّد ذكاء اصطناعي حقيقي بالخادم قبل تفعيل تحرير الصور.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String prompt) => ActionChip(
    label: Text(label),
    onPressed: _busy ? null : () => setState(() => _prompt.text = prompt),
  );

  void _info(String title, String body) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: Text(title), content: Text(body),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))],
    ));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
}
