import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Interface label: Research, lectures and projects
  ///
  /// In en, this message translates to:
  /// **'Research, lectures and projects'**
  String get label9794059229;

  /// Interface label: All caught up! You have read every notification.
  ///
  /// In en, this message translates to:
  /// **'All caught up! You have read every notification.'**
  String get label327647350e;

  /// Interface label: Red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get label96cab1ba1b;

  /// Interface label: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get label83b4b55adb;

  /// Interface label: Green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get labela6b0763996;

  /// Interface label: Great effort! Review the explanations for the questions you missed.
  ///
  /// In en, this message translates to:
  /// **'Great effort! Review the explanations for the questions you missed.'**
  String get label184b890547;

  /// Interface label: Purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get label256fbd4d63;

  /// Interface label: Blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get labelb2d33354b5;

  /// Interface label: Memory and effective learning fundamentals
  ///
  /// In en, this message translates to:
  /// **'Memory and effective learning fundamentals'**
  String get labelc22a33af23;

  /// Interface label: Yellow
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get label62b0721618;

  /// Interface label: Schedule times for today’s tasks to see your time distribution here.
  ///
  /// In en, this message translates to:
  /// **'Schedule times for today’s tasks to see your time distribution here.'**
  String get label64aa1cf1d3;

  /// Interface label: Add your first summary or idea to revisit later.
  ///
  /// In en, this message translates to:
  /// **'Add your first summary or idea to revisit later.'**
  String get label572e3c0c8b;

  /// Interface label: Best streak
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get label3a45e59ce6;

  /// Interface label: Yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get label3957c8cfd0;

  /// Interface label: You
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get label4ab1332cb5;

  /// Interface label: You are ready to go!
  ///
  /// In en, this message translates to:
  /// **'You are ready to go!'**
  String get label17bb0fc3ae;

  /// Interface label: Create a folder for each subject to keep books, notes and files together.
  ///
  /// In en, this message translates to:
  /// **'Create a folder for each subject to keep books, notes and files together.'**
  String get label3bc56b236c;

  /// Interface label: Achievements and badges
  ///
  /// In en, this message translates to:
  /// **'Achievements and badges'**
  String get label7d647179ef;

  /// Interface label: Total files
  ///
  /// In en, this message translates to:
  /// **'Total files'**
  String get label345c9b984b;

  /// Interface label: Total pages
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get label88efd3f598;

  /// Interface label: Send a test notification
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get label78111d1be8;

  /// Interface label: Notify me when a study session or break ends
  ///
  /// In en, this message translates to:
  /// **'Notify me when a study session or break ends'**
  String get label8f0b2f504b;

  /// Interface label: Encouragement and reminders for today's tasks
  ///
  /// In en, this message translates to:
  /// **'Encouragement and reminders for today\'s tasks'**
  String get label9c80a6131b;

  /// Interface label: Goal reminders
  ///
  /// In en, this message translates to:
  /// **'Goal reminders'**
  String get label9d0806067c;

  /// Interface label: Add progress (+1)
  ///
  /// In en, this message translates to:
  /// **'Add progress (+1)'**
  String get labelbde855a064;

  /// Interface label: Add habit
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get labelc7a51040d4;

  /// Interface label: New habit
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get label1fcc2c1763;

  /// Interface label: Add a subject
  ///
  /// In en, this message translates to:
  /// **'Add a subject'**
  String get labelf629361869;

  /// Interface label: Create a subject folder
  ///
  /// In en, this message translates to:
  /// **'Create a subject folder'**
  String get labelb441edc2ab;

  /// Interface label: Add a note
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get label1552e5f5ad;

  /// Interface label: Add a file
  ///
  /// In en, this message translates to:
  /// **'Add a file'**
  String get labelfafed82e68;

  /// Interface label: Add a file or book
  ///
  /// In en, this message translates to:
  /// **'Add a file or book'**
  String get label4e13fff422;

  /// Interface label: Add your first file
  ///
  /// In en, this message translates to:
  /// **'Add your first file'**
  String get label6954b8cdca;

  /// Interface label: Add task
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get label21164b4c0f;

  /// Interface label: Add a study task
  ///
  /// In en, this message translates to:
  /// **'Add a study task'**
  String get label133d2cb86b;

  /// Interface label: Add a goal
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get label4aeb2adb11;

  /// Interface label: Add a study goal
  ///
  /// In en, this message translates to:
  /// **'Add a study goal'**
  String get labelb84d5c5e4d;

  /// Interface label: Add homework
  ///
  /// In en, this message translates to:
  /// **'Add homework'**
  String get labelb588673a63;

  /// Interface label: New assignment
  ///
  /// In en, this message translates to:
  /// **'New assignment'**
  String get label3191b586a7;

  /// Interface label: Try again
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get label2e47b5f289;

  /// Interface label: Reset timer
  ///
  /// In en, this message translates to:
  /// **'Reset timer'**
  String get labeld242591f4a;

  /// Interface label: Timer and alarm settings
  ///
  /// In en, this message translates to:
  /// **'Timer and alarm settings'**
  String get label7edd904a2e;

  /// Interface label: Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get label5bf826c5e5;

  /// Interface label: Complete a focus session (25 minutes)
  ///
  /// In en, this message translates to:
  /// **'Complete a focus session (25 minutes)'**
  String get label5e964cb2c1;

  /// Interface label: Complete a study task
  ///
  /// In en, this message translates to:
  /// **'Complete a study task'**
  String get label2d67c55659;

  /// Interface label: Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get labele776b0209b;

  /// Interface label: Complete a task in your daily planner
  ///
  /// In en, this message translates to:
  /// **'Complete a task in your daily planner'**
  String get labelc5cc69b5c4;

  /// Interface label: Create a study plan
  ///
  /// In en, this message translates to:
  /// **'Create a study plan'**
  String get label54e28418a2;

  /// Interface label: Create Folder
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get label707e9ad0b9;

  /// Interface label: Create a practice quiz
  ///
  /// In en, this message translates to:
  /// **'Create a practice quiz'**
  String get labelfffd7b92c0;

  /// Interface label: Finish homework before its deadline
  ///
  /// In en, this message translates to:
  /// **'Finish homework before its deadline'**
  String get label09dfa4bf2a;

  /// Interface label: Pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get label1e5093f2e1;

  /// Interface label: Search titles or content…
  ///
  /// In en, this message translates to:
  /// **'Search titles or content…'**
  String get label652e3cf3c4;

  /// Interface label: Set up your workspace
  ///
  /// In en, this message translates to:
  /// **'Set up your workspace'**
  String get label2b290d0462;

  /// Interface label: Start focusing
  ///
  /// In en, this message translates to:
  /// **'Start focusing'**
  String get label12cfbc9db4;

  /// Interface label: Build positive daily habits
  ///
  /// In en, this message translates to:
  /// **'Build positive daily habits'**
  String get label8b6bffc240;

  /// Interface label: Build consistent study habits to work towards your goals.
  ///
  /// In en, this message translates to:
  /// **'Build consistent study habits to work towards your goals.'**
  String get labeladd43f99c5;

  /// Interface label: Quiz me on physics with multiple choice questions
  ///
  /// In en, this message translates to:
  /// **'Quiz me on physics with multiple choice questions'**
  String get labeldf1e61baa2;

  /// Interface label: Choose your education level
  ///
  /// In en, this message translates to:
  /// **'Choose your education level'**
  String get labelf0065a3563;

  /// Interface label: Choose a theme or follow your device settings
  ///
  /// In en, this message translates to:
  /// **'Choose a theme or follow your device settings'**
  String get labelc695a6727c;

  /// Interface label: Choose a note for a local summary
  ///
  /// In en, this message translates to:
  /// **'Choose a note for a local summary'**
  String get labele2627de87d;

  /// Interface label: Ask about a subject, a plan or a quiz…
  ///
  /// In en, this message translates to:
  /// **'Ask about a subject, a plan or a quiz…'**
  String get labelad1bf7a9f8;

  /// Interface label: Break
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get labelc3f2fec662;

  /// Interface label: Long break
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get labeld5dfe01751;

  /// Interface label: Long break (minutes)
  ///
  /// In en, this message translates to:
  /// **'Long break (minutes)'**
  String get labelfa96e585b2;

  /// Interface label: Short break
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get labelf21b23e924;

  /// Interface label: Short break (minutes)
  ///
  /// In en, this message translates to:
  /// **'Short break (minutes)'**
  String get labela2d8e5730b;

  /// Interface label: Student name
  ///
  /// In en, this message translates to:
  /// **'Student name'**
  String get label5ae0209cf4;

  /// Interface label: Student name:
  ///
  /// In en, this message translates to:
  /// **'Student name:'**
  String get label6618dc51b6;

  /// Interface label: Habit name
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get labela15f43fe00;

  /// Interface label: Subject Name
  ///
  /// In en, this message translates to:
  /// **'Subject Name'**
  String get labelb673c0111f;

  /// Interface label: Subject or topic:
  ///
  /// In en, this message translates to:
  /// **'Subject or topic:'**
  String get label4d072b0e9b;

  /// Interface label: Your name and education level help personalize your study space.
  ///
  /// In en, this message translates to:
  /// **'Your name and education level help personalize your study space.'**
  String get label37251b0910;

  /// Interface label: Now
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get label7b94973f96;

  /// Interface label: Sun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get label85c4f658c9;

  /// Interface label: Wed
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get label70eb298427;

  /// Interface label: Sounds and effects
  ///
  /// In en, this message translates to:
  /// **'Sounds and effects'**
  String get label259bd1aefe;

  /// Interface label: Goals
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get label943b13bbbc;

  /// Interface label: Study goals
  ///
  /// In en, this message translates to:
  /// **'Study goals'**
  String get label98129d55bf;

  /// Interface label: Priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get label44ad0c1afc;

  /// Interface label: Mon
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get label95a522655e;

  /// Interface label: Statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get label810ea582a5;

  /// Interface label: Notifications and reminders
  ///
  /// In en, this message translates to:
  /// **'Notifications and reminders'**
  String get label8eec5361dc;

  /// Interface label: Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get label90b6c869a1;

  /// Interface label: Current progress
  ///
  /// In en, this message translates to:
  /// **'Current progress'**
  String get label11a71f2cb6;

  /// Interface label: Progress must be between zero and the total target.
  ///
  /// In en, this message translates to:
  /// **'Progress must be between zero and the total target.'**
  String get label8c4a54a93c;

  /// Interface label: Full name
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get labele19b16bdb7;

  /// Interface label: Haptic feedback
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get labela63e974f36;

  /// Interface label: Focus
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get labelfb631b39ab;

  /// Interface label: Category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get label7c75fec5c0;

  /// Interface label: Explanation:
  ///
  /// In en, this message translates to:
  /// **'Explanation:'**
  String get label7be18f05e3;

  /// Interface label: Progress
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get label1fec4efe90;

  /// Interface label: Overall progress
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get label0b5ca28bab;

  /// Interface label: Daily reminders:
  ///
  /// In en, this message translates to:
  /// **'Daily reminders:'**
  String get labele1c0cc7d53;

  /// Interface label: Tue
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get label5965d7956e;

  /// Interface label: Fri
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get label8d067a376a;

  /// Interface label: Rewards (XP)
  ///
  /// In en, this message translates to:
  /// **'Rewards (XP)'**
  String get label0a19938ed9;

  /// Interface label: Maintain a daily study streak
  ///
  /// In en, this message translates to:
  /// **'Maintain a daily study streak'**
  String get labelc261b1dbcd;

  /// Interface label: Thu
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get labelea7bf454d2;

  /// Interface label: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelb986d8fb16;

  /// Interface label: Mathematics
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get label825de89502;

  /// Interface label: Previous
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get labelf533ebab64;

  /// Interface label: Sat
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get labelc7e6b0c840;

  /// Interface label: Current streak
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get label37f705f7ca;

  /// Interface label: Daily habits
  ///
  /// In en, this message translates to:
  /// **'Daily habits'**
  String get labelbf0c4c9e43;

  /// Interface label: Title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelbaffa49c77;

  /// Interface label: Physics
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get label81f1d57162;

  /// Interface label: All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get label11fdef2dc5;

  /// Interface label: Subject
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get labelb510d10bcd;

  /// Interface label: Subject
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get label23aa451148;

  /// Interface label: Subject:
  ///
  /// In en, this message translates to:
  /// **'Subject:'**
  String get label2b722794a7;

  /// Interface label: Folder / subject
  ///
  /// In en, this message translates to:
  /// **'Folder / subject'**
  String get label3a4342e920;

  /// Interface label: This folder is empty
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get labela6b32448b7;

  /// Interface label: Content
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get label1711387d68;

  /// Interface label: Planner
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get label7a286c5563;

  /// Interface label: Daily planner
  ///
  /// In en, this message translates to:
  /// **'Daily planner'**
  String get labeldc69e909cb;

  /// Interface label: Middle school
  ///
  /// In en, this message translates to:
  /// **'Middle school'**
  String get label3eb87a1f76;

  /// Interface label: High school
  ///
  /// In en, this message translates to:
  /// **'High school'**
  String get label2b7e1606ae;

  /// Interface label: University
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get label0fa4c92748;

  /// Interface label: Education level
  ///
  /// In en, this message translates to:
  /// **'Education level'**
  String get label7258aef4a4;

  /// Interface label: Education level:
  ///
  /// In en, this message translates to:
  /// **'Education level:'**
  String get label624cec98eb;

  /// Interface label: More
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get label6a4ef56148;

  /// Interface label: Study assistant
  ///
  /// In en, this message translates to:
  /// **'Study assistant'**
  String get label04f582e7c3;

  /// Interface label: Study assistant
  ///
  /// In en, this message translates to:
  /// **'Study assistant'**
  String get label57333f55c1;

  /// Interface label: Local study assistant
  ///
  /// In en, this message translates to:
  /// **'Local study assistant'**
  String get label536dd0128a;

  /// Interface label: Preparing a response…
  ///
  /// In en, this message translates to:
  /// **'Preparing a response…'**
  String get labelf08dcc6140;

  /// Interface label: Rewards and badges
  ///
  /// In en, this message translates to:
  /// **'Rewards and badges'**
  String get labelaf76e78def;

  /// Interface label: Library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get label0bababdcc9;

  /// Interface label: Books, notes and PDFs
  ///
  /// In en, this message translates to:
  /// **'Books, notes and PDFs'**
  String get labelced8429c05;

  /// Interface label: Library and notes
  ///
  /// In en, this message translates to:
  /// **'Library and notes'**
  String get label6b5542e840;

  /// Interface label: Notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelb172fc1d3b;

  /// Interface label: Morning digest
  ///
  /// In en, this message translates to:
  /// **'Morning digest'**
  String get labele61ac719b7;

  /// Interface label: Daily morning digest
  ///
  /// In en, this message translates to:
  /// **'Daily morning digest'**
  String get label1ca0eecebf;

  /// Interface label: Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get label2f1419b780;

  /// Interface label: Alarm muted
  ///
  /// In en, this message translates to:
  /// **'Alarm muted'**
  String get label3ea2be5019;

  /// Interface label: Alarm enabled
  ///
  /// In en, this message translates to:
  /// **'Alarm enabled'**
  String get labele61db7663e;

  /// Interface label: Tasks
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get label385634c132;

  /// Interface label: Completed tasks this week
  ///
  /// In en, this message translates to:
  /// **'Completed tasks this week'**
  String get label8aa995d913;

  /// Interface label: Subjects
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get labelaa2d5b333d;

  /// Interface label: Study edition
  ///
  /// In en, this message translates to:
  /// **'Study edition'**
  String get label0a259af8b7;

  /// Interface label: Total target
  ///
  /// In en, this message translates to:
  /// **'Total target'**
  String get labele7bf204fac;

  /// Interface label: Homework
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get label9c18690657;

  /// Interface label: Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get labela34a799122;

  /// Interface label: Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get label7d3a88b2b9;

  /// Interface label: Preferred study time:
  ///
  /// In en, this message translates to:
  /// **'Preferred study time:'**
  String get label39fe99a473;

  /// Interface label: Focus session complete! Take a well-earned break.
  ///
  /// In en, this message translates to:
  /// **'Focus session complete! Take a well-earned break.'**
  String get label32976e5b33;

  /// Interface label: Open your study space ✦
  ///
  /// In en, this message translates to:
  /// **'Open your study space ✦'**
  String get label79beb7bb26;

  /// Interface label: Edit your student profile
  ///
  /// In en, this message translates to:
  /// **'Edit your student profile'**
  String get label2a9826c7d7;

  /// Interface label: Vibration
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get labele75a15ba7f;

  /// Interface label: Search notes
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get label684b539df9;

  /// Interface label: Start a focus session for this plan
  ///
  /// In en, this message translates to:
  /// **'Start a focus session for this plan'**
  String get label842ce7d95f;

  /// Interface label: New conversation
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get label50daf2b8bb;

  /// Interface label: Purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get label013ff80b0a;

  /// Interface label: Question bank
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get labelcde07e48c5;

  /// Interface label: Plan your next step using your actual task data.
  ///
  /// In en, this message translates to:
  /// **'Plan your next step using your actual task data.'**
  String get labele3413c3640;

  /// Interface label: Strong foundations and organization
  ///
  /// In en, this message translates to:
  /// **'Strong foundations and organization'**
  String get labelfb5db35cd7;

  /// Interface label: Confirm study plan
  ///
  /// In en, this message translates to:
  /// **'Confirm study plan'**
  String get labelca4e6a21b2;

  /// Interface label: Confirm data reset
  ///
  /// In en, this message translates to:
  /// **'Confirm data reset'**
  String get label82e2c6a8f6;

  /// Interface label: History
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get label6d5892d913;

  /// Interface label: End date
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get label4ea6e4d5ff;

  /// Interface label: Due date
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get label744dccdcdc;

  /// Interface label: Keep track of assignments and deadlines.
  ///
  /// In en, this message translates to:
  /// **'Keep track of assignments and deadlines.'**
  String get label7ea0c084e5;

  /// Interface label: Discard changes
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get label39364a1b73;

  /// Interface label: Discard changes?
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get label16a0e757de;

  /// Interface label: Try a sample summary
  ///
  /// In en, this message translates to:
  /// **'Try a sample summary'**
  String get label8465206f36;

  /// Interface label: Update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get label4309a75e68;

  /// Interface label: Update pages
  ///
  /// In en, this message translates to:
  /// **'Update pages'**
  String get label2a5183092b;

  /// Interface label: Update reading progress
  ///
  /// In en, this message translates to:
  /// **'Update reading progress'**
  String get label7537f1d8f6;

  /// Interface label: Goal deadline reminders
  ///
  /// In en, this message translates to:
  /// **'Goal deadline reminders'**
  String get label87ac7c9859;

  /// Interface label: Complete a study goal
  ///
  /// In en, this message translates to:
  /// **'Complete a study goal'**
  String get labelaee54b6433;

  /// Interface label: Reach 100% of a study goal
  ///
  /// In en, this message translates to:
  /// **'Reach 100% of a study goal'**
  String get label23f32ccb64;

  /// Interface label: Manage task, focus timer and morning reminders
  ///
  /// In en, this message translates to:
  /// **'Manage task, focus timer and morning reminders'**
  String get label990aa481cf;

  /// Interface label: Personalize your profile, appearance and preferences
  ///
  /// In en, this message translates to:
  /// **'Personalize your profile, appearance and preferences'**
  String get label72c55adc2c;

  /// Interface label: Skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get labeld467da0e5d;

  /// Interface label: Task reminders (15 minutes before)
  ///
  /// In en, this message translates to:
  /// **'Task reminders (15 minutes before)'**
  String get label123d0ce932;

  /// Interface label: Study reminders
  ///
  /// In en, this message translates to:
  /// **'Study reminders'**
  String get labeldf404d8370;

  /// Interface label: Undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get label98df46fbd8;

  /// Interface label: Move to today
  ///
  /// In en, this message translates to:
  /// **'Move to today'**
  String get label7bc073b199;

  /// Interface label: Focus
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get label36bbf1d771;

  /// Interface label: Focus and prioritization
  ///
  /// In en, this message translates to:
  /// **'Focus and prioritization'**
  String get labeldd427da7eb;

  /// Interface label: Record progress
  ///
  /// In en, this message translates to:
  /// **'Record progress'**
  String get labelb81f2b0399;

  /// Interface label: Play alarm sound
  ///
  /// In en, this message translates to:
  /// **'Play alarm sound'**
  String get labeleb5578a0a5;

  /// Interface label: Play a sound with notifications
  ///
  /// In en, this message translates to:
  /// **'Play a sound with notifications'**
  String get label47fa6eedc6;

  /// Interface label: Edit note
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get label72cac6825a;

  /// Interface label: Edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get label3c89739532;

  /// Interface label: Edit your name and education level
  ///
  /// In en, this message translates to:
  /// **'Edit your name and education level'**
  String get labelfbeb103b29;

  /// Interface label: Notification permission was not granted by the browser or system.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted by the browser or system.'**
  String get label4f3cfb06a9;

  /// Interface label: Unable to load content
  ///
  /// In en, this message translates to:
  /// **'Unable to load content'**
  String get labelc19e997e6e;

  /// Interface label: Could not delete. Please retry.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please retry.'**
  String get label364c0b68d6;

  /// Interface label: Could not save. Please retry.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please retry.'**
  String get labeld8e329ab4f;

  /// Interface label: Could not restore. Please retry.
  ///
  /// In en, this message translates to:
  /// **'Could not restore. Please retry.'**
  String get label5b26593d75;

  /// Interface label: Independent learning and professional courses
  ///
  /// In en, this message translates to:
  /// **'Independent learning and professional courses'**
  String get labeld03be70807;

  /// Interface label: Assignment details
  ///
  /// In en, this message translates to:
  /// **'Assignment details'**
  String get label661611374b;

  /// Interface label: Vibrate when a notification arrives
  ///
  /// In en, this message translates to:
  /// **'Vibrate when a notification arrives'**
  String get label2f262e249f;

  /// Interface label: Use dark mode
  ///
  /// In en, this message translates to:
  /// **'Use dark mode'**
  String get label9c28e43ea4;

  /// Interface label: Use light mode
  ///
  /// In en, this message translates to:
  /// **'Use light mode'**
  String get labelc0d49c119f;

  /// Interface label: Summarize notes
  ///
  /// In en, this message translates to:
  /// **'Summarize notes'**
  String get labelc91a04c5c6;

  /// Interface label: Summarize a saved note
  ///
  /// In en, this message translates to:
  /// **'Summarize a saved note'**
  String get label9025946250;

  /// Interface label: Follow system
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get label8f1fa03ce2;

  /// Interface label: Test notification sent and saved to your notification history.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent and saved to your notification history.'**
  String get label43285fe2a5;

  /// Interface label: Your study space is ready.
  ///
  /// In en, this message translates to:
  /// **'Your study space is ready.'**
  String get labela1712a9876;

  /// Interface label: Deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get label978dd66713;

  /// Interface label: Profile updated! ✅
  ///
  /// In en, this message translates to:
  /// **'Profile updated! ✅'**
  String get labelf4f4fd90c6;

  /// Interface label: Notification permission granted!
  ///
  /// In en, this message translates to:
  /// **'Notification permission granted!'**
  String get label6aa73219b5;

  /// Interface label: Summary copied to clipboard!
  ///
  /// In en, this message translates to:
  /// **'Summary copied to clipboard!'**
  String get label4f975c463c;

  /// Interface label: Add 5 minutes
  ///
  /// In en, this message translates to:
  /// **'Add 5 minutes'**
  String get labelc340d44e50;

  /// Interface label: Vibrate when time runs out
  ///
  /// In en, this message translates to:
  /// **'Vibrate when time runs out'**
  String get label99ec32bdc8;

  /// Interface label: Notify me before a deadline or when a goal is complete
  ///
  /// In en, this message translates to:
  /// **'Notify me before a deadline or when a goal is complete'**
  String get labela742813ba8;

  /// Interface label: Remind me before each scheduled task
  ///
  /// In en, this message translates to:
  /// **'Remind me before each scheduled task'**
  String get label96f5148fc6;

  /// Interface label: Focus and break notifications
  ///
  /// In en, this message translates to:
  /// **'Focus and break notifications'**
  String get labela4084551f3;

  /// Interface label: Organize books, notes and PDFs into subject folders
  ///
  /// In en, this message translates to:
  /// **'Organize books, notes and PDFs into subject folders'**
  String get label91ffc329a4;

  /// Interface label: This note has unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'This note has unsaved changes.'**
  String get label26f63063a4;

  /// Interface label: Today’s planned time
  ///
  /// In en, this message translates to:
  /// **'Today’s planned time'**
  String get label0d99062ae7;

  /// Interface label: Create quiz
  ///
  /// In en, this message translates to:
  /// **'Create quiz'**
  String get label2d8fcf372a;

  /// Interface label: Create a study plan
  ///
  /// In en, this message translates to:
  /// **'Create a study plan'**
  String get label9e437f768f;

  /// Interface label: Tasks are grouped by their scheduled day.
  ///
  /// In en, this message translates to:
  /// **'Tasks are grouped by their scheduled day.'**
  String get labeld82f15bc46;

  /// Interface label: Change or clear the filters to see more items.
  ///
  /// In en, this message translates to:
  /// **'Change or clear the filters to see more items.'**
  String get label550da3f152;

  /// Interface label: Try a different search or view all messages.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or view all messages.'**
  String get labeldb1f635346;

  /// Interface label: Focus session complete
  ///
  /// In en, this message translates to:
  /// **'Focus session complete'**
  String get label9ef4a40af8;

  /// Interface label: Books, notes and summaries for this subject
  ///
  /// In en, this message translates to:
  /// **'Books, notes and summaries for this subject'**
  String get label6daa9348a6;

  /// Interface label: Stay focused with a timer and an optional alarm
  ///
  /// In en, this message translates to:
  /// **'Stay focused with a timer and an optional alarm'**
  String get label6aca22bf47;

  /// Interface label: Could not save your data. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not save your data. Please try again.'**
  String get labeldbe6f46a0f;

  /// Interface label: Could not save your changes.
  ///
  /// In en, this message translates to:
  /// **'Could not save your changes.'**
  String get label6725522272;

  /// Interface label: Could not restore your data. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not restore your data. Please try again.'**
  String get label79f05a8b5e;

  /// Interface label: Set study goals and track your progress, step by step.
  ///
  /// In en, this message translates to:
  /// **'Set study goals and track your progress, step by step.'**
  String get label9e1ffc1710;

  /// Interface label: Choose a sustainable daily study pace.
  ///
  /// In en, this message translates to:
  /// **'Choose a sustainable daily study pace.'**
  String get labele0219fd385;

  /// Interface label: Delete habit
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get labelaf769a073e;

  /// Interface label: Delete item
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get labeldc7679723f;

  /// Interface label: Delete note
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get labeld3204c4f82;

  /// Interface label: Delete task
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get labelb8eea0d23c;

  /// Interface label: OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get labeld4c6598d6f;

  /// Interface label: Save settings
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get labela5b4472cdf;

  /// Interface label: Save changes
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get label41097c7fa7;

  /// Interface label: Save habit
  ///
  /// In en, this message translates to:
  /// **'Save habit'**
  String get labeld6a07f1209;

  /// Interface label: Save note
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get labelb2fbee589f;

  /// Interface label: Save task (+50 XP on completion)
  ///
  /// In en, this message translates to:
  /// **'Save task (+50 XP on completion)'**
  String get labelb465f6facc;

  /// Interface label: Save goal (+300 XP on completion)
  ///
  /// In en, this message translates to:
  /// **'Save goal (+300 XP on completion)'**
  String get label87d00b45ea;

  /// Interface label: Save homework
  ///
  /// In en, this message translates to:
  /// **'Save homework'**
  String get label05a254cff3;

  /// Interface label: Save to folder
  ///
  /// In en, this message translates to:
  /// **'Save to folder'**
  String get labelc788bf129c;

  /// Interface label: New plan
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get label104b09cb1e;

  /// Interface label: Study plans
  ///
  /// In en, this message translates to:
  /// **'Study plans'**
  String get label03cd948cfb;

  /// Interface label: Study plans, note summaries and motivating XP levels.
  ///
  /// In en, this message translates to:
  /// **'Study plans, note summaries and motivating XP levels.'**
  String get label3b7587c187;

  /// Interface label: Alarm options
  ///
  /// In en, this message translates to:
  /// **'Alarm options'**
  String get label569f485e0f;

  /// Interface label: Study
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get label996e5739fa;

  /// Interface label: Tutoring
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get labelc1b1cba364;

  /// Interface label: Let's get to know you
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get label15df61a24e;

  /// Interface label: min
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get labelb030187c8a;

  /// Interface label: A morning reminder to review today's tasks and goals
  ///
  /// In en, this message translates to:
  /// **'A morning reminder to review today\'s tasks and goals'**
  String get label302a236dd7;

  /// Interface label: YOUR STUDY COMPANION
  ///
  /// In en, this message translates to:
  /// **'YOUR STUDY COMPANION'**
  String get label974e44e09a;

  /// Interface label: Your study companion for planning and productivity
  ///
  /// In en, this message translates to:
  /// **'Your study companion for planning and productivity'**
  String get label0579ba926d;

  /// Interface label: Your break is over. Ready for another focus session?
  ///
  /// In en, this message translates to:
  /// **'Your break is over. Ready for another focus session?'**
  String get label4724e35d72;

  /// Interface label: Play an alarm when a session ends
  ///
  /// In en, this message translates to:
  /// **'Play an alarm when a session ends'**
  String get labelea9ccc80d4;

  /// Interface label: Low priority 🟢
  ///
  /// In en, this message translates to:
  /// **'Low priority 🟢'**
  String get label66b6b05b6e;

  /// Interface label: Exercise
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get label8af22f7f74;

  /// Interface label: 3D Flip Clock
  ///
  /// In en, this message translates to:
  /// **'3D Flip Clock'**
  String get label516dc08820;

  /// Interface label: A flip clock for personalized focus sessions.
  ///
  /// In en, this message translates to:
  /// **'A flip clock for personalized focus sessions.'**
  String get labelb118689dc8;

  /// Interface label: Study reminders, timer alerts and goal updates will appear here.
  ///
  /// In en, this message translates to:
  /// **'Study reminders, timer alerts and goal updates will appear here.'**
  String get labele69eeda4a9;

  /// Interface label: Reminders, tasks and important deadlines
  ///
  /// In en, this message translates to:
  /// **'Reminders, tasks and important deadlines'**
  String get labelc2363be47f;

  /// Interface label: Keep track of assignments and due dates.
  ///
  /// In en, this message translates to:
  /// **'Keep track of assignments and due dates.'**
  String get labelacc4f1dbd0;

  /// Interface label: Cyan
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get label567fd7776f;

  /// Interface label: Easy
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get label67bd2e990e;

  /// Interface label: All local records and your profile will be deleted permanently. Setup will reopen.
  ///
  /// In en, this message translates to:
  /// **'All local records and your profile will be deleted permanently. Setup will reopen.'**
  String get label2206359913;

  /// Interface label: Personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get labelaedf71a3b5;

  /// Interface label: Morning
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get label871e19f899;

  /// Interface label: Morning 🌅
  ///
  /// In en, this message translates to:
  /// **'Morning 🌅'**
  String get labela0092ad019;

  /// Interface label: Hard
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get label3c3ca997ea;

  /// Interface label: Plan four hours of mathematics study
  ///
  /// In en, this message translates to:
  /// **'Plan four hours of mathematics study'**
  String get labele4d549d8b8;

  /// Interface label: S
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get label67dd1cf4d8;

  /// Interface label: Early energy
  ///
  /// In en, this message translates to:
  /// **'Early energy'**
  String get label20b3762405;

  /// Interface label: ENote student
  ///
  /// In en, this message translates to:
  /// **'ENote student'**
  String get label42f9d7dd3a;

  /// Interface label: Meals
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get label3944fbff8c;

  /// Interface label: Request permission
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get label1cb6df5b0b;

  /// Interface label: Urgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get label0fac5b494f;

  /// Interface label: Urgent and important 🔴
  ///
  /// In en, this message translates to:
  /// **'Urgent and important 🔴'**
  String get labeld768c54e09;

  /// Interface label: Study habits and goals
  ///
  /// In en, this message translates to:
  /// **'Study habits and goals'**
  String get label6df4e67087;

  /// Interface label: General
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get label1785948751;

  /// Interface label: View details
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get label688478b29d;

  /// Interface label: View all
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get labeld36294e5ab;

  /// Interface label: View all tasks
  ///
  /// In en, this message translates to:
  /// **'View all tasks'**
  String get label692f26f23f;

  /// Interface label: File or book title
  ///
  /// In en, this message translates to:
  /// **'File or book title'**
  String get label8bb5dd6e7e;

  /// Interface label: Task title
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get labelacd5788daa;

  /// Interface label: Goal title
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get label78e6d86cae;

  /// Interface label: Open menu
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get label09e80f8b25;

  /// Interface label: Open folder
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get labelecf1101c09;

  /// Interface label: Open & edit
  ///
  /// In en, this message translates to:
  /// **'Open & edit'**
  String get label87562cc1d4;

  /// Interface label: Reading
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get labelc239328252;

  /// Interface label: Mark all as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get labela8217a8d30;

  /// Interface label: Textbook
  ///
  /// In en, this message translates to:
  /// **'Textbook'**
  String get labela2973604fe;

  /// Interface label: Practice quiz
  ///
  /// In en, this message translates to:
  /// **'Practice quiz'**
  String get labelf6ac956795;

  /// Interface label: Quizzes
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get labelce9c2c913f;

  /// Interface label: How can I use the Feynman technique to explain a difficult lesson?
  ///
  /// In en, this message translates to:
  /// **'How can I use the Feynman technique to explain a difficult lesson?'**
  String get label8d129a336a;

  /// Interface label: How can I organize Pomodoro sessions for demanding subjects?
  ///
  /// In en, this message translates to:
  /// **'How can I organize Pomodoro sessions for demanding subjects?'**
  String get label829e0bd9c7;

  /// Interface label: How do I earn experience points (XP)?
  ///
  /// In en, this message translates to:
  /// **'How do I earn experience points (XP)?'**
  String get labelc5f489ce86;

  /// Interface label: No study goals yet
  ///
  /// In en, this message translates to:
  /// **'No study goals yet'**
  String get label7b9f0ae614;

  /// Interface label: No notifications yet
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get labelb63dfe54db;

  /// Interface label: No habits yet
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get labele6f0d31a45;

  /// Interface label: No folders yet
  ///
  /// In en, this message translates to:
  /// **'No folders yet'**
  String get label36b81cdaa1;

  /// Interface label: No conversations in this section
  ///
  /// In en, this message translates to:
  /// **'No conversations in this section'**
  String get labelf0c4b21404;

  /// Interface label: Your notebook is empty.
  ///
  /// In en, this message translates to:
  /// **'Your notebook is empty.'**
  String get labele056af301c;

  /// Interface label: No tasks match the selected filter.
  ///
  /// In en, this message translates to:
  /// **'No tasks match the selected filter.'**
  String get labela6c181654c;

  /// Interface label: No matching tasks
  ///
  /// In en, this message translates to:
  /// **'No matching tasks'**
  String get label8280b0566c;

  /// Interface label: No matching results
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get label8d88b0583d;

  /// Interface label: No search results
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get labele9fc96d46d;

  /// Interface label: No homework yet
  ///
  /// In en, this message translates to:
  /// **'No homework yet'**
  String get label1d682b0f5f;

  /// Interface label: No pending homework 🎉
  ///
  /// In en, this message translates to:
  /// **'No pending homework 🎉'**
  String get labelbffcea26b6;

  /// Interface label: Move unfinished tasks from previous days into today's schedule.
  ///
  /// In en, this message translates to:
  /// **'Move unfinished tasks from previous days into today\'s schedule.'**
  String get labeld4cc8c9dec;

  /// Interface label: Start your day by adding one task and setting its priority.
  ///
  /// In en, this message translates to:
  /// **'Start your day by adding one task and setting its priority.'**
  String get labelc76c1dd108;

  /// Interface label: Notifications are not enabled on this device yet.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not enabled on this device yet.'**
  String get labelabac469fea;

  /// Interface label: Habit color
  ///
  /// In en, this message translates to:
  /// **'Habit color'**
  String get labeldb34c74349;

  /// Interface label: Folder Color
  ///
  /// In en, this message translates to:
  /// **'Folder Color'**
  String get labelba9a5a70e2;

  /// Interface label: Goal color
  ///
  /// In en, this message translates to:
  /// **'Goal color'**
  String get labele27138980b;

  /// Interface label: Circular Dial
  ///
  /// In en, this message translates to:
  /// **'Circular Dial'**
  String get label3e40b089ae;

  /// Interface label: Focus timer
  ///
  /// In en, this message translates to:
  /// **'Focus timer'**
  String get label4b3e9fa5a2;

  /// Interface label: Focus timer and alarm
  ///
  /// In en, this message translates to:
  /// **'Focus timer and alarm'**
  String get label7b906a637f;

  /// Interface label: Pomodoro timer
  ///
  /// In en, this message translates to:
  /// **'Pomodoro timer'**
  String get label4151ec4bf0;

  /// Interface label: Interactive flip timer
  ///
  /// In en, this message translates to:
  /// **'Interactive flip timer'**
  String get label83beab0bf9;

  /// Interface label: New subject
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get labelad20ffd9c6;

  /// Interface label: Keep editing
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get labelde68b96fa2;

  /// Interface label: Continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get label70fc837b66;

  /// Interface label: Habit tracker
  ///
  /// In en, this message translates to:
  /// **'Habit tracker'**
  String get labelb6485345d0;

  /// Interface label: Medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get label91fa23bdc1;

  /// Interface label: Paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get label5b23306afc;

  /// Interface label: For example: Alex Morgan
  ///
  /// In en, this message translates to:
  /// **'For example: Alex Morgan'**
  String get label4199b13158;

  /// Interface label: e.g. Finish 5 chemistry chapters
  ///
  /// In en, this message translates to:
  /// **'e.g. Finish 5 chemistry chapters'**
  String get label78511344e9;

  /// Interface label: For example: Biology and geology
  ///
  /// In en, this message translates to:
  /// **'For example: Biology and geology'**
  String get label2f1b39aa4f;

  /// Interface label: e.g. Read for 20 minutes
  ///
  /// In en, this message translates to:
  /// **'e.g. Read for 20 minutes'**
  String get label2e25135000;

  /// Interface label: For example: Complete pages 45 and 46
  ///
  /// In en, this message translates to:
  /// **'For example: Complete pages 45 and 46'**
  String get labelecba2e1028;

  /// Interface label: For example: Mathematics
  ///
  /// In en, this message translates to:
  /// **'For example: Mathematics'**
  String get labelf53e275ac2;

  /// Interface label: For example: Mathematics, biology, grammar, English…
  ///
  /// In en, this message translates to:
  /// **'For example: Mathematics, biology, grammar, English…'**
  String get label04603f0aea;

  /// Interface label: For example: Wave physics, organic chemistry…
  ///
  /// In en, this message translates to:
  /// **'For example: Wave physics, organic chemistry…'**
  String get labele99bcccbab;

  /// Interface label: For example: Modern physics — chapter one
  ///
  /// In en, this message translates to:
  /// **'For example: Modern physics — chapter one'**
  String get label8e6a795bfb;

  /// Interface label: e.g. Review physics chapter three
  ///
  /// In en, this message translates to:
  /// **'e.g. Review physics chapter three'**
  String get label602257483b;

  /// Interface label: Subject Folders
  ///
  /// In en, this message translates to:
  /// **'Subject Folders'**
  String get label886f4689ba;

  /// Interface label: School
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get label44ee4b4e2e;

  /// Interface label: Homework
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get label72f5aa4bf0;

  /// Interface label: Study session 📚
  ///
  /// In en, this message translates to:
  /// **'Study session 📚'**
  String get label22dd79192c;

  /// Interface label: Study notes
  ///
  /// In en, this message translates to:
  /// **'Study notes'**
  String get label5588426963;

  /// Interface label: Suggested study sessions:
  ///
  /// In en, this message translates to:
  /// **'Suggested study sessions:'**
  String get labele347a191c4;

  /// Interface label: Welcome to ENote
  ///
  /// In en, this message translates to:
  /// **'Welcome to ENote'**
  String get labela766af2149;

  /// Interface label: Notification center
  ///
  /// In en, this message translates to:
  /// **'Notification center'**
  String get labelf62cbfd887;

  /// Interface label: Evening
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get label4804f096ea;

  /// Interface label: Evening 🌙
  ///
  /// In en, this message translates to:
  /// **'Evening 🌙'**
  String get labelc5f89a1a8f;

  /// Interface label: Study assistant and rewards
  ///
  /// In en, this message translates to:
  /// **'Study assistant and rewards'**
  String get label9a67f666e6;

  /// Interface label: Difficulty:
  ///
  /// In en, this message translates to:
  /// **'Difficulty:'**
  String get label1e2d12cd3d;

  /// Interface label: Clear history
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get labela5967ab83e;

  /// Interface label: Clear all
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get label6a7442e269;

  /// Interface label: Reset all data
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get labelfc7726661c;

  /// Interface label: Clear notification history
  ///
  /// In en, this message translates to:
  /// **'Clear notification history'**
  String get label1f6c788785;

  /// Interface label: Delete permanently
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get label05db58dea6;

  /// Interface label: Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get label8d4efa9231;

  /// Interface label: Enabled
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get label723d0053b2;

  /// Interface label: Your idea library
  ///
  /// In en, this message translates to:
  /// **'Your idea library'**
  String get label5be2920627;

  /// Interface label: An organized reference library
  ///
  /// In en, this message translates to:
  /// **'An organized reference library'**
  String get label49304cdf56;

  /// Interface label: Your library starts with an idea
  ///
  /// In en, this message translates to:
  /// **'Your library starts with an idea'**
  String get labeldc2b264e54;

  /// Interface label: Completed ✅
  ///
  /// In en, this message translates to:
  /// **'Completed ✅'**
  String get label60f4db06c4;

  /// Interface label: Notes / description
  ///
  /// In en, this message translates to:
  /// **'Notes / description'**
  String get label163617e7b4;

  /// Interface label: Important notes about this file…
  ///
  /// In en, this message translates to:
  /// **'Important notes about this file…'**
  String get label6462f7d8ed;

  /// Interface label: Untitled note
  ///
  /// In en, this message translates to:
  /// **'Untitled note'**
  String get label11b7bd05ae;

  /// Interface label: New note
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get labelb1881eb305;

  /// Interface label: Revision summary
  ///
  /// In en, this message translates to:
  /// **'Revision summary'**
  String get label15c19b7233;

  /// Interface label: Keep useful summaries and ideas. Open a note to read or edit it.
  ///
  /// In en, this message translates to:
  /// **'Keep useful summaries and ideas. Open a note to read or edit it.'**
  String get label10f88ffecc;

  /// Interface label: PDF file
  ///
  /// In en, this message translates to:
  /// **'PDF file'**
  String get labele19e2de0e6;

  /// Interface label: Subject folders, reading progress and quick lecture links.
  ///
  /// In en, this message translates to:
  /// **'Subject folders, reading progress and quick lecture links.'**
  String get label599ff0e242;

  /// Interface label: Excellent! You have a strong understanding of these concepts.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You have a strong understanding of these concepts.'**
  String get label6d2bdbe820;

  /// Interface label: Danger zone
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get label3c62f15bb9;

  /// Interface label: One place for your study planner, focus timer and library.
  ///
  /// In en, this message translates to:
  /// **'One place for your study planner, focus timer and library.'**
  String get label3840526624;

  /// Interface label: Follow-up practice:
  ///
  /// In en, this message translates to:
  /// **'Follow-up practice:'**
  String get labela8a5bc6ef1;

  /// Interface label: Medium priority 🟡
  ///
  /// In en, this message translates to:
  /// **'Medium priority 🟡'**
  String get labelae88baca41;

  /// Interface label: New task
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get label940db99942;

  /// Interface label: Copy summary
  ///
  /// In en, this message translates to:
  /// **'Copy summary'**
  String get labeld58c5e3e1e;

  /// Interface label: Study tips:
  ///
  /// In en, this message translates to:
  /// **'Study tips:'**
  String get labelf6364c4add;

  /// Interface label: Practical ways to manage exam anxiety
  ///
  /// In en, this message translates to:
  /// **'Practical ways to manage exam anxiety'**
  String get label0f7ff327d3;

  /// Interface label: Plan tasks, set priorities and move unfinished work
  ///
  /// In en, this message translates to:
  /// **'Plan tasks, set priorities and move unfinished work'**
  String get labelf0a58ece2d;

  /// Interface label: This is a test notification from ENote.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification from ENote.'**
  String get labeleae7f982b4;

  /// Interface label: Earn rewards for steady study progress
  ///
  /// In en, this message translates to:
  /// **'Earn rewards for steady study progress'**
  String get label9a4ddd6a0c;

  /// Interface label: Track goals, progress and reminders
  ///
  /// In en, this message translates to:
  /// **'Track goals, progress and reminders'**
  String get labelf91b2a057a;

  /// Interface label: Quick revision points:
  ///
  /// In en, this message translates to:
  /// **'Quick revision points:'**
  String get label0de5fa048d;

  /// Interface label: Material type
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get labela095899ef6;

  /// Interface label: Sleep
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get labelef807a53df;

  /// Interface label: Daily focus target:
  ///
  /// In en, this message translates to:
  /// **'Daily focus target:'**
  String get label05e4edca5a;

  /// Interface label: Daily focus target:
  ///
  /// In en, this message translates to:
  /// **'Daily focus target:'**
  String get label9cd557906e;

  /// Interface label: New goal
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get label6aad1061ae;

  /// Interface label: Quiet, focused learning
  ///
  /// In en, this message translates to:
  /// **'Quiet, focused learning'**
  String get label55b226e012;

  /// Interface label: These are planned study times, rather than measured focus time.
  ///
  /// In en, this message translates to:
  /// **'These are planned study times, rather than measured focus time.'**
  String get labelc214fd0117;

  /// Interface label: Delete all data permanently and restart setup? This cannot be undone.
  ///
  /// In en, this message translates to:
  /// **'Delete all data permanently and restart setup? This cannot be undone.'**
  String get labeld19814bd0e;

  /// Interface label: Clear all previous notifications from your history?
  ///
  /// In en, this message translates to:
  /// **'Clear all previous notifications from your history?'**
  String get label291b4d8ee6;

  /// Interface label: Homework
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get label561006bf87;

  /// Interface label: Pink
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get label836d81cd5f;

  /// Interface label: End time
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get label9a138c0a0c;

  /// Interface label: End time must be after start time.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get label87c6d39f1b;

  /// Interface label: Start time
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get labelff4ce1add7;

  /// Interface label: Focus time
  ///
  /// In en, this message translates to:
  /// **'Focus time'**
  String get labelb0dd339f81;

  /// Interface label: Focus time (minutes)
  ///
  /// In en, this message translates to:
  /// **'Focus time (minutes)'**
  String get label920d9af502;

  /// Interface label: friend
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get label7eca13df80;

  /// Interface label: friend
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get label0ef6b8d03f;

  /// Interface label: Enter your name to continue.
  ///
  /// In en, this message translates to:
  /// **'Enter your name to continue.'**
  String get labelf5ea0c01bd;

  /// Interface label: Enter your name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get label107bf0dd88;

  /// Interface label: Choose your education level.
  ///
  /// In en, this message translates to:
  /// **'Choose your education level.'**
  String get label5a5df8828e;

  /// Interface label: A fresh start for your day
  ///
  /// In en, this message translates to:
  /// **'A fresh start for your day'**
  String get label2ac9ce07e3;

  /// Interface label: ⏰ Break finished!
  ///
  /// In en, this message translates to:
  /// **'⏰ Break finished!'**
  String get label41aaf92e8c;

  /// Interface label: 🎉 Well done! (+100 XP)
  ///
  /// In en, this message translates to:
  /// **'🎉 Well done! (+100 XP)'**
  String get label0c03f5a479;

  /// Interface label: 🔔 ENote test notification
  ///
  /// In en, this message translates to:
  /// **'🔔 ENote test notification'**
  String get label67cb01e45b;

  /// Study time available: {p0} hours
  ///
  /// In en, this message translates to:
  /// **'Study time available: {p0} hours'**
  String messagea5a66bd9f3(String p0);

  /// Questions: {p0}
  ///
  /// In en, this message translates to:
  /// **'Questions: {p0}'**
  String message6731cf5a72(String p0);

  /// Study plan ({p0} hours total)
  ///
  /// In en, this message translates to:
  /// **'Study plan ({p0} hours total)'**
  String message44326941d7(String p0);

  /// Quiz: {p0}
  ///
  /// In en, this message translates to:
  /// **'Quiz: {p0}'**
  String message16e923f5ae(String p0);

  /// Difficulty: {p0} · {p1} questions
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {p0} · {p1} questions'**
  String message4178437921(String p0, String p1);

  /// Score: {p0}/{p1}
  ///
  /// In en, this message translates to:
  /// **'Score: {p0}/{p1}'**
  String messageed951c324b(String p0, String p1);

  /// Question {p0}
  ///
  /// In en, this message translates to:
  /// **'Question {p0}'**
  String messageb8d204704d(String p0);

  /// Quiz complete: {p0}%!
  ///
  /// In en, this message translates to:
  /// **'Quiz complete: {p0}%!'**
  String message2c49b1d2f5(String p0);

  /// Study summary · {p0} minute read
  ///
  /// In en, this message translates to:
  /// **'Study summary · {p0} minute read'**
  String message5c10ff4a67(String p0);

  /// {p0} of {p1}
  ///
  /// In en, this message translates to:
  /// **'{p0} of {p1}'**
  String messagec991cdd692(String p0, String p1);

  /// Rewards ({p0} XP)
  ///
  /// In en, this message translates to:
  /// **'Rewards ({p0} XP)'**
  String message30abd8f96f(String p0);

  /// Level {p0} · {p1}
  ///
  /// In en, this message translates to:
  /// **'Level {p0} · {p1}'**
  String message34a64aeb49(String p0, String p1);

  /// 🔥 Streak: {p0} days
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak: {p0} days'**
  String message0b8b5f7fdc(String p0);

  /// 🏆 Badges: {p0} of {p1} unlocked
  ///
  /// In en, this message translates to:
  /// **'🏆 Badges: {p0} of {p1} unlocked'**
  String messagee8c8186e98(String p0, String p1);

  /// Target: {p0} | Current: {p1} • Due: {p2}
  ///
  /// In en, this message translates to:
  /// **'Target: {p0} | Current: {p1} • Due: {p2}'**
  String message0d5e44a09a(String p0, String p1, String p2);

  /// Pending ({p0})
  ///
  /// In en, this message translates to:
  /// **'Pending ({p0})'**
  String message48e253cc7a(String p0);

  /// Due: {p0}
  ///
  /// In en, this message translates to:
  /// **'Due: {p0}'**
  String messagedf894fb490(String p0);

  /// Completed ({p0})
  ///
  /// In en, this message translates to:
  /// **'Completed ({p0})'**
  String message9c2bab3499(String p0);

  /// Books and files: {p0}
  ///
  /// In en, this message translates to:
  /// **'Books and files: {p0}'**
  String messagec60ab2054f(String p0);

  /// Last page read in “{p0}”:
  ///
  /// In en, this message translates to:
  /// **'Last page read in “{p0}”:'**
  String messageee6fe30168(String p0);

  /// Reading progress: {p0} of {p1} pages
  ///
  /// In en, this message translates to:
  /// **'Reading progress: {p0} of {p1} pages'**
  String messageb531bc554d(String p0, String p1);

  /// New: {p0}
  ///
  /// In en, this message translates to:
  /// **'New: {p0}'**
  String messagea8ccbc2d66(String p0);

  /// Moved {p0} tasks to today. ⚡
  ///
  /// In en, this message translates to:
  /// **'Moved {p0} tasks to today. ⚡'**
  String message32dc4a31fd(String p0);

  /// Move unfinished tasks ({p0})
  ///
  /// In en, this message translates to:
  /// **'Move unfinished tasks ({p0})'**
  String message1c7f213a95(String p0);

  /// Level {p0}
  ///
  /// In en, this message translates to:
  /// **'Level {p0}'**
  String message70cec35d5a(String p0);

  /// {p0} XP until level {p1}
  ///
  /// In en, this message translates to:
  /// **'{p0} XP until level {p1}'**
  String messagee98e93f406(String p0, String p1);

  /// {p0}/{p1} unlocked
  ///
  /// In en, this message translates to:
  /// **'{p0}/{p1} unlocked'**
  String message7ae08743a2(String p0, String p1);

  /// Localized minutes count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutes(int count);

  /// Localized days count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String days(int count);

  /// Localized files count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String files(int count);

  /// Localized tasks count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String tasks(int count);

  /// Localized subjects count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subject} other{{count} subjects}}'**
  String subjects(int count);

  /// No description provided for @localWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ENote. These are local study templates, not a connected AI model. Create a study plan, practise study strategies, or extract lines from your notes.'**
  String get localWelcome;

  /// No description provided for @localPlanRequest.
  ///
  /// In en, this message translates to:
  /// **'Create a study plan for {subject} over {hours} hours.'**
  String localPlanRequest(String subject, String hours);

  /// No description provided for @localPlanReply.
  ///
  /// In en, this message translates to:
  /// **'Here is a local study template for {subject}. Adjust it to your syllabus.'**
  String localPlanReply(String subject);

  /// No description provided for @localQuizRequest.
  ///
  /// In en, this message translates to:
  /// **'Practise study strategies for {subject}.'**
  String localQuizRequest(String subject);

  /// No description provided for @localQuizReply.
  ///
  /// In en, this message translates to:
  /// **'This practice quiz covers study strategies. It does not assess your subject knowledge.'**
  String get localQuizReply;

  /// No description provided for @localNoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Extract review points from {title}.'**
  String localNoteRequest(String title);

  /// No description provided for @localNoteReply.
  ///
  /// In en, this message translates to:
  /// **'Here are selected lines from your notes. Review them against the original.'**
  String get localNoteReply;

  /// No description provided for @localNewChat.
  ///
  /// In en, this message translates to:
  /// **'New conversation. Choose a study template to begin.'**
  String get localNewChat;

  /// No description provided for @localSubject.
  ///
  /// In en, this message translates to:
  /// **'Your subject'**
  String get localSubject;

  /// No description provided for @localNote.
  ///
  /// In en, this message translates to:
  /// **'Study note'**
  String get localNote;

  /// No description provided for @localMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get localMedium;

  /// No description provided for @localOverview.
  ///
  /// In en, this message translates to:
  /// **'A flexible study template: understand, practise, recall, and review.'**
  String get localOverview;

  /// No description provided for @localUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand the key ideas'**
  String get localUnderstand;

  /// No description provided for @localUnderstandBody.
  ///
  /// In en, this message translates to:
  /// **'Choose one topic. Read a short section and identify the ideas you need to understand.'**
  String get localUnderstandBody;

  /// No description provided for @localPractise.
  ///
  /// In en, this message translates to:
  /// **'Practise with examples'**
  String get localPractise;

  /// No description provided for @localPractiseBody.
  ///
  /// In en, this message translates to:
  /// **'Work through examples on your own, then compare your steps with a reliable solution.'**
  String get localPractiseBody;

  /// No description provided for @localRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall without looking'**
  String get localRecall;

  /// No description provided for @localRecallBody.
  ///
  /// In en, this message translates to:
  /// **'Close your notes. Explain the topic in your own words and mark any gaps.'**
  String get localRecallBody;

  /// No description provided for @localReview.
  ///
  /// In en, this message translates to:
  /// **'Review and plan the next step'**
  String get localReview;

  /// No description provided for @localReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Check your mistakes and decide what to revisit in your next session.'**
  String get localReviewBody;

  /// No description provided for @localPlanTip.
  ///
  /// In en, this message translates to:
  /// **'Start with one manageable task and take breaks when needed.'**
  String get localPlanTip;

  /// No description provided for @localPomodoroTip.
  ///
  /// In en, this message translates to:
  /// **'Try 25 minutes of focus followed by a 5-minute break; adjust to your needs.'**
  String get localPomodoroTip;

  /// No description provided for @localRevision.
  ///
  /// In en, this message translates to:
  /// **'Revisit the material in a later session and test what you remember.'**
  String get localRevision;

  /// No description provided for @localStrategies.
  ///
  /// In en, this message translates to:
  /// **'Study strategies'**
  String get localStrategies;

  /// No description provided for @localQuizQ1.
  ///
  /// In en, this message translates to:
  /// **'Which activity lets you check what you remember?'**
  String get localQuizQ1;

  /// No description provided for @localQuizA1.
  ///
  /// In en, this message translates to:
  /// **'Recall the idea with your notes closed'**
  String get localQuizA1;

  /// No description provided for @localQuizB1.
  ///
  /// In en, this message translates to:
  /// **'Only reread the same paragraph'**
  String get localQuizB1;

  /// No description provided for @localQuizC1.
  ///
  /// In en, this message translates to:
  /// **'Skip every difficult topic'**
  String get localQuizC1;

  /// No description provided for @localQuizWhy1.
  ///
  /// In en, this message translates to:
  /// **'Recalling without looking reveals gaps that rereading can hide.'**
  String get localQuizWhy1;

  /// No description provided for @localQuizQ2.
  ///
  /// In en, this message translates to:
  /// **'What is a useful next step after making a mistake?'**
  String get localQuizQ2;

  /// No description provided for @localQuizA2.
  ///
  /// In en, this message translates to:
  /// **'Check the reasoning and try a similar example'**
  String get localQuizA2;

  /// No description provided for @localQuizB2.
  ///
  /// In en, this message translates to:
  /// **'Ignore the mistake'**
  String get localQuizB2;

  /// No description provided for @localQuizC2.
  ///
  /// In en, this message translates to:
  /// **'Memorise only the answer'**
  String get localQuizC2;

  /// No description provided for @localQuizWhy2.
  ///
  /// In en, this message translates to:
  /// **'Understanding the missed step helps you correct the method.'**
  String get localQuizWhy2;

  /// No description provided for @localQuizQ3.
  ///
  /// In en, this message translates to:
  /// **'How can you check whether your explanation is clear?'**
  String get localQuizQ3;

  /// No description provided for @localQuizA3.
  ///
  /// In en, this message translates to:
  /// **'Explain the idea simply in your own words'**
  String get localQuizA3;

  /// No description provided for @localQuizB3.
  ///
  /// In en, this message translates to:
  /// **'Copy a definition without understanding it'**
  String get localQuizB3;

  /// No description provided for @localQuizC3.
  ///
  /// In en, this message translates to:
  /// **'Use more jargon in every sentence'**
  String get localQuizC3;

  /// No description provided for @localQuizWhy3.
  ///
  /// In en, this message translates to:
  /// **'Explaining an idea simply can expose what you have not yet understood.'**
  String get localQuizWhy3;

  /// No description provided for @localNoteSummary.
  ///
  /// In en, this message translates to:
  /// **'Selected lines from your note; this is an extract, not an AI-generated summary.'**
  String get localNoteSummary;

  /// No description provided for @localNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Check the selected points against the original and add your own explanation.'**
  String get localNoteAction;

  /// No description provided for @localExamSupport.
  ///
  /// In en, this message translates to:
  /// **'Break your next study task into a small, manageable step. Take a pause when you need one, and ask a trusted person for support if worry is getting in the way.'**
  String get localExamSupport;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number between {min} and {max}.'**
  String validationInteger(String min, String max);

  /// No description provided for @validationTime.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time, such as 09:30.'**
  String get validationTime;

  /// No description provided for @validationDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid date in YYYY-MM-DD format.'**
  String get validationDate;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get activeSession;

  /// No description provided for @pausedSession.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedSession;

  /// No description provided for @accessibleTimer.
  ///
  /// In en, this message translates to:
  /// **'{mode}: {minutes} minutes and {seconds} seconds remaining.'**
  String accessibleTimer(String mode, String minutes, String seconds);

  /// No description provided for @label945de519f6.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get label945de519f6;

  /// No description provided for @label3021745a89.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get label3021745a89;

  /// No description provided for @label11076c4f66.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get label11076c4f66;

  /// No description provided for @label62c3bc6f61.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get label62c3bc6f61;

  /// No description provided for @label40add5d3e4.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get label40add5d3e4;

  /// No description provided for @labelf8b69a90e2.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get labelf8b69a90e2;

  /// No description provided for @label8d6a5d1bbd.
  ///
  /// In en, this message translates to:
  /// **'On your plan today'**
  String get label8d6a5d1bbd;

  /// No description provided for @labelb0404d47aa.
  ///
  /// In en, this message translates to:
  /// **'Closer to your goals'**
  String get labelb0404d47aa;

  /// No description provided for @label5a5af57b42.
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance Analytics'**
  String get label5a5af57b42;

  /// No description provided for @label40a5b383bd.
  ///
  /// In en, this message translates to:
  /// **'Your time deserves a good plan.'**
  String get label40a5b383bd;

  /// No description provided for @label009481fb62.
  ///
  /// In en, this message translates to:
  /// **'Start a focus session'**
  String get label009481fb62;

  /// No description provided for @label8dc921a995.
  ///
  /// In en, this message translates to:
  /// **'Today’s completed tasks'**
  String get label8dc921a995;

  /// No description provided for @label7d4a462dd1.
  ///
  /// In en, this message translates to:
  /// **'Recorded focus minutes'**
  String get label7d4a462dd1;

  /// No description provided for @labelbbd1d11263.
  ///
  /// In en, this message translates to:
  /// **'Goals in progress'**
  String get labelbbd1d11263;

  /// No description provided for @labelbf5148ef5b.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get labelbf5148ef5b;

  /// No description provided for @label0277b904ae.
  ///
  /// In en, this message translates to:
  /// **'Focus Master'**
  String get label0277b904ae;

  /// No description provided for @label913c73d22f.
  ///
  /// In en, this message translates to:
  /// **'Goal Hunter'**
  String get label913c73d22f;

  /// مرحبًا،
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get label47ffed7d09;

  /// يومك صفحة جديدة. ابدأ بمهمة واحدة.
  ///
  /// In en, this message translates to:
  /// **'Your day is a fresh page. Start with one task.'**
  String get label49e48fe128;

  /// أضف هدفك الأول وابدأ متابعة تقدّمك.
  ///
  /// In en, this message translates to:
  /// **'Add your first goal and start tracking your progress.'**
  String get labele53b4c8cec;

  /// سجل الجوائز
  ///
  /// In en, this message translates to:
  /// **'Rewards history'**
  String get labeld9f0a500e2;

  /// توزيع المهام المنجزة فعلياً خلال الأيام السبعة الأخيرة.
  ///
  /// In en, this message translates to:
  /// **'Tasks actually completed over the last seven days.'**
  String get labelb76be2f7f7;

  /// توزيع وقت المذاكرة المخطط اليوم
  ///
  /// In en, this message translates to:
  /// **'Planned study time distribution today'**
  String get label56e7da3baa;

  /// رتّب أولوياتك وابدأ بمهمة واحدة. خذ استراحة قصيرة بين جلسات التركيز.
  ///
  /// In en, this message translates to:
  /// **'Set your priorities and start with one task. Take a short break between focus sessions.'**
  String get labelcd239b96a6;

  /// خطط مذاكرة تفاعلية، كويزات فورية، وتلخيص ذكي لملاحظاتك الدراسية.
  ///
  /// In en, this message translates to:
  /// **'Interactive study plans, instant quizzes, and smart summaries of your study notes.'**
  String get label2bbfef15df;

  /// لا توجد واجبات معلقة. أحسنت!
  ///
  /// In en, this message translates to:
  /// **'No pending homework. Well done!'**
  String get label17a9410884;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
