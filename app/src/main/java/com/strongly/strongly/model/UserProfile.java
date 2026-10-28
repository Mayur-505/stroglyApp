package com.strongly.strongly.model;

import com.google.gson.Gson;
import com.strongly.strongly.util.Prefs;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class UserProfile {
    private static final String KEY = "user_profile";

    public String gender = "Male";
    public int height = 175;
    public String heightUnit = "CM";
    public int weight = 75;
    public String weightUnit = "Kg";
    public int age = 25;
    public String activityLevel = "Moderate";
    public List<String> goals = new ArrayList<>(Arrays.asList("Lose Weight", "Six Pack", "Stay Active"));
    public String workoutPlace = "Home";
    public String fitnessLevel = "Beginner";
    public String duration = "30 min";
    public String trainingDays = "5 Days";

    public UserProfile() {}

    public UserProfile(String gender) { this.gender = gender; }

    public void save() { Prefs.putString(KEY, new Gson().toJson(this)); }

    public static UserProfile load() {
        String s = Prefs.getString(KEY, null);
        if (s == null || s.isEmpty()) return new UserProfile();
        try {
            UserProfile p = new Gson().fromJson(s, UserProfile.class);
            return p != null ? p : new UserProfile();
        } catch (Exception e) {
            return new UserProfile();
        }
    }
}
