import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Your bookmark model – adjust fields as needed.
class Link {
  final String title;
  final String url;
  final String? description;
  final String? faviconUrl;

  Link({
    required this.title,
    required this.url,
    this.description,
    this.faviconUrl,
  });
}

/// A ListTile-based widget for displaying a single Link/bookmark.
class LinkTile extends StatelessWidget {
  final Link link;
  const LinkTile({required this.link, Key? key}) : super(key: key);

  /// Opens the link in the external browser.
  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(link.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch ${link.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: link.faviconUrl != null
            ? ClipOval(
                child: Image.network(link.faviconUrl!,
                    width: 32, height: 32, fit: BoxFit.cover),
              )
            : const Icon(Icons.link, size: 32),
        title: Text(link.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(link.url, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _launchUrl(context),
        ),
        onTap: () => _launchUrl(context),
      ),
    );
  }
}
