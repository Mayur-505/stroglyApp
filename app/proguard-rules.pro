-keep class com.strongly.strongly.model.** { *; }

# Facebook Audience Network (unused) references annotation classes that are not shipped
-dontwarn com.facebook.infer.annotation.**

# WorkManager (pulled in by the Ads SDK) creates its Room database by reflection
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.room.RoomDatabase
