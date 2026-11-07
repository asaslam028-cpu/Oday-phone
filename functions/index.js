const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyAdminOnNewOrder = onDocumentCreated("orders/{orderId}", async (event) => {
  const data = event.data.data();
  const name = data.customerName || data.name || "عميل جديد";
  const total = data.total || data.amount || "";

  await getMessaging().send({
    topic: "admin",
    notification: {
      title: "طلب جديد في عدي فون",
      body: `طلب جديد من ${name} - ${total} جنيه`,
    },
    android: { priority: "high" },
  });
});
