import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/l10n/l10n.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/security/notifications/actions.dart';
import 'package:katya/store/security/notifications/model.dart';
import 'package:katya/views/widgets/button.dart';
import 'package:katya/views/widgets/loading_indicator.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationSettingsViewModel>(
      distinct: true,
      converter: (store) => NotificationSettingsViewModel.fromStore(store),
      builder: (context, viewModel) => _View(viewModel: viewModel),
    );
  }
}

class _View extends StatefulWidget {
  final NotificationSettingsViewModel viewModel;

  const _View({required this.viewModel});

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late bool _enabled;
  late bool _showBanners;
  late bool _playSound;
  late bool _vibrate;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didUpdateWidget(_View oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel.settings != oldWidget.viewModel.settings) {
      _loadSettings();
    }
  }

  void _loadSettings() {
    final settings = widget.viewModel.settings;
    setState(() {
      _enabled = settings.enabled;
      _showBanners = settings.showInAppBanners;
      _playSound = settings.playSound;
      _vibrate = settings.vibrate;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.viewModel.addEmail(_emailController.text.trim());
      _emailController.clear();
      // Clear focus and close keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      // Error is handled by the middleware
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notification_settings_title),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global Toggle
                  Card(
                    elevation: 2,
                    child: SwitchListTile(
                      title: Text(
                        l10n.enable_security_notifications,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        l10n.enable_security_notifications_description,
                        style: theme.textTheme.bodySmall,
                      ),
                      value: _enabled,
                      onChanged: (value) {
                        setState(() => _enabled = value);
                        widget.viewModel.toggleNotifications(value);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_enabled) ...[
                    // Notification Preferences
                    _buildSection(
                      context,
                      title: l10n.notification_preferences,
                      children: [
                        _buildPreferenceTile(
                          context,
                          title: l10n.failed_login_attempts,
                          value: widget.viewModel.settings.failedLoginAttempts,
                          onChanged: (value) => widget.viewModel.updatePreference(
                            'failedLoginAttempts',
                            value,
                          ),
                        ),
                        _buildDivider(),
                        _buildPreferenceTile(
                          context,
                          title: l10n.new_device_login,
                          value: widget.viewModel.settings.newDeviceLogin,
                          onChanged: (value) => widget.viewModel.updatePreference(
                            'newDeviceLogin',
                            value,
                          ),
                        ),
                        _buildDivider(),
                        _buildPreferenceTile(
                          context,
                          title: l10n.password_changes,
                          value: widget.viewModel.settings.passwordChange,
                          onChanged: (value) => widget.viewModel.updatePreference(
                            'passwordChange',
                            value,
                          ),
                        ),
                        _buildDivider(),
                        _buildPreferenceTile(
                          context,
                          title: l10n.two_factor_changes,
                          value: widget.viewModel.settings.twoFactorDisabled,
                          onChanged: (value) => widget.viewModel.updatePreference(
                            'twoFactorDisabled',
                            value,
                          ),
                        ),
                        _buildDivider(),
                        _buildPreferenceTile(
                          context,
                          title: l10n.suspicious_activity,
                          value: widget.viewModel.settings.suspiciousActivity,
                          onChanged: (value) => widget.viewModel.updatePreference(
                            'suspiciousActivity',
                            value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notification Settings
                    _buildSection(
                      context,
                      title: l10n.notification_settings,
                      children: [
                        SwitchListTile(
                          title: Text(l10n.show_in_app_banners),
                          subtitle: Text(l10n.show_in_app_banners_description),
                          value: _showBanners,
                          onChanged: (value) {
                            setState(() => _showBanners = value);
                            widget.viewModel.setInAppBannersEnabled(value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        _buildDivider(),
                        SwitchListTile(
                          title: Text(l10n.play_sound),
                          subtitle: Text(l10n.play_sound_description),
                          value: _playSound,
                          onChanged: (value) {
                            setState(() => _playSound = value);
                            widget.viewModel.setNotificationSoundEnabled(value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        _buildDivider(),
                        SwitchListTile(
                          title: Text(l10n.vibrate),
                          subtitle: Text(l10n.vibrate_description),
                          value: _vibrate,
                          onChanged: (value) {
                            setState(() => _vibrate = value);
                            widget.viewModel.setNotificationVibrationEnabled(value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email Notifications
                    _buildSection(
                      context,
                      title: l10n.email_notifications,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: l10n.add_email_address,
                                      hintText: 'you@example.com',
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.please_enter_an_email_address;
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                        return l10n.please_enter_a_valid_email_address;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: _addEmail,
                                  tooltip: l10n.add_email,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.viewModel.settings.emailAddresses.isNotEmpty) ...[
                          const Divider(height: 1),
                          ...widget.viewModel.settings.emailAddresses.map((email) {
                            return ListTile(
                              title: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => widget.viewModel.removeEmail(email),
                                tooltip: l10n.remove_email,
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // View Security Logs
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(l10n.view_security_logs),
                        leading: const Icon(Icons.history),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: widget.viewModel.viewSecurityLogs,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }

  Widget _buildPreferenceTile(
    BuildContext context, {
    required String title,
    required NotificationPreference value,
    required Function(NotificationPreference) onChanged,
  }) {
    final l10n = l10nOf(context);

    return ListTile(
      title: Text(title),
      subtitle: Text(_getPreferenceDescription(value, l10n)),
      trailing: PopupMenuButton<NotificationPreference>(
        onSelected: onChanged,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: NotificationPreference.none,
            child: Text(l10n.none),
          ),
          PopupMenuItem(
            value: NotificationPreference.push,
            child: Text(l10n.push_notifications_only),
          ),
          PopupMenuItem(
            value: NotificationPreference.email,
            child: Text(l10n.email_only),
          ),
          PopupMenuItem(
            value: NotificationPreference.all,
            child: Text(l10n.push_and_email),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPreferenceShortDescription(value, l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _getPreferenceDescription(
    NotificationPreference preference,
    AppLocalizations l10n,
  ) {
    switch (preference) {
      case NotificationPreference.none:
        return l10n.no_notifications;
      case NotificationPreference.push:
        return l10n.push_notifications_only;
      case NotificationPreference.email:
        return l10n.email_only;
      case NotificationPreference.all:
        return l10n.push_and_email;
    }
  }

  String _getPreferenceShortDescription(
    NotificationPreference preference,
    AppLocalizations l10n,
  ) {
    switch (preference) {
      case NotificationPreference.none:
        return l10n.none;
      case NotificationPreference.push:
        return l10n.push;
      case NotificationPreference.email:
        return l10n.email;
      case NotificationPreference.all:
        return l10n.both;
    }
  }
}

class NotificationSettingsViewModel {
  final SecurityNotificationSettings settings;
  final Function() toggleNotifications;
  final Function(String, NotificationPreference) updatePreference;
  final Function(String) addEmail;
  final Function(String) removeEmail;
  final Function(bool) setInAppBannersEnabled;
  final Function(bool) setNotificationSoundEnabled;
  final Function(bool) setNotificationVibrationEnabled;
  final Function() viewSecurityLogs;

  NotificationSettingsViewModel({
    required this.settings,
    required this.toggleNotifications,
    required this.updatePreference,
    required this.addEmail,
    required this.removeEmail,
    required this.setInAppBannersEnabled,
    required this.setNotificationSoundEnabled,
    required this.setNotificationVibrationEnabled,
    required this.viewSecurityLogs,
  });

  static NotificationSettingsViewModel fromStore(Store<AppState> store) {
    return NotificationSettingsViewModel(
      settings: store.state.securityNotificationSettings,
      toggleNotifications: (enabled) {
        store.dispatch(ToggleSecurityNotifications(enabled: enabled));
      },
      updatePreference: (type, preference) {
        store.dispatch(UpdateNotificationPreference(
          preferenceType: type,
          preference: preference,
        ));
      },
      addEmail: (email) {
        store.dispatch(AddNotificationEmail(email: email));
      },
      removeEmail: (email) {
        store.dispatch(RemoveNotificationEmail(email: email));
      },
      setInAppBannersEnabled: (enabled) {
        store.dispatch(SetInAppBannersEnabled(enabled: enabled));
      },
      setNotificationSoundEnabled: (enabled) {
        store.dispatch(SetNotificationSoundEnabled(enabled: enabled));
      },
      setNotificationVibrationEnabled: (enabled) {
        store.dispatch(SetNotificationVibrationEnabled(enabled: enabled));
      },
      viewSecurityLogs: () {
        // Navigate to security logs screen
      },
    );
  }
}
