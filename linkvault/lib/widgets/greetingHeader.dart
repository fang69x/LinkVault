import 'package:flutter/material.dart';
import 'package:linkvault/models/user_model.dart';
import 'package:linkvault/utils/theme.dart';

class GreetingHeader extends StatefulWidget {
  final User? user;
  final int linkCount;

  const GreetingHeader({this.user, required this.linkCount, super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, -0.1), end: Offset.zero).animate(_ctrl);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 16),
      sliver: SliverToBoxAdapter(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Card.filled(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: Hero(
                  tag: 'user_avatar',
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.accentColor,
                    backgroundImage: widget.user?.avatarUrl != null
                        ? NetworkImage(widget.user!.avatarUrl!)
                        : null,
                    child: widget.user?.avatarUrl == null
                        ? Text(widget.user?.name?[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                        : null,
                  ),
                ),
                title: Text('Welcome back,',
                    style: Theme.of(context).textTheme.bodySmall),
                subtitle: Text(widget.user?.name ?? 'User',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                trailing: Semantics(
                  label: '${widget.linkCount} saved links',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark,
                            size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 4),
                        Text('${widget.linkCount} links',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                    )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
