const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { title, body, token } = data;

  const message = {
    notification: { title, body },
    token: token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return { success: true };
  } catch (error) {
    console.error('Error sending message:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
