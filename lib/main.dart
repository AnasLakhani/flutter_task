import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(LinkAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _urlController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  List<Link> _links = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final box = await Hive.openBox<Link>('links');
    // box.clear();
    setState(() {
      _links = box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Link Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Empty Tab'),
            Tab(text: 'Links Tab'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(
            child: Text('Empty Tab Content'),
          ),
          _buildLinksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _urlController.text = '';
          _titleController.text = '';
          _showLinkBottomSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLinksTab() {
    return ListView.builder(
      itemCount: _links.length,
      itemBuilder: (context, index) {
        final link = _links[index];
        return ListTile(
          leading: Icon(getDomainIcon(link.url)),
          subtitle: Text(link.title.isEmpty ? link.url : link.title),
          title: Text(link.url),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editLink(link);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _deleteLink(index, link);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLinkBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16),
          // padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'Custom Title (Optional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveLink();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveLink() async {
    final url = _urlController.text.trim();
    final title = _titleController.text.trim();

    // Check if the number of links is less than 3
    if (_links.length >= 3) {
      Fluttertoast.showToast(msg: 'You can only add up to 3 links.');

      return;
    }

    // Check if the URL length exceeds 25 characters
    if (url.length > 25) {
      Fluttertoast.showToast(msg: 'URL cannot exceed 25 characters.');

      return;
    }

    if (_isValidUrl(url)) {
      final box = await Hive.openBox<Link>('links');
      final link =
          Link(url: url, title: title.isNotEmpty ? title : _extractDomain(url));
      box.add(link);
      setState(() {
        _links.add(link);
        _urlController.clear();
        _titleController.clear();
      });
      Navigator.pop(context); // Close the bottom sheet
    } else {
      Fluttertoast.showToast(msg: 'Invalid URL');
    }
  }

  String _extractDomain(String url) {
    return Uri.parse(url).host;
  }

  void _editLink(Link link) {
    _urlController.text = link.url;
    _titleController.text = link.title;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          // padding: const EdgeInsets.all(16),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'Custom Title (Optional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateLink(link);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateLink(Link link) async {
    final url = _urlController.text.trim();
    final title = _titleController.text.trim();

    // Check if the URL length exceeds 25 characters
    if (url.length > 25) {
      Fluttertoast.showToast(msg: 'URL cannot exceed 25 characters.');
      return;
    }

    if (_isValidUrl(url)) {
      link.url = url;
      link.title = title.isNotEmpty ? title : _extractDomain(url);
      await link.save(); // Save the updated link
      setState(() {
        _urlController.clear();
        _titleController.clear();
      });
      Navigator.pop(context); // Close the bottom sheet
    } else {
      Fluttertoast.showToast(msg: 'Invalid URL');
    }
  }

  // Define a map to map domains to their corresponding icons
  Map<String, IconData> domainIconMap = {
    'instagram': Icons.camera,
    'facebook': Icons.facebook,
    'tiktok': Icons.tiktok,
  };

// Function to get the domain icon based on the URL
  IconData getDomainIcon(String url) {
    // Extract the domain from the URL
    // String domain = Uri.parse(url).host;
    // url = 'facebook';
    // Check if the domain exists in the map

    String domain;

    if (url.contains(":")) {
      domain = Uri.parse(url)
          .host
          .replaceAll('www.', '')
          .split('.')
          .first
          .toLowerCase();
    } else {
      domain = (url).replaceAll('www.', '').split('.').first.toLowerCase();
    }
    print(url);

    print(domain);
    if (domainIconMap.containsKey(domain)) {
      // Return the corresponding icon
      return domainIconMap[domain]!;
    } else {
      // Return a default icon for other domains
      return Icons.public;
    }
  }

  bool _isValidUrl(String url) {
    // Regular expression for URL validation
    // This is a basic example, you may need to adjust it as needed
    final RegExp urlRegex = RegExp(
      r"^(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+",
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.hasMatch(url);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _deleteLink(int index, Link link) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this link?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final box = await Hive.openBox<Link>('links');

                await box.deleteAt(index);
                setState(() {
                  _links.removeAt(index);
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Delete Successfully'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        box.add(link);
                        setState(() {
                          _links.add(link);
                          _urlController.clear();
                          _titleController.clear();
                        });
                      },
                    )));
                Navigator.of(context).pop(true);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class Link extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  String title;

  Link({required this.url, required this.title});
}

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 0;

  @override
  Link read(BinaryReader reader) {
    return Link(
      url: reader.readString(),
      title: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer.writeString(obj.url);
    writer.writeString(obj.title);
  }
}
