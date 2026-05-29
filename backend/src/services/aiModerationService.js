const natural = require('compromise');
const Filter = require('bad-words');

// AI Moderation patterns
const VIOLATION_PATTERNS = {
  spam: ['click here', 'free money', 'get rich quick', 'limited time', 'act now', '100% guaranteed', 'make money fast', 'work from home'],
  harassment: ['kill yourself', 'die', 'worthless', 'stupid idiot', 'loser', 'ugly', 'fat', 'retard'],
  hateSpeech: ['hate group', 'inferior race', 'superior race', 'ethnic cleansing', 'genocide', 'white power', 'race war'],
  violence: ['bomb threat', 'shoot up', 'stab', 'murder', 'terrorist attack', 'mass shooting', 'kill everyone'],
  explicit: ['porn', 'xxx', 'nude', 'sexual content', 'adult video', 'onlyfans'],
  illegal: ['buy drugs', 'sell weed', 'hacking service', 'stolen credit card', 'fake id', 'illegal weapons'],
  phishing: ['verify your account', 'suspended', 'click link', 'confirm password', 'login here', 'security alert'],
  impersonation: ['official support', 'admin team', 'verify identity', 'security team', 'account manager'],
};

const filter = new Filter();

class AIModerationService {
  constructor() {
    this.violationScores = new Map();
    this.flaggedContent = new Map();
  }

  analyzeContent(content, userId, messageId) {
    const lowerContent = content.toLowerCase();
    let totalScore = 1.0;
    const violations = {};
    const flaggedKeywords = [];

    // Check each violation category
    for (const [category, patterns] of Object.entries(VIOLATION_PATTERNS)) {
      let score = 0;
      for (const pattern of patterns) {
        if (lowerContent.includes(pattern)) {
          score += 0.25;
          if (!flaggedKeywords.includes(pattern)) {
            flaggedKeywords.push(pattern);
          }
        }
      }

      // Check for profanity
      if (filter.isProfane(content)) {
        score += 0.3;
        const words = filter.clean(content).split(' ').filter(w => w === '***');
        words.forEach(w => flaggedKeywords.push('profanity'));
      }

      // NLP analysis
      const doc = natural(content);
      const negativeWords = doc.match('#Negative').json();
      if (negativeWords.length > 3) {
        score += 0.1 * negativeWords.length;
      }

      if (score > 0) {
        violations[category] = Math.min(score, 1.0);
        totalScore -= score * 0.1;
      }
    }

    totalScore = Math.max(0, Math.min(1, totalScore));
    const requiresReview = totalScore < 0.5 || Object.values(violations).some(s => s > 0.5);
    const isRestricted = totalScore < 0.3;

    const result = {
      safetyScore: totalScore,
      violations,
      flaggedKeywords,
      requiresHumanReview: requiresReview,
      isRestricted,
      restrictionReason: isRestricted ? this._getRestrictionReason(violations) : null,
      timestamp: new Date(),
    };

    // Store for tracking
    if (messageId) {
      this.flaggedContent.set(messageId, { userId, content, result });
    }

    return result;
  }

  _getRestrictionReason(violations) {
    const topViolation = Object.entries(violations)
      .sort((a, b) => b[1] - a[1])[0];
    if (topViolation) {
      return `Flagged for ${topViolation[0]} (score: ${(topViolation[1] * 100).toFixed(1)}%)`;
    }
    return 'Content violates community guidelines';
  }

  getUserStrikeCount(userId) {
    let count = 0;
    for (const [_, data] of this.flaggedContent) {
      if (data.userId === userId && data.result.isRestricted) {
        count++;
      }
    }
    return count;
  }

  shouldBanUser(userId) {
    return this.getUserStrikeCount(userId) >= 3;
  }
}

const moderationService = new AIModerationService();

function setupAIModeration() {
  console.log('✅ AI Moderation Service initialized');
}

module.exports = { 
  AIModerationService, 
  moderationService, 
  setupAIModeration 
};
