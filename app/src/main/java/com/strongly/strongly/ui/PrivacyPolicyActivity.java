package com.strongly.strongly.ui;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

public class PrivacyPolicyActivity extends LegalPageActivity {

    @Override
    protected String headerTitle() {
        return "Privacy Policy";
    }

    @Override
    protected String headerSubtitle() {
        return "Legal & Data Protection";
    }

    @Override
    protected View heroCard() {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);

        LinearLayout tags = new LinearLayout(this);
        tags.setOrientation(LinearLayout.HORIZONTAL);
        tags.addView(pillTag(Icons.SHIELD_ROUNDED, "Verified Active Policy", LIME));
        View s = new View(this);
        tags.addView(s, new LinearLayout.LayoutParams(dp(8), 1));
        tags.addView(pillTag(0, "Google Play Compliant", 0xFF64B5F6));
        col.addView(tags);

        TextView title = text("Strongly Privacy Policy", 22, 900, 0xFFFFFFFF);
        col.addView(title, lp(-2, -2, 0, 12, 0, 4));

        TextView date = text("Effective Date: September 18, 2026 • Version 1.0.0", 12, 400, 0x8AFFFFFF);
        col.addView(date);

        return heroShell(col);
    }

    @Override
    protected void buildSections() {
        // Section 1: Overview
        {
            LinearLayout s = section(Icons.SHIELD_ROUNDED, LIME, "1. Overview & Developer Identity");
            body(s, "This Privacy Policy explains how Gree Web Solutions (\"we\", \"us\", or \"our\") collects, uses, stores, and protects your information when you use the Strongly mobile application (\"the App\") and our related services.");
            callout(s, Icons.SHIELD_ROUNDED, LIME, "Core Privacy Guarantee",
                    "We are deeply committed to respecting your privacy and ensuring transparency regarding your data. We do not sell your personal or fitness data to third parties under any circumstances.");
        }

        // Section 2: Information We Collect
        {
            LinearLayout s = section(Icons.INFO_OUTLINE_ROUNDED, 0xFF64B5F6, "2. Information We Collect");
            body(s, "Strongly is built with a privacy-first approach. We only collect information that is strictly necessary to deliver fitness experiences, track workout progress, and maintain app stability:");
            bullet(s, "A. Local Fitness & Activity Data:", "Information regarding your completed workouts, completed days in 30-day roadmaps, workout duration, estimated calories burned, and chosen preferences (such as selected language). Stored locally for fast, reliable offline access.");
            bullet(s, "B. Account & Cloud Sync (Optional):", "When you choose to create an account or log in, your name and email are securely stored to sync your workout history across devices.");
            bullet(s, "C. Device & Technical Information:", "Anonymous technical identifiers such as device model, OS version, and diagnostic logs to troubleshoot bugs and improve app stability.");
        }

        // Section 3: How We Use Your Information
        {
            LinearLayout s = section(Icons.TRENDING_UP_ROUNDED, 0xFFFFB74D, "3. How We Use Your Information");
            body(s, "The information processed is utilized exclusively for:");
            bullet(s, "•", "Delivering 30-day structured workout routines and calculating estimated calories burned.");
            bullet(s, "•", "Maintaining your active workout streaks and unlocked roadmap days.");
            bullet(s, "•", "Localizing app content into your selected language (10 languages supported).");
            bullet(s, "•", "Sending optional daily workout reminders and progress milestone notifications.");
            bullet(s, "•", "Diagnosing technical issues, crashes, and ensuring application stability.");
        }

        // Section 4: Device Permissions
        {
            LinearLayout s = section(Icons.POLICY_OUTLINED, 0xFFBA68C8, "4. Device Permissions");
            body(s, "To provide interactive workout coaching and background timers, Strongly may request the following permissions:");
            bullet(s, "Internet Access:", "Used to load workout guides and high-resolution exercise media assets from secure CDN servers.");
            bullet(s, "Foreground Service / Wake Lock:", "Ensures the workout countdown timer and audio guidance continue playing smoothly while you exercise.");
            bullet(s, "Notifications (Optional):", "To send reminder alerts for your daily workout schedule at your preferred time.");
            bullet(s, "Local Storage / Cache:", "To store workout history and media locally on your device for fast offline access.");
        }

        // Section 5: Data Security & Storage
        {
            LinearLayout s = section(Icons.LOCK_ROUNDED, 0xFF4DD0E1, "5. Data Security & Storage");
            body(s, "We implement industry-standard administrative, technical, and physical security measures:");
            bullet(s, "Encryption in Transit:", "All network transmissions are strictly encrypted using Transport Layer Security (TLS 1.2/1.3 / HTTPS).");
            bullet(s, "Secure Cloud Infrastructure:", "Content Delivery Networks (AWS S3) and secure backend APIs utilize encrypted storage protocols.");
            bullet(s, "Local-First Retention:", "Workout logs and settings are preserved on your device, giving you immediate control over your data.");
        }

        // Section 6: Third-Party Service Providers
        {
            LinearLayout s = section(Icons.PARK_ROUNDED, 0xFF81C784, "6. Third-Party Service Providers");
            body(s, "We partner with trusted third-party providers solely for infrastructure, analytics, and app delivery:");
            bullet(s, "Google Play Services:", "Core application distribution, in-app updates, and platform diagnostics.");
            bullet(s, "Amazon Web Services (AWS S3):", "Secure hosting and Content Delivery Network (CDN) for exercise media assets.");
        }

        // Section 7: User Rights & Data Control
        {
            LinearLayout s = section(Icons.CHECK_CIRCLE_OUTLINE_ROUNDED, LIME, "7. Your Rights & Data Control");
            body(s, "You maintain complete autonomy and ownership over your data:");
            bullet(s, "Data Ownership:", "Your exercise progression, unlocked days, and workout streak metrics reside directly under your control.");
            bullet(s, "Cloud Data Sync:", "When logged in, your progress is safely backed up to the cloud and restored whenever you log in on any device.");
            bullet(s, "Instant Data Erasure:", "You can clear local data at any time through application settings or by uninstalling the application.");
        }

        // Section 8: Children's Privacy
        {
            LinearLayout s = section(Icons.HELP_OUTLINE_ROUNDED, 0xFFFF8A65, "8. Children's Privacy");
            body(s, "Strongly is not intended for or marketed to children under the age of 13. We do not knowingly collect personal information from anyone under 13 years of age. If we learn of inadvertent collection, we promptly delete such data.");
        }

        // Section 9: Changes to this Policy
        {
            LinearLayout s = section(Icons.CALENDAR_TODAY_ROUNDED, 0xFFAED581, "9. Changes to this Policy");
            body(s, "We may periodically update this Privacy Policy to reflect changes in our app features or regulatory guidelines. When updates occur, the \"Last Updated\" date will be revised accordingly.");
        }
    }
}
