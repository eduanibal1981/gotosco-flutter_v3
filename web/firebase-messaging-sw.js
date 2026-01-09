// firebase-messaging-sw.js
// Service Worker for Firebase Cloud Messaging on Web

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Firebase config for GoToSco (from firebase_options.dart)
firebase.initializeApp({
    apiKey: 'AIzaSyAI860rY_P-yytu9n2aThb_KVbwcyp8Jb4',
    authDomain: 'gotoscoai-ec5bd.firebaseapp.com',
    projectId: 'gotoscoai-ec5bd',
    storageBucket: 'gotoscoai-ec5bd.firebasestorage.app',
    messagingSenderId: '7285013352',
    appId: '1:7285013352:web:0d19449a910a9ff77934dd',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message:', payload);

    const notificationTitle = payload.notification?.title || 'GoToSco';
    const notificationOptions = {
        body: payload.notification?.body || 'You have a new notification',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        data: payload.data,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    console.log('[firebase-messaging-sw.js] Notification click received.');
    event.notification.close();

    // Open the app or focus existing window
    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
            for (const client of clientList) {
                if (client.url.includes(self.location.origin) && 'focus' in client) {
                    return client.focus();
                }
            }
            if (clients.openWindow) {
                return clients.openWindow('/');
            }
        })
    );
});
