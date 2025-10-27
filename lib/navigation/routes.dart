class Routes {
  // Onboarding
  static const loading = '/loading';
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const forgot = '/forgot';
  static const reset = '/reset';
  static const verification = '/verification';
  static const searchHomeservers = '/search/homeservers';

  // Main (Authed)
  static const root = '/';
  static const home = '/home';

  // Search
  static const searchAll = '/home/search';
  static const searchChats = '/home/search/chats';
  static const searchUsers = '/home/search/users';
  static const searchGroups = '/home/search/groups';

  // Chat
  static const chat = '/home/chat';
  static const chatDetails = '/home/chat/details';
  static const chatAllUsers = '/home/chat/all-users';
  static const chatMessage = '/home/chat/message';
  static const mediaPreview = '/home/chat/media-preview';
  static const call = '/home/chat/call';
  static const callIncoming = '/home/chat/call-incoming';

  // Groups
  static const groupCreate = '/home/groups/create';
  static const groupCreatePublic = '/home/groups/create-public';
  static const inviteUsers = '/home/groups/invite';

  // Profile
  static const profile = '/home/profile';
  static const profileUser = '/home/profile/user';

  // Settings
  static const settings = '/home/settings';
  static const settingsChats = '/home/settings/chats';
  static const settingsDevices = '/home/settings/devices';
  static const settingsLanguages = '/home/settings/languages';
  static const settingsNotifications = '/home/settings/notifications';
  static const settingsPrivacy = '/home/settings/privacy';
  static const settingsAdvanced = '/home/settings/advanced';
  static const settingsBlocked = '/home/settings/blocked';
  static const settingsKeyBackup = '/home/settings/key-backup';
  static const settingsSecurity = '/home/settings/security';
  static const settingsPassword = '/home/settings/password';
  static const settingsSecurityLogs = '/home/settings/security-logs';
  static const settingsIPWhitelist = '/home/settings/ip-whitelist';
  static const settingsSession = '/home/settings/session';
  static const settingsRateLimit = '/home/settings/rate-limit';
  static const deviceManagement = '/home/settings/device-management';

  // QR Scanner
  static const qrScanner = '/home/qr-scanner';
}
