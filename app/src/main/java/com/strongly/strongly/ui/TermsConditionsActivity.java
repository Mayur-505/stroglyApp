package com.strongly.strongly.ui;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

public class TermsConditionsActivity extends LegalPageActivity {

    @Override
    protected String headerTitle() {
        return "Terms of Service";
    }

    @Override
    protected String headerSubtitle() {
        return "User Agreement & Fitness Disclaimer";
    }

    @Override
    protected View heroCard() {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);

        LinearLayout tags = new LinearLayout(this);
        tags.setOrientation(LinearLayout.HORIZONTAL);
        tags.addView(pillTag(Icons.DESCRIPTION_OUTLINED, "Legal Agreement", LIME));
        View s = new View(this);
        tags.addView(s, new LinearLayout.LayoutParams(dp(8), 1));
        tags.addView(pillTag(0, "Official Terms", 0xFFFFB74D));
        col.addView(tags);

        TextView title = text("Strongly Terms of Service", 22, 900, 0xFFFFFFFF);
        col.addView(title, lp(-2, -2, 0, 12, 0, 4));

        TextView date = text("Effective Date: September 18, 2026 • Version 1.0.0", 12, 400, 0x8AFFFFFF);
        col.addView(date);

        return heroShell(col);
    }

    @Override
    protected void buildSections() {
        // Section 1: Acceptance of Terms
        {
            LinearLayout s = section(Icons.CHECK_CIRCLE_OUTLINE_ROUNDED, LIME, "1. Acceptance of Terms");
            body(s, "By downloading, installing, accessing, or using the Strongly mobile application (\"the App\") or website, you agree to be bound by these Terms of Service (\"Terms\") provided by Gree Web Solutions (\"Company\", \"we\", \"our\"). If you do not agree to these Terms, please do not use the App.");
        }

        // Section 2: Important Health & Medical Disclaimer
        {
            LinearLayout s = section(Icons.WARNING_ROUNDED, 0xFFFFB74D, "2. Health & Medical Disclaimer");
            callout(s, Icons.WARNING_ROUNDED, 0xFFFFB74D, "IMPORTANT MEDICAL NOTICE",
                    "Strongly is an educational and fitness guidance tool for healthy individuals. The exercises, workout routines, calorie estimations, and nutrition recommendations provided in the App are for general informational purposes only and do NOT constitute medical advice, medical diagnosis, or personalized physical therapy.");
            bullet(s, "Consult Your Physician:", "You should always consult with a licensed physician or healthcare professional before beginning any new exercise routine or diet program, especially if you have pre-existing cardiovascular, musculoskeletal, respiratory, metabolic conditions, high blood pressure, or are pregnant.");
            bullet(s, "Voluntary Participation & Risk:", "Physical exercise carries an inherent risk of injury. You participate voluntarily and assume full responsibility for your physical capabilities. If you feel faint, dizzy, nauseous, or experience chest pain or severe shortness of breath, STOP IMMEDIATELY and seek emergency medical assistance.");
        }

        // Section 3: Limited License & Intellectual Property
        {
            LinearLayout s = section(Icons.SHIELD_ROUNDED, 0xFF64B5F6, "3. Intellectual Property License");
            body(s, "We grant you a personal, non-exclusive, non-transferable, revocable license to download and use Strongly strictly for personal, non-commercial fitness purposes.");
            body(s, "All trademarks, logos, exercise media, graphics, software code, workout routines, and user interfaces are the intellectual property of Gree Web Solutions and are protected by applicable intellectual property laws.");
        }

        // Section 4: App Usage & User Conduct
        {
            LinearLayout s = section(Icons.POLICY_OUTLINED, 0xFFBA68C8, "4. App Usage & User Conduct");
            body(s, "When using Strongly, you agree to:");
            bullet(s, "•", "Use the App solely for personal, non-commercial fitness training in accordance with applicable laws.");
            bullet(s, "•", "Not attempt to disrupt, decompile, reverse engineer, or exploit application assets or network services.");
            bullet(s, "•", "Not misuse the App or attempt unauthorized access to infrastructure or media content.");
        }

        // Section 5: Calorie Estimations Disclaimer
        {
            LinearLayout s = section(Icons.FIRE_ROUNDED, 0xFFFF7043, "5. Calorie & Progress Estimations");
            body(s, "All calorie burn calculations and estimated workout durations displayed within Strongly are mathematical approximations based on average metabolic rates. Actual calories burned vary significantly depending on individual body composition, age, gender, heart rate, and training intensity.");
        }

        // Section 6: Limitation of Liability
        {
            LinearLayout s = section(Icons.LOCK_ROUNDED, 0xFF4DD0E1, "6. Limitation of Liability");
            body(s, "To the maximum extent permitted by law, Gree Web Solutions, its developers, and affiliates shall not be liable for any direct, indirect, incidental, consequential, special, or punitive damages arising from your use of, or inability to use, the App or any workouts recommended herein.");
        }

        // Section 7: Termination
        {
            LinearLayout s = section(Icons.CLEAR_ROUNDED, 0xFFE57373, "7. Termination");
            body(s, "We reserve the right to suspend or discontinue support for Strongly at our sole discretion. You may terminate your use of the App at any time simply by discontinuing use or uninstalling Strongly from your device.");
        }

        // Section 8: Governing Law
        {
            LinearLayout s = section(Icons.LANGUAGE_ROUNDED, 0xFFAED581, "8. Governing Law");
            body(s, "These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law provisions.");
        }
    }
}
