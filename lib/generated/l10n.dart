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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
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
    return Intl.message('Language', name: 'language', desc: '', args: []);
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
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
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
    return Intl.message('Points', name: 'points', desc: '', args: []);
  }

  /// `Communities`
  String get communities {
    return Intl.message('Communities', name: 'communities', desc: '', args: []);
  }

  /// `Complaints`
  String get complaints {
    return Intl.message('Complaints', name: 'complaints', desc: '', args: []);
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
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
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
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Email`
  String get emailHint {
    return Intl.message('Email', name: 'emailHint', desc: '', args: []);
  }

  /// `Password`
  String get passwordHint {
    return Intl.message('Password', name: 'passwordHint', desc: '', args: []);
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
    return Intl.message('Remember me', name: 'rememberMe', desc: '', args: []);
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
    return Intl.message('Login', name: 'loginButton', desc: '', args: []);
  }

  /// `Logging in...`
  String get loggingIn {
    return Intl.message('Logging in...', name: 'loggingIn', desc: '', args: []);
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
    return Intl.message('Full name', name: 'fullNameHint', desc: '', args: []);
  }

  /// `Phone number`
  String get phoneHint {
    return Intl.message('Phone number', name: 'phoneHint', desc: '', args: []);
  }

  /// `Sign Up`
  String get signupButton {
    return Intl.message('Sign Up', name: 'signupButton', desc: '', args: []);
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
    return Intl.message('Sign in', name: 'signIn', desc: '', args: []);
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
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `statistics`
  String get statistics {
    return Intl.message('statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
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
    return Intl.message('Name', name: 'communityNameLabel', desc: '', args: []);
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
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
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
    return Intl.message('Issue Title', name: 'issueTitle', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Reported on`
  String get reportedOn {
    return Intl.message('Reported on', name: 'reportedOn', desc: '', args: []);
  }

  /// `NEW`
  String get statusNew {
    return Intl.message('NEW', name: 'statusNew', desc: '', args: []);
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
    return Intl.message('Resolved', name: 'statusResolved', desc: '', args: []);
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
    return Intl.message('Remove Vote', name: 'removeVote', desc: '', args: []);
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
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `ago`
  String get ago {
    return Intl.message('ago', name: 'ago', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Rewards`
  String get rewards {
    return Intl.message('Rewards', name: 'rewards', desc: '', args: []);
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
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message('In Progress', name: 'inProgress', desc: '', args: []);
  }

  /// `Resolved`
  String get resolved {
    return Intl.message('Resolved', name: 'resolved', desc: '', args: []);
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
    return Intl.message('Emergency', name: 'emergency', desc: '', args: []);
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `Progress`
  String get progress {
    return Intl.message('Progress', name: 'progress', desc: '', args: []);
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
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `votes`
  String get votes {
    return Intl.message('votes', name: 'votes', desc: '', args: []);
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

  /// `Your report makes the difference`
  String get homeSubtitle {
    return Intl.message(
      'Your report makes the difference',
      name: 'homeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Add New Complaint`
  String get addNewComplaint {
    return Intl.message(
      'Add New Complaint',
      name: 'addNewComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Upload a photo of the issue easily`
  String get uploadPhotoSubtitle {
    return Intl.message(
      'Upload a photo of the issue easily',
      name: 'uploadPhotoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Track Your Complaint`
  String get trackYourComplaint {
    return Intl.message(
      'Track Your Complaint',
      name: 'trackYourComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Follow the status of your report step by step`
  String get trackComplaintSubtitle {
    return Intl.message(
      'Follow the status of your report step by step',
      name: 'trackComplaintSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `My Complaints`
  String get myComplaints {
    return Intl.message(
      'My Complaints',
      name: 'myComplaints',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load complaints`
  String get failedToLoadComplaints {
    return Intl.message(
      'Failed to load complaints',
      name: 'failedToLoadComplaints',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `No complaints yet.`
  String get noComplaintsYet {
    return Intl.message(
      'No complaints yet.',
      name: 'noComplaintsYet',
      desc: '',
      args: [],
    );
  }

  /// `Submit an issue to see it listed here.`
  String get submitIssueHint {
    return Intl.message(
      'Submit an issue to see it listed here.',
      name: 'submitIssueHint',
      desc: '',
      args: [],
    );
  }

  /// `Report received`
  String get reportReceived {
    return Intl.message(
      'Report received',
      name: 'reportReceived',
      desc: '',
      args: [],
    );
  }

  /// `The report has been reviewed and classified`
  String get reportReviewedClassified {
    return Intl.message(
      'The report has been reviewed and classified',
      name: 'reportReviewedClassified',
      desc: '',
      args: [],
    );
  }

  /// `Our team has started working on solving the problem`
  String get teamStartedSolving {
    return Intl.message(
      'Our team has started working on solving the problem',
      name: 'teamStartedSolving',
      desc: '',
      args: [],
    );
  }

  /// `Fixed`
  String get fixed {
    return Intl.message('Fixed', name: 'fixed', desc: '', args: []);
  }

  /// `Report number`
  String get reportNumber {
    return Intl.message(
      'Report number',
      name: 'reportNumber',
      desc: '',
      args: [],
    );
  }

  /// `Submission date`
  String get submissionDate {
    return Intl.message(
      'Submission date',
      name: 'submissionDate',
      desc: '',
      args: [],
    );
  }

  /// `Report status`
  String get reportStatus {
    return Intl.message(
      'Report status',
      name: 'reportStatus',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get change {
    return Intl.message('Change', name: 'change', desc: '', args: []);
  }

  /// `Current location`
  String get currentLocation {
    return Intl.message(
      'Current location',
      name: 'currentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Please select a problem type`
  String get pleaseSelectProblemType {
    return Intl.message(
      'Please select a problem type',
      name: 'pleaseSelectProblemType',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a description`
  String get pleaseEnterDescription {
    return Intl.message(
      'Please enter a description',
      name: 'pleaseEnterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Please add at least one photo`
  String get pleaseAddPhoto {
    return Intl.message(
      'Please add at least one photo',
      name: 'pleaseAddPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for location to load`
  String get pleaseWaitLocationLoad {
    return Intl.message(
      'Please wait for location to load',
      name: 'pleaseWaitLocationLoad',
      desc: '',
      args: [],
    );
  }

  /// `Add a complaint`
  String get addComplaintTitle {
    return Intl.message(
      'Add a complaint',
      name: 'addComplaintTitle',
      desc: '',
      args: [],
    );
  }

  /// `Type of problem`
  String get typeOfProblem {
    return Intl.message(
      'Type of problem',
      name: 'typeOfProblem',
      desc: '',
      args: [],
    );
  }

  /// `Select the type of problem`
  String get selectProblemType {
    return Intl.message(
      'Select the type of problem',
      name: 'selectProblemType',
      desc: '',
      args: [],
    );
  }

  /// `Problem description`
  String get problemDescription {
    return Intl.message(
      'Problem description',
      name: 'problemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Write a description of the problem...`
  String get writeProblemDescription {
    return Intl.message(
      'Write a description of the problem...',
      name: 'writeProblemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add photos`
  String get addPhotos {
    return Intl.message('Add photos', name: 'addPhotos', desc: '', args: []);
  }

  /// `Click to add images`
  String get clickToAddImages {
    return Intl.message(
      'Click to add images',
      name: 'clickToAddImages',
      desc: '',
      args: [],
    );
  }

  /// `Attaching photos helps resolve the issue faster.`
  String get attachPhotosHint {
    return Intl.message(
      'Attaching photos helps resolve the issue faster.',
      name: 'attachPhotosHint',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Submitting...`
  String get submitting {
    return Intl.message(
      'Submitting...',
      name: 'submitting',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Failed to upload images. Please try again.`
  String get failedUploadImages {
    return Intl.message(
      'Failed to upload images. Please try again.',
      name: 'failedUploadImages',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save complaint. Please try again.`
  String get failedSaveComplaint {
    return Intl.message(
      'Failed to save complaint. Please try again.',
      name: 'failedSaveComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Uploading photos`
  String get uploadingPhotos {
    return Intl.message(
      'Uploading photos',
      name: 'uploadingPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Analysing with AI`
  String get analyzingWithAi {
    return Intl.message(
      'Analysing with AI',
      name: 'analyzingWithAi',
      desc: '',
      args: [],
    );
  }

  /// `Saving complaint`
  String get savingComplaint {
    return Intl.message(
      'Saving complaint',
      name: 'savingComplaint',
      desc: '',
      args: [],
    );
  }

  /// `Complaint Submitted! 🎉`
  String get complaintSubmittedSuccess {
    return Intl.message(
      'Complaint Submitted! 🎉',
      name: 'complaintSubmittedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Submitting your complaint...`
  String get submittingComplaint {
    return Intl.message(
      'Submitting your complaint...',
      name: 'submittingComplaint',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Your complaint has been recorded and will be reviewed shortly.`
  String get complaintRecordedReviewSoon {
    return Intl.message(
      'Your complaint has been recorded and will be reviewed shortly.',
      name: 'complaintRecordedReviewSoon',
      desc: '',
      args: [],
    );
  }

  /// `Complaint Management`
  String get complaintManagement {
    return Intl.message(
      'Complaint Management',
      name: 'complaintManagement',
      desc: '',
      args: [],
    );
  }

  /// `No complaints match the selected filters`
  String get noFilteredComplaints {
    return Intl.message(
      'No complaints match the selected filters',
      name: 'noFilteredComplaints',
      desc: '',
      args: [],
    );
  }

  /// `Priority: none`
  String get prioritySortNone {
    return Intl.message(
      'Priority: none',
      name: 'prioritySortNone',
      desc: '',
      args: [],
    );
  }

  /// `Priority: high to low`
  String get priorityHighToLow {
    return Intl.message(
      'Priority: high to low',
      name: 'priorityHighToLow',
      desc: '',
      args: [],
    );
  }

  /// `Priority: low to high`
  String get priorityLowToHigh {
    return Intl.message(
      'Priority: low to high',
      name: 'priorityLowToHigh',
      desc: '',
      args: [],
    );
  }

  /// `Not Issue`
  String get notIssue {
    return Intl.message('Not Issue', name: 'notIssue', desc: '', args: []);
  }

  /// `Complaint Details`
  String get complaintDetails {
    return Intl.message(
      'Complaint Details',
      name: 'complaintDetails',
      desc: '',
      args: [],
    );
  }

  /// `PRIORITY`
  String get priorityLabel {
    return Intl.message('PRIORITY', name: 'priorityLabel', desc: '', args: []);
  }

  /// `Description`
  String get descriptionLabel {
    return Intl.message(
      'Description',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Location & Address`
  String get locationAndAddress {
    return Intl.message(
      'Location & Address',
      name: 'locationAndAddress',
      desc: '',
      args: [],
    );
  }

  /// `AI Analysis`
  String get aiAnalysisTitle {
    return Intl.message(
      'AI Analysis',
      name: 'aiAnalysisTitle',
      desc: '',
      args: [],
    );
  }

  /// `Is Valid Issue?`
  String get isValidIssue {
    return Intl.message(
      'Is Valid Issue?',
      name: 'isValidIssue',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Confidence`
  String get confidence {
    return Intl.message('Confidence', name: 'confidence', desc: '', args: []);
  }

  /// `AI Summary:`
  String get aiSummary {
    return Intl.message('AI Summary:', name: 'aiSummary', desc: '', args: []);
  }

  /// `Metadata`
  String get metadata {
    return Intl.message('Metadata', name: 'metadata', desc: '', args: []);
  }

  /// `User ID`
  String get userIdLabel {
    return Intl.message('User ID', name: 'userIdLabel', desc: '', args: []);
  }

  /// `Likes`
  String get likes {
    return Intl.message('Likes', name: 'likes', desc: '', args: []);
  }

  /// `Last Updated`
  String get lastUpdated {
    return Intl.message(
      'Last Updated',
      name: 'lastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Update Status`
  String get updateStatus {
    return Intl.message(
      'Update Status',
      name: 'updateStatus',
      desc: '',
      args: [],
    );
  }

  /// `Status updated to`
  String get statusUpdatedTo {
    return Intl.message(
      'Status updated to',
      name: 'statusUpdatedTo',
      desc: '',
      args: [],
    );
  }

  /// `AI analysis failed. Please try again.`
  String get aiAnalysisFailed {
    return Intl.message(
      'AI analysis failed. Please try again.',
      name: 'aiAnalysisFailed',
      desc: '',
      args: [],
    );
  }

  /// `The AI determined the image is not a valid issue.`
  String get imageNotValidIssue {
    return Intl.message(
      'The AI determined the image is not a valid issue.',
      name: 'imageNotValidIssue',
      desc: '',
      args: [],
    );
  }

  /// `Report delay`
  String get reportDelay {
    return Intl.message(
      'Report delay',
      name: 'reportDelay',
      desc: '',
      args: [],
    );
  }

  /// `Add an optional message to admin...`
  String get feedbackOptionalMessage {
    return Intl.message(
      'Add an optional message to admin...',
      name: 'feedbackOptionalMessage',
      desc: '',
      args: [],
    );
  }

  /// `Feedback sent to admin`
  String get feedbackSent {
    return Intl.message(
      'Feedback sent to admin',
      name: 'feedbackSent',
      desc: '',
      args: [],
    );
  }

  /// `Feedback Inbox`
  String get feedbackInbox {
    return Intl.message(
      'Feedback Inbox',
      name: 'feedbackInbox',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `No feedback yet`
  String get noFeedbackYet {
    return Intl.message(
      'No feedback yet',
      name: 'noFeedbackYet',
      desc: '',
      args: [],
    );
  }

  /// `Complaint ID`
  String get complaintIdLabel {
    return Intl.message(
      'Complaint ID',
      name: 'complaintIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `No message provided`
  String get noMessageProvided {
    return Intl.message(
      'No message provided',
      name: 'noMessageProvided',
      desc: '',
      args: [],
    );
  }

  /// `Age (days)`
  String get complaintAgeDays {
    return Intl.message(
      'Age (days)',
      name: 'complaintAgeDays',
      desc: '',
      args: [],
    );
  }

  /// `Threshold (days)`
  String get thresholdDays {
    return Intl.message(
      'Threshold (days)',
      name: 'thresholdDays',
      desc: '',
      args: [],
    );
  }

  /// `URGENT`
  String get urgent {
    return Intl.message('URGENT', name: 'urgent', desc: '', args: []);
  }

  /// `Mark resolved`
  String get markResolved {
    return Intl.message(
      'Mark resolved',
      name: 'markResolved',
      desc: '',
      args: [],
    );
  }

  /// `Possible duplicate found`
  String get duplicatePotentialTitle {
    return Intl.message(
      'Possible duplicate found',
      name: 'duplicatePotentialTitle',
      desc: '',
      args: [],
    );
  }

  /// `A similar complaint appears to already exist nearby.`
  String get duplicatePotentialBody {
    return Intl.message(
      'A similar complaint appears to already exist nearby.',
      name: 'duplicatePotentialBody',
      desc: '',
      args: [],
    );
  }

  /// `Similarity`
  String get duplicateScoreLabel {
    return Intl.message(
      'Similarity',
      name: 'duplicateScoreLabel',
      desc: '',
      args: [],
    );
  }

  /// `Distance`
  String get duplicateDistanceLabel {
    return Intl.message(
      'Distance',
      name: 'duplicateDistanceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Submit anyway`
  String get submitAnyway {
    return Intl.message(
      'Submit anyway',
      name: 'submitAnyway',
      desc: '',
      args: [],
    );
  }

  /// `Join existing`
  String get joinExisting {
    return Intl.message(
      'Join existing',
      name: 'joinExisting',
      desc: '',
      args: [],
    );
  }

  /// `Mark as duplicate`
  String get markAsDuplicate {
    return Intl.message(
      'Mark as duplicate',
      name: 'markAsDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Complaint marked as duplicate`
  String get duplicateMarkedSuccess {
    return Intl.message(
      'Complaint marked as duplicate',
      name: 'duplicateMarkedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate clusters`
  String get duplicateClusters {
    return Intl.message(
      'Duplicate clusters',
      name: 'duplicateClusters',
      desc: '',
      args: [],
    );
  }

  /// `No duplicate clusters yet`
  String get noDuplicateClusters {
    return Intl.message(
      'No duplicate clusters yet',
      name: 'noDuplicateClusters',
      desc: '',
      args: [],
    );
  }

  /// `Cluster`
  String get clusterLabel {
    return Intl.message('Cluster', name: 'clusterLabel', desc: '', args: []);
  }

  /// `Items`
  String get clusterItemsCount {
    return Intl.message('Items', name: 'clusterItemsCount', desc: '', args: []);
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
