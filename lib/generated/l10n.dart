// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Edit Personal Info`
  String get editPersonalInfo {
    return Intl.message(
      'Edit Personal Info',
      name: 'editPersonalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `App Notifications`
  String get appNotifications {
    return Intl.message(
      'App Notifications',
      name: 'appNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Complaint Updates`
  String get complaintUpdates {
    return Intl.message(
      'Complaint Updates',
      name: 'complaintUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Community Updates`
  String get communityUpdates {
    return Intl.message(
      'Community Updates',
      name: 'communityUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `Logged out successfully`
  String get loggedOutSuccessfully {
    return Intl.message(
      'Logged out successfully',
      name: 'loggedOutSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Logout failed`
  String get logoutFailed {
    return Intl.message(
      'Logout failed',
      name: 'logoutFailed',
      desc: '',
      args: [],
    );
  }

  /// `Annette Black`
  String get defaultUserName {
    return Intl.message(
      'Annette Black',
      name: 'defaultUserName',
      desc: '',
      args: [],
    );
  }

  /// `dolores.chambers@example.com`
  String get defaultUserEmail {
    return Intl.message(
      'dolores.chambers@example.com',
      name: 'defaultUserEmail',
      desc: '',
      args: [],
    );
  }

  /// `Points`
  String get points {
    return Intl.message(
      'Points',
      name: 'points',
      desc: '',
      args: [],
    );
  }

  /// `Communities`
  String get communities {
    return Intl.message(
      'Communities',
      name: 'communities',
      desc: '',
      args: [],
    );
  }

  /// `Complaints`
  String get complaints {
    return Intl.message(
      'Complaints',
      name: 'complaints',
      desc: '',
      args: [],
    );
  }

  /// `Activity Log`
  String get activityLog {
    return Intl.message(
      'Activity Log',
      name: 'activityLog',
      desc: '',
      args: [],
    );
  }

  /// `Rewards Center`
  String get rewardsCenter {
    return Intl.message(
      'Rewards Center',
      name: 'rewardsCenter',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Logging out...`
  String get loggingOut {
    return Intl.message(
      'Logging out...',
      name: 'loggingOut',
      desc: '',
      args: [],
    );
  }

  /// `See, Snap, Improve`
  String get onboardTitle1 {
    return Intl.message(
      'See, Snap, Improve',
      name: 'onboardTitle1',
      desc: '',
      args: [],
    );
  }

  /// `With every glance, our streets get better. Report an issue and see it fixed.`
  String get onboardSubtitle1 {
    return Intl.message(
      'With every glance, our streets get better. Report an issue and see it fixed.',
      name: 'onboardSubtitle1',
      desc: '',
      args: [],
    );
  }

  /// `Report in Seconds`
  String get onboardTitle2 {
    return Intl.message(
      'Report in Seconds',
      name: 'onboardTitle2',
      desc: '',
      args: [],
    );
  }

  /// `It’s faster than you think. Snap a photo, add the location, and send your report in under 30 seconds.`
  String get onboardSubtitle2 {
    return Intl.message(
      'It’s faster than you think. Snap a photo, add the location, and send your report in under 30 seconds.',
      name: 'onboardSubtitle2',
      desc: '',
      args: [],
    );
  }

  /// `Follow the Progress`
  String get onboardTitle3 {
    return Intl.message(
      'Follow the Progress',
      name: 'onboardTitle3',
      desc: '',
      args: [],
    );
  }

  /// `Stay updated every step of the way. From new report to solved — see how Nazra turns issues into improvements.`
  String get onboardSubtitle3 {
    return Intl.message(
      'Stay updated every step of the way. From new report to solved — see how Nazra turns issues into improvements.',
      name: 'onboardSubtitle3',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailHint {
    return Intl.message(
      'Email',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordHint {
    return Intl.message(
      'Password',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPasswordHint {
    return Intl.message(
      'Confirm password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get rememberMe {
    return Intl.message(
      'Remember me',
      name: 'rememberMe',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Logging in...`
  String get loggingIn {
    return Intl.message(
      'Logging in...',
      name: 'loggingIn',
      desc: '',
      args: [],
    );
  }

  /// `Or continue with`
  String get orContinueWith {
    return Intl.message(
      'Or continue with',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create your Account`
  String get createYourAccount {
    return Intl.message(
      'Create your Account',
      name: 'createYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get fullNameHint {
    return Intl.message(
      'Full name',
      name: 'fullNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneHint {
    return Intl.message(
      'Phone number',
      name: 'phoneHint',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupButton {
    return Intl.message(
      'Sign Up',
      name: 'signupButton',
      desc: '',
      args: [],
    );
  }

  /// `Creating Account...`
  String get creatingAccount {
    return Intl.message(
      'Creating Account...',
      name: 'creatingAccount',
      desc: '',
      args: [],
    );
  }

  /// `Or sign up with`
  String get orSignupWith {
    return Intl.message(
      'Or sign up with',
      name: 'orSignupWith',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signIn {
    return Intl.message(
      'Sign in',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all required fields`
  String get pleaseFillAllFields {
    return Intl.message(
      'Please fill all required fields',
      name: 'pleaseFillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Account created successfully!`
  String get accountCreatedSuccess {
    return Intl.message(
      'Account created successfully!',
      name: 'accountCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Signup failed`
  String get signupFailed {
    return Intl.message(
      'Signup failed',
      name: 'signupFailed',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `statistics`
  String get statistics {
    return Intl.message(
      'statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Create First Community`
  String get createFirstCommunity {
    return Intl.message(
      'Create First Community',
      name: 'createFirstCommunity',
      desc: '',
      args: [],
    );
  }

  /// `Create Community`
  String get createCommunity {
    return Intl.message(
      'Create Community',
      name: 'createCommunity',
      desc: '',
      args: [],
    );
  }

  /// `No communities yet`
  String get noCommunitiesYet {
    return Intl.message(
      'No communities yet',
      name: 'noCommunitiesYet',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get communityNameLabel {
    return Intl.message(
      'Name',
      name: 'communityNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get communityDescLabel {
    return Intl.message(
      'Description',
      name: 'communityDescLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `User not logged in`
  String get userNotLoggedIn {
    return Intl.message(
      'User not logged in',
      name: 'userNotLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Issue Details`
  String get issueDetails {
    return Intl.message(
      'Issue Details',
      name: 'issueDetails',
      desc: '',
      args: [],
    );
  }

  /// `Issue Title`
  String get issueTitle {
    return Intl.message(
      'Issue Title',
      name: 'issueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Reported on`
  String get reportedOn {
    return Intl.message(
      'Reported on',
      name: 'reportedOn',
      desc: '',
      args: [],
    );
  }

  /// `NEW`
  String get statusNew {
    return Intl.message(
      'NEW',
      name: 'statusNew',
      desc: '',
      args: [],
    );
  }

  /// `Under review`
  String get statusUnderReview {
    return Intl.message(
      'Under review',
      name: 'statusUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `Escalated`
  String get statusEscalated {
    return Intl.message(
      'Escalated',
      name: 'statusEscalated',
      desc: '',
      args: [],
    );
  }

  /// `Resolved`
  String get statusResolved {
    return Intl.message(
      'Resolved',
      name: 'statusResolved',
      desc: '',
      args: [],
    );
  }

  /// `Issue reported`
  String get issueReported {
    return Intl.message(
      'Issue reported',
      name: 'issueReported',
      desc: '',
      args: [],
    );
  }

  /// `Pending review`
  String get pendingReview {
    return Intl.message(
      'Pending review',
      name: 'pendingReview',
      desc: '',
      args: [],
    );
  }

  /// `The issue is being reviewed by the community/admin`
  String get issueUnderReview {
    return Intl.message(
      'The issue is being reviewed by the community/admin',
      name: 'issueUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `Pending escalation`
  String get pendingEscalation {
    return Intl.message(
      'Pending escalation',
      name: 'pendingEscalation',
      desc: '',
      args: [],
    );
  }

  /// `The issue has been escalated to authorities`
  String get issueEscalated {
    return Intl.message(
      'The issue has been escalated to authorities',
      name: 'issueEscalated',
      desc: '',
      args: [],
    );
  }

  /// `Pending resolution`
  String get pendingResolution {
    return Intl.message(
      'Pending resolution',
      name: 'pendingResolution',
      desc: '',
      args: [],
    );
  }

  /// `The issue has been resolved`
  String get issueResolved {
    return Intl.message(
      'The issue has been resolved',
      name: 'issueResolved',
      desc: '',
      args: [],
    );
  }

  /// `Community Votes`
  String get communityVotes {
    return Intl.message(
      'Community Votes',
      name: 'communityVotes',
      desc: '',
      args: [],
    );
  }

  /// `Vote to escalate this issue`
  String get voteToEscalate {
    return Intl.message(
      'Vote to escalate this issue',
      name: 'voteToEscalate',
      desc: '',
      args: [],
    );
  }

  /// `Remove Vote`
  String get removeVote {
    return Intl.message(
      'Remove Vote',
      name: 'removeVote',
      desc: '',
      args: [],
    );
  }

  /// `Vote for Escalation`
  String get voteForEscalation {
    return Intl.message(
      'Vote for Escalation',
      name: 'voteForEscalation',
      desc: '',
      args: [],
    );
  }

  /// `Escalation Note`
  String get escalationNote {
    return Intl.message(
      'Escalation Note',
      name: 'escalationNote',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get markAllAsRead {
    return Intl.message(
      'Mark all as read',
      name: 'markAllAsRead',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet`
  String get noNotificationsYet {
    return Intl.message(
      'No notifications yet',
      name: 'noNotificationsYet',
      desc: '',
      args: [],
    );
  }

  /// `We will let you know when something happens`
  String get weWillLetYouKnow {
    return Intl.message(
      'We will let you know when something happens',
      name: 'weWillLetYouKnow',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message(
      'Just now',
      name: 'justNow',
      desc: '',
      args: [],
    );
  }

  /// `ago`
  String get ago {
    return Intl.message(
      'ago',
      name: 'ago',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Rewards`
  String get rewards {
    return Intl.message(
      'Rewards',
      name: 'rewards',
      desc: '',
      args: [],
    );
  }

  /// `No activities found`
  String get noActivitiesFound {
    return Intl.message(
      'No activities found',
      name: 'noActivitiesFound',
      desc: '',
      args: [],
    );
  }

  /// `Status Distribution`
  String get statusDistribution {
    return Intl.message(
      'Status Distribution',
      name: 'statusDistribution',
      desc: '',
      args: [],
    );
  }

  /// `Priority Distribution`
  String get priorityDistribution {
    return Intl.message(
      'Priority Distribution',
      name: 'priorityDistribution',
      desc: '',
      args: [],
    );
  }

  /// `Top Categories`
  String get topCategories {
    return Intl.message(
      'Top Categories',
      name: 'topCategories',
      desc: '',
      args: [],
    );
  }

  /// `Total Complaints`
  String get totalComplaints {
    return Intl.message(
      'Total Complaints',
      name: 'totalComplaints',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message(
      'In Progress',
      name: 'inProgress',
      desc: '',
      args: [],
    );
  }

  /// `Resolved`
  String get resolved {
    return Intl.message(
      'Resolved',
      name: 'resolved',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No categories yet`
  String get noCategoriesYet {
    return Intl.message(
      'No categories yet',
      name: 'noCategoriesYet',
      desc: '',
      args: [],
    );
  }

  /// `Emergency`
  String get emergency {
    return Intl.message(
      'Emergency',
      name: 'emergency',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get high {
    return Intl.message(
      'High',
      name: 'high',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get medium {
    return Intl.message(
      'Medium',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get low {
    return Intl.message(
      'Low',
      name: 'low',
      desc: '',
      args: [],
    );
  }

  /// `Progress`
  String get progress {
    return Intl.message(
      'Progress',
      name: 'progress',
      desc: '',
      args: [],
    );
  }

  /// `AI Confidence`
  String get aiConfidence {
    return Intl.message(
      'AI Confidence',
      name: 'aiConfidence',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `votes`
  String get votes {
    return Intl.message(
      'votes',
      name: 'votes',
      desc: '',
      args: [],
    );
  }

  /// `Tap to view details`
  String get tapToViewDetails {
    return Intl.message(
      'Tap to view details',
      name: 'tapToViewDetails',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
