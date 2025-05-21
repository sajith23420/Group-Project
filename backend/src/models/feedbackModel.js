const { FEEDBACK_STATUS } = require('../config/constants');

class Feedback {
  constructor(
    feedbackId,
    userId,
    subject,
    message,
    postOfficeId,
    rating,
    status = FEEDBACK_STATUS.NEW,
    adminResponse
  ) {
    this.feedbackId = feedbackId;
    this.userId = userId;
    this.postOfficeId = postOfficeId || null;
    this.subject = subject;
    this.message = message;
    this.rating = rating ? Number(rating) : null;
    this.submittedAt = new Date().toISOString();
    this.status = status;
    this.adminResponse = adminResponse || null;
  }

  static fromFirestore(doc) {
    const data = doc.data();
    const feedback = new Feedback(
      doc.id,
      data.userId,
      data.subject,
      data.message,
      data.postOfficeId,
      data.rating,
      data.status,
      data.adminResponse
    );
    feedback.submittedAt = data.submittedAt;
    return feedback;
  }

  toFirestore() {
    return {
      feedbackId: this.feedbackId,
      userId: this.userId,
      postOfficeId: this.postOfficeId,
      subject: this.subject,
      message: this.message,
      rating: this.rating,
      submittedAt: this.submittedAt,
      status: this.status,
      adminResponse: this.adminResponse,
    };
  }
}

module.exports = Feedback;
