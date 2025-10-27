# Web Platform Configuration

## Target Platforms
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Mobile)
- Progressive Web App (PWA)

## Development Requirements
- Flutter SDK 3.0+
- Chrome 100+
- Node.js 16+
- npm/yarn

## Build Settings
- **Target**: JavaScript (ES6+)
- **CanvasKit/SkWASM**: WebGL rendering
- **WebAssembly**: Performance optimization
- **Service Worker**: PWA support

## Browser Support
- **Chrome**: 100+
- **Firefox**: 100+
- **Safari**: 15+
- **Edge**: 100+
- **Mobile Safari**: 15+
- **Chrome Mobile**: 100+

## Web App Manifest
```json
{
  "name": "Katya - Secure Messaging",
  "short_name": "Katya",
  "description": "Secure, decentralized messaging platform",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#007AFF",
  "orientation": "portrait-primary",
  "scope": "/",
  "lang": "en",
  "categories": ["productivity", "social", "communication"],
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable any"
    }
  ],
  "screenshots": [
    {
      "src": "screenshots/desktop.png",
      "sizes": "1280x720",
      "type": "image/png",
      "platform": "wide",
      "label": "Desktop view"
    },
    {
      "src": "screenshots/mobile.png",
      "sizes": "390x844",
      "type": "image/png",
      "platform": "narrow",
      "label": "Mobile view"
    }
  ],
  "shortcuts": [
    {
      "name": "New Chat",
      "short_name": "Chat",
      "description": "Start a new conversation",
      "url": "/chat/new",
      "icons": [
        {
          "src": "icons/chat-icon.png",
          "sizes": "96x96"
        }
      ]
    }
  ]
}
```

## Service Worker Configuration
```javascript
const CACHE_NAME = 'katya-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});

self.addEventListener('push', (event) => {
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body,
      icon: '/icons/icon-192.png',
      badge: '/icons/badge-72.png',
      vibrate: [200, 100, 200],
      data: {
        url: data.url
      },
      actions: [
        {
          action: 'open',
          title: 'Open Chat',
          icon: '/icons/open.png'
        },
        {
          action: 'close',
          title: 'Dismiss',
          icon: '/icons/close.png'
        }
      ]
    };

    event.waitUntil(
      self.registration.showNotification(data.title, options)
    );
  }
});
```

## Platform-Specific Features
- **Responsive Design**: Mobile-first approach
- **Touch Gestures**: Swipe navigation, pull-to-refresh
- **Keyboard Shortcuts**: Ctrl+K for search, Esc to close
- **Browser Notifications**: Request permission on first visit
- **Offline Support**: Cache important resources
- **Install Prompt**: Native app-like experience
- **Share Target**: Receive files from other apps
- **Web App Links**: Deep linking support
- **Context Menus**: Right-click options
- **Fullscreen Mode**: Immersive experience

## Build Commands
```bash
# Development build
flutter build web --web-renderer html

# Production build with CanvasKit
flutter build web --web-renderer canvaskit --release

# PWA build
flutter build web --pwa-strategy standalone --release

# Profile build
flutter build web --profile
```

## Deployment Options
### Static Hosting
- **Firebase Hosting**: CDN distribution
- **Netlify**: Edge functions support
- **Vercel**: Serverless deployment
- **GitHub Pages**: Free hosting
- **AWS S3 + CloudFront**: Global CDN

### CDN Configuration
```nginx
location / {
  try_files $uri $uri/ /index.html;
  add_header Cache-Control "public, immutable";
  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-Content-Type-Options "nosniff";
  add_header X-XSS-Protection "1; mode=block";
}

location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}
```

## Performance Optimization
- **Code Splitting**: Lazy load routes
- **Image Optimization**: WebP format, responsive images
- **Bundle Compression**: Gzip/Brotli
- **Caching Strategy**: Cache-first for assets
- **Prefetching**: Important resources
- **Tree Shaking**: Remove unused code
- **Minification**: JavaScript/CSS optimization

## Security Headers
- **Content Security Policy**: Restrict resource loading
- **HSTS**: Force HTTPS
- **X-Frame-Options**: Prevent clickjacking
- **X-Content-Type-Options**: MIME type protection
- **Referrer Policy**: Control referrer information

## Analytics & Monitoring
- **Google Analytics**: User behavior tracking
- **Sentry**: Error monitoring
- **Web Vitals**: Performance metrics
- **Real User Monitoring**: Core Web Vitals
- **Crash Reporting**: JavaScript error tracking

## SEO Configuration
- **Meta Tags**: Title, description, keywords
- **Open Graph**: Social media sharing
- **Twitter Cards**: Rich previews
- **Structured Data**: Schema.org markup
- **Sitemap**: XML sitemap generation
- **Robots.txt**: Search engine directives

## Testing
- **BrowserStack**: Cross-browser testing
- **Lighthouse**: Performance auditing
- **WebPageTest**: Load time analysis
- **Accessibility Testing**: Screen reader compatibility
- **Responsive Testing**: Mobile/tablet/desktop
