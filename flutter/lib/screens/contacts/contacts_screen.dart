import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact.dart';
import '../../state/contacts_controller.dart';
import '../../state/messages_controller.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive.dart';
import 'widgets/contact_card.dart';

/// The Contacts screen, laid out as the Week 3 prototype draws it: one list,
/// primary contact first, each row opening a written conversation.
///
/// There is no call button anywhere on this screen. A voice call is the one
/// channel a deaf or hard-of-hearing user cannot rely on, so every row leads to
/// text, and the banner at the top points at the Notify action that replaces
/// "give me a ring" with a silent flash on the other person's phone.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Loading is kicked off after the first frame so the controllers are not
    // asked to notify listeners while the widget tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final ContactsController contacts = context.read<ContactsController>();
    await contacts.load();
    if (!mounted) return;
    await context
        .read<MessagesController>()
        .loadThreads(contacts.allContacts.map((Contact c) => c.id));
  }

  void _openThread(Contact contact) {
    context.pushNamed(
      Routes.messageThreadName,
      pathParameters: <String, String>{'contactId': contact.id},
    );
  }

  /// The body under the tip banner: spinner, error, empty state or the list.
  ///
  /// These are mutually exclusive on purpose. An earlier version showed the
  /// failure banner *and* "No contacts yet" together, which told the user two
  /// contradictory things — that something went wrong, and that they simply
  /// have no contacts.
  Widget _buildList(
    ContactsController contacts,
    MessagesController messages,
    bool isTablet,
  ) {
    if (contacts.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (contacts.error != null) {
      return AlertBanner(
        tone: AlertTone.error,
        title: 'Contacts could not be loaded',
        message: 'Your contacts are saved on this phone, so nothing has been '
            'lost. Try again in a moment.',
        action: FilledButton.icon(
          onPressed: _bootstrap,
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Try again'),
        ),
      );
    }

    final List<Contact> visible = contacts.allContacts;
    if (visible.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No contacts yet',
        message: 'Your care team will appear here once someone is added to '
            'your circle.',
      );
    }

    // On a phone the rows stack; from the tablet breakpoint up they sit two
    // across, which keeps a card from stretching the full width of a wide
    // screen.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 12;
        final double cardWidth = isTablet
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: visible
              .map(
                (Contact contact) => SizedBox(
                  width: cardWidth,
                  child: ContactCard(
                    contact: contact,
                    preview: messages.previewFor(contact.id),
                    unreadCount: messages.unreadCount(contact.id),
                    onOpenThread: () => _openThread(contact),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ContactsController contacts = context.watch<ContactsController>();
    final MessagesController messages = context.watch<MessagesController>();
    final bool isTablet = Breakpoints.isTablet(context);

    return AppScaffold(
      title: 'Contacts',
      subtitle: 'People who care for you',
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ReadableWidth(
          maxWidth: 900,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.gutter),
            children: <Widget>[
              const _NotifyTip(),
              const SizedBox(height: 16),
              _buildList(contacts, messages, isTablet),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tip banner from the top of the prototype's Contacts screen.
class _NotifyTip extends StatelessWidget {
  const _NotifyTip();

  @override
  Widget build(BuildContext context) {
    return const AlertBanner(
      tone: AlertTone.info,
      icon: Icons.vibration,
      title: 'Getting someone\'s attention',
      message: 'Open a chat and tap Notify to send a silent visual flash and '
          'vibration. No sound needed.',
    );
  }
}
