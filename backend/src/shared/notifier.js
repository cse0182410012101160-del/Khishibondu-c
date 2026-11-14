class Notifier {
  async notifyUser() {
    throw new Error("Notifier.notifyUser must be implemented.");
  }
}

class ConsoleNotifier extends Notifier {
  async notifyUser(userId, notification, data = {}) {
    console.log(
      `[Notifier] ${userId}: ${notification.title} - ${notification.body}`,
      data,
    );
  }
}

class FcmNotifier extends Notifier {
  constructor(tokenStore) {
    super();
    this.tokenStore = tokenStore;
    const admin = require("firebase-admin");
    if (!admin.apps.length) {
      const credentials = process.env.FIREBASE_SERVICE_ACCOUNT_JSON
        ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
        : undefined;
      admin.initializeApp(
        credentials
          ? { credential: admin.credential.cert(credentials) }
          : undefined,
      );
    }
    this.messaging = admin.messaging();
  }

  async notifyUser(userId, notification, data = {}) {
    const tokens = this.tokenStore
      .filter((device) => device.userId === userId)
      .map((device) => device.token);
    if (!tokens.length) return;
    await this.messaging.sendEachForMulticast({
      tokens,
      notification,
      data: Object.fromEntries(
        Object.entries(data).map(([key, value]) => [key, String(value)]),
      ),
    });
  }
}

function createNotifier(tokenStore) {
  return (process.env.NOTIFIER || "console").toLowerCase() === "fcm"
    ? new FcmNotifier(tokenStore)
    : new ConsoleNotifier();
}

module.exports = { Notifier, ConsoleNotifier, FcmNotifier, createNotifier };
