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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Your Care Business'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @houseKeeping.
  ///
  /// In en, this message translates to:
  /// **'Hourly Cleaning'**
  String get houseKeeping;

  /// No description provided for @houseKeepingDescription.
  ///
  /// In en, this message translates to:
  /// **'Regular cleaning for your home with customizable options'**
  String get houseKeepingDescription;

  /// No description provided for @deepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get deepCleaning;

  /// No description provided for @deepCleaningDescription.
  ///
  /// In en, this message translates to:
  /// **'Our professionals will provide quality cleaning using equipment'**
  String get deepCleaningDescription;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchServices;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the app?'**
  String get exitConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @as_soon_as_possible.
  ///
  /// In en, this message translates to:
  /// **'As soon as possible'**
  String get as_soon_as_possible;

  /// No description provided for @expected_time.
  ///
  /// In en, this message translates to:
  /// **'ِExpected Time'**
  String get expected_time;

  /// No description provided for @deepCleaningRequest.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning Request'**
  String get deepCleaningRequest;

  /// No description provided for @propertyTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What type of property needs cleaning?'**
  String get propertyTypeQuestion;

  /// No description provided for @propertyTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the property type that best describes your space'**
  String get propertyTypeDescription;

  /// No description provided for @propertyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your property'**
  String get propertyDetailsTitle;

  /// No description provided for @propertyDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'These details help cleaning companies provide more accurate quotes'**
  String get propertyDetailsDescription;

  /// No description provided for @numberOfBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Bedrooms'**
  String get numberOfBedrooms;

  /// No description provided for @numberOfBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Bathrooms'**
  String get numberOfBathrooms;

  /// No description provided for @numberOfKitchens.
  ///
  /// In en, this message translates to:
  /// **'Number of Kitchens'**
  String get numberOfKitchens;

  /// No description provided for @numberOfLivingRooms.
  ///
  /// In en, this message translates to:
  /// **'Number of Living Rooms'**
  String get numberOfLivingRooms;

  /// No description provided for @numberOfFloors.
  ///
  /// In en, this message translates to:
  /// **'Number of floors'**
  String get numberOfFloors;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @additionalInformationHint.
  ///
  /// In en, this message translates to:
  /// **'Special instructions, specific areas that need attention, etc.'**
  String get additionalInformationHint;

  /// No description provided for @addPhotosVideos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos & Videos'**
  String get addPhotosVideos;

  /// No description provided for @photosVideosDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us understand your space better by uploading photos or videos'**
  String get photosVideosDescription;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @employee_availability.
  ///
  /// In en, this message translates to:
  /// **'Employee Availability'**
  String get employee_availability;

  /// No description provided for @company_availability.
  ///
  /// In en, this message translates to:
  /// **'Company Availability'**
  String get company_availability;

  /// No description provided for @select_employee.
  ///
  /// In en, this message translates to:
  /// **'Select Employee'**
  String get select_employee;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @total_cleaners_label.
  ///
  /// In en, this message translates to:
  /// **'Total Cleaners'**
  String get total_cleaners_label;

  /// No description provided for @day_of_week_label.
  ///
  /// In en, this message translates to:
  /// **'Day of Week'**
  String get day_of_week_label;

  /// No description provided for @start_hour_label.
  ///
  /// In en, this message translates to:
  /// **'Start Hour'**
  String get start_hour_label;

  /// No description provided for @end_hour_label.
  ///
  /// In en, this message translates to:
  /// **'End Hour'**
  String get end_hour_label;

  /// No description provided for @add_availability_title.
  ///
  /// In en, this message translates to:
  /// **'Add Availability'**
  String get add_availability_title;

  /// No description provided for @edit_availability_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Availability'**
  String get edit_availability_title;

  /// No description provided for @delete_availability_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Availability'**
  String get delete_availability_title;

  /// No description provided for @delete_availability_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this availability slot?'**
  String get delete_availability_message;

  /// No description provided for @no_availability.
  ///
  /// In en, this message translates to:
  /// **'No availability'**
  String get no_availability;

  /// No description provided for @invalid_time_range.
  ///
  /// In en, this message translates to:
  /// **'End hour must be after start hour'**
  String get invalid_time_range;

  /// No description provided for @invalid_total_cleaners.
  ///
  /// In en, this message translates to:
  /// **'Total cleaners must be greater than 0'**
  String get invalid_total_cleaners;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @annually.
  ///
  /// In en, this message translates to:
  /// **'Annually'**
  String get annually;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filters;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @employee_calendar.
  ///
  /// In en, this message translates to:
  /// **'Employee Calendar'**
  String get employee_calendar;

  /// No description provided for @employee_id.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employee_id;

  /// No description provided for @team_id.
  ///
  /// In en, this message translates to:
  /// **'Team ID'**
  String get team_id;

  /// No description provided for @request_type.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get request_type;

  /// No description provided for @request_status.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get request_status;

  /// No description provided for @request_types.
  ///
  /// In en, this message translates to:
  /// **'Request Types'**
  String get request_types;

  /// No description provided for @total_works_label.
  ///
  /// In en, this message translates to:
  /// **'Total Works'**
  String get total_works_label;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @employee_summary.
  ///
  /// In en, this message translates to:
  /// **'Employee Summary'**
  String get employee_summary;

  /// No description provided for @team_summary.
  ///
  /// In en, this message translates to:
  /// **'Team Summary'**
  String get team_summary;

  /// No description provided for @assigned_to.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assigned_to;

  /// No description provided for @no_calendar_data.
  ///
  /// In en, this message translates to:
  /// **'No calendar data'**
  String get no_calendar_data;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @schedule_conflict_title.
  ///
  /// In en, this message translates to:
  /// **'Schedule conflict'**
  String get schedule_conflict_title;

  /// No description provided for @schedule_conflict_message.
  ///
  /// In en, this message translates to:
  /// **'This worker already has a job at this time.'**
  String get schedule_conflict_message;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @period_type.
  ///
  /// In en, this message translates to:
  /// **'Period Type'**
  String get period_type;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get start_date;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get end_date;

  /// No description provided for @noMediaSelected.
  ///
  /// In en, this message translates to:
  /// **'No media selected yet'**
  String get noMediaSelected;

  /// No description provided for @scheduleDeepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Schedule Your Deep Cleaning'**
  String get scheduleDeepCleaning;

  /// No description provided for @scheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a date, time, and address for your deep cleaning service'**
  String get scheduleDescription;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @serviceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get serviceAddress;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @mediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get mediaFiles;

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled For'**
  String get scheduledFor;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found.'**
  String get noAddressesFound;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @cleaningRequestCreated.
  ///
  /// In en, this message translates to:
  /// **'Cleaning request created!'**
  String get cleaningRequestCreated;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No Address'**
  String get noAddress;

  /// No description provided for @failedToLoadAddresses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load addresses'**
  String get failedToLoadAddresses;

  /// No description provided for @request_card_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get request_card_total;

  /// No description provided for @request_card_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get request_card_property_type;

  /// No description provided for @request_card_bedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get request_card_bedroom;

  /// No description provided for @request_card_kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchens'**
  String get request_card_kitchen;

  /// No description provided for @request_card_livingroom.
  ///
  /// In en, this message translates to:
  /// **'Livingrooms'**
  String get request_card_livingroom;

  /// No description provided for @request_card_bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get request_card_bathroom;

  /// No description provided for @request_card_notes.
  ///
  /// In en, this message translates to:
  /// **'Special Notes'**
  String get request_card_notes;

  /// No description provided for @request_card_media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get request_card_media;

  /// No description provided for @request_card_cleaners.
  ///
  /// In en, this message translates to:
  /// **'Cleaners'**
  String get request_card_cleaners;

  /// No description provided for @request_card_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get request_card_duration;

  /// No description provided for @request_card_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get request_card_products;

  /// No description provided for @request_card_schedule.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get request_card_schedule;

  /// No description provided for @no_requests.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get no_requests;

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get view_profile;

  /// No description provided for @map_select_location.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get map_select_location;

  /// No description provided for @login_login_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get login_login_to_continue;

  /// No description provided for @login_email.
  ///
  /// In en, this message translates to:
  /// **'ِEmail'**
  String get login_email;

  /// No description provided for @login_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password;

  /// No description provided for @login_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get login_forgot_password;

  /// No description provided for @login_login_label.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_login_label;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_account;

  /// No description provided for @login_apply_to_become_provider.
  ///
  /// In en, this message translates to:
  /// **'Apply to Become a Provider'**
  String get login_apply_to_become_provider;

  /// No description provided for @login_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get login_signup;

  /// No description provided for @signup_accept_terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms and Conditions'**
  String get signup_accept_terms_conditions;

  /// No description provided for @signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signup_title;

  /// No description provided for @signup_create_account_button.
  ///
  /// In en, this message translates to:
  /// **'Create the account'**
  String get signup_create_account_button;

  /// No description provided for @signup_join_yourcare.
  ///
  /// In en, this message translates to:
  /// **'Join Your Care'**
  String get signup_join_yourcare;

  /// No description provided for @signup_fill_information.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to create an account'**
  String get signup_fill_information;

  /// No description provided for @signup_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signup_name;

  /// No description provided for @signup_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signup_email;

  /// No description provided for @signup_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get signup_phone;

  /// No description provided for @signup_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signup_password;

  /// No description provided for @signup_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signup_confirm_password;

  /// No description provided for @signup_confirm_password_error.
  ///
  /// In en, this message translates to:
  /// **'Please Confirm Password'**
  String get signup_confirm_password_error;

  /// No description provided for @signup_confirm_password_no_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords Do Not Match!'**
  String get signup_confirm_password_no_match;

  /// No description provided for @signup_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get signup_agree;

  /// No description provided for @signup_terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get signup_terms_and_conditions;

  /// No description provided for @signup_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already Have an Account?'**
  String get signup_already_have_account;

  /// No description provided for @home_what_main_text.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get home_what_main_text;

  /// No description provided for @home_house_keeping_description.
  ///
  /// In en, this message translates to:
  /// **'ٍRegular House Keeping'**
  String get home_house_keeping_description;

  /// No description provided for @home_deep_cleaning_description.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning For New Houses'**
  String get home_deep_cleaning_description;

  /// No description provided for @address_edit_address.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get address_edit_address;

  /// No description provided for @profile_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit_profile;

  /// No description provided for @address_create_new_address.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get address_create_new_address;

  /// No description provided for @address_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get address_property_type;

  /// No description provided for @address_type_house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get address_type_house;

  /// No description provided for @address_type_office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get address_type_office;

  /// No description provided for @address_type_apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get address_type_apartment;

  /// No description provided for @address_name.
  ///
  /// In en, this message translates to:
  /// **'Address Name'**
  String get address_name;

  /// No description provided for @address_choose_area.
  ///
  /// In en, this message translates to:
  /// **'Select Area'**
  String get address_choose_area;

  /// No description provided for @address_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get address_block;

  /// No description provided for @address_street.
  ///
  /// In en, this message translates to:
  /// **'street'**
  String get address_street;

  /// No description provided for @address_avenue.
  ///
  /// In en, this message translates to:
  /// **'Avenue'**
  String get address_avenue;

  /// No description provided for @address_delete_address.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get address_delete_address;

  /// No description provided for @address_deleted.
  ///
  /// In en, this message translates to:
  /// **'Address Deleted'**
  String get address_deleted;

  /// No description provided for @address_add_address.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get address_add_address;

  /// No description provided for @address_added.
  ///
  /// In en, this message translates to:
  /// **'Address Added'**
  String get address_added;

  /// No description provided for @address_my_addresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get address_my_addresses;

  /// No description provided for @address_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get address_default;

  /// No description provided for @address_no_saved_address.
  ///
  /// In en, this message translates to:
  /// **'You have no saved addresses yet'**
  String get address_no_saved_address;

  /// No description provided for @address_delete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete address?'**
  String get address_delete_confirmation;

  /// No description provided for @address_building.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get address_building;

  /// No description provided for @address_floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get address_floor;

  /// No description provided for @address_apartment_number.
  ///
  /// In en, this message translates to:
  /// **'Apartment Number'**
  String get address_apartment_number;

  /// No description provided for @address_office_number.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get address_office_number;

  /// No description provided for @address_set_default.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get address_set_default;

  /// No description provided for @address_update.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get address_update;

  /// No description provided for @address_save.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get address_save;

  /// No description provided for @bids_bottom_sheet_bid.
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get bids_bottom_sheet_bid;

  /// No description provided for @bids_bottom_sheet_offered.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get bids_bottom_sheet_offered;

  /// No description provided for @bids_bottom_sheet_customer_info.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get bids_bottom_sheet_customer_info;

  /// No description provided for @bids_bottom_sheet_customer_info_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get bids_bottom_sheet_customer_info_email;

  /// No description provided for @bids_bottom_sheet_company_info.
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get bids_bottom_sheet_company_info;

  /// No description provided for @bids_bottom_sheet_company_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get bids_bottom_sheet_company_address;

  /// No description provided for @bids_bottom_sheet_company_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get bids_bottom_sheet_company_phone;

  /// No description provided for @bids_bottom_sheet_company_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get bids_bottom_sheet_company_email;

  /// No description provided for @bids_bottom_sheet_company_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get bids_bottom_sheet_company_website;

  /// No description provided for @request_accept_bid.
  ///
  /// In en, this message translates to:
  /// **'Accept Bid'**
  String get request_accept_bid;

  /// No description provided for @request_details_label.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get request_details_label;

  /// No description provided for @request_company.
  ///
  /// In en, this message translates to:
  /// **'Confirmed By'**
  String get request_company;

  /// No description provided for @request_bids_received.
  ///
  /// In en, this message translates to:
  /// **'Received Bids'**
  String get request_bids_received;

  /// No description provided for @request_incoming_bids_show_here.
  ///
  /// In en, this message translates to:
  /// **'received bids will show here'**
  String get request_incoming_bids_show_here;

  /// No description provided for @request_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get request_location;

  /// No description provided for @request_full_location.
  ///
  /// In en, this message translates to:
  /// **'Full Location'**
  String get request_full_location;

  /// No description provided for @request_date_time.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get request_date_time;

  /// No description provided for @request_property_details.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get request_property_details;

  /// No description provided for @request_request_id.
  ///
  /// In en, this message translates to:
  /// **'Request #'**
  String get request_request_id;

  /// No description provided for @request_assigned_cleaners.
  ///
  /// In en, this message translates to:
  /// **'Assigned Cleaners'**
  String get request_assigned_cleaners;

  /// No description provided for @request_cancel_request.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get request_cancel_request;

  /// No description provided for @request_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get request_contact_support;

  /// No description provided for @requests_my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get requests_my_requests;

  /// No description provided for @requests_all_requests.
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get requests_all_requests;

  /// No description provided for @requests_house_keeping.
  ///
  /// In en, this message translates to:
  /// **'House Keeping'**
  String get requests_house_keeping;

  /// No description provided for @requests_deep_cleaning.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get requests_deep_cleaning;

  /// No description provided for @requests_no_requests.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get requests_no_requests;

  /// No description provided for @requests_summary.
  ///
  /// In en, this message translates to:
  /// **'Request Summary'**
  String get requests_summary;

  /// No description provided for @house_keeping_title.
  ///
  /// In en, this message translates to:
  /// **'House Keeping'**
  String get house_keeping_title;

  /// No description provided for @requests_number_of_cleaners.
  ///
  /// In en, this message translates to:
  /// **'Choose number of cleaners'**
  String get requests_number_of_cleaners;

  /// No description provided for @requests_duration.
  ///
  /// In en, this message translates to:
  /// **'Choose number of hours'**
  String get requests_duration;

  /// No description provided for @requests_cleaning_product_title.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Products'**
  String get requests_cleaning_product_title;

  /// No description provided for @requests_cleaning_products_description.
  ///
  /// In en, this message translates to:
  /// **'Would you like us to bring our own cleaning products?'**
  String get requests_cleaning_products_description;

  /// No description provided for @general_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get general_cancel;

  /// No description provided for @general_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get general_delete;

  /// No description provided for @general_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get general_close;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @personal_information_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information_title;

  /// No description provided for @request_id.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get request_id;

  /// No description provided for @request_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get request_price;

  /// No description provided for @housekeeping_configuration.
  ///
  /// In en, this message translates to:
  /// **'Housekeeping Pricing'**
  String get housekeeping_configuration;

  /// No description provided for @housekeeping_pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get housekeeping_pricing;

  /// No description provided for @housekeeping_area_fees.
  ///
  /// In en, this message translates to:
  /// **'Area Fees'**
  String get housekeeping_area_fees;

  /// No description provided for @house_keeping_configuration.
  ///
  /// In en, this message translates to:
  /// **'House Keeping Configuration'**
  String get house_keeping_configuration;

  /// No description provided for @auto_bidding.
  ///
  /// In en, this message translates to:
  /// **'Auto Bidding'**
  String get auto_bidding;

  /// No description provided for @auto_bidding_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Auto Bidding'**
  String get auto_bidding_enabled;

  /// No description provided for @save_auto_bidding.
  ///
  /// In en, this message translates to:
  /// **'Save Auto Bidding'**
  String get save_auto_bidding;

  /// No description provided for @expected_time_days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get expected_time_days;

  /// No description provided for @department_types.
  ///
  /// In en, this message translates to:
  /// **'Department Types'**
  String get department_types;

  /// No description provided for @number_of_floors.
  ///
  /// In en, this message translates to:
  /// **'Number of Floors'**
  String get number_of_floors;

  /// No description provided for @size_options.
  ///
  /// In en, this message translates to:
  /// **'Size Options'**
  String get size_options;

  /// No description provided for @no_pricing_options.
  ///
  /// In en, this message translates to:
  /// **'No pricing options available'**
  String get no_pricing_options;

  /// No description provided for @base_price_per_cleaner_per_hour.
  ///
  /// In en, this message translates to:
  /// **'Base price per cleaner per hour'**
  String get base_price_per_cleaner_per_hour;

  /// No description provided for @single_pricing_model.
  ///
  /// In en, this message translates to:
  /// **'Single Pricing Model'**
  String get single_pricing_model;

  /// No description provided for @multiple_pricing_model.
  ///
  /// In en, this message translates to:
  /// **'Multiple Pricing Model'**
  String get multiple_pricing_model;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @cleaning_products_price.
  ///
  /// In en, this message translates to:
  /// **'Cleaning products price'**
  String get cleaning_products_price;

  /// No description provided for @price_must_be_greater_than_zero.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than zero'**
  String get price_must_be_greater_than_zero;

  /// No description provided for @housekeeping_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get housekeeping_active;

  /// No description provided for @account_delete_request.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion'**
  String get account_delete_request;

  /// No description provided for @account_delete_request_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens a secure web form'**
  String get account_delete_request_subtitle;

  /// No description provided for @force_update_title.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get force_update_title;

  /// No description provided for @force_update_message.
  ///
  /// In en, this message translates to:
  /// **'A newer version of the app is required to continue.'**
  String get force_update_message;

  /// No description provided for @force_update_minimum_label.
  ///
  /// In en, this message translates to:
  /// **'Minimum required version'**
  String get force_update_minimum_label;

  /// No description provided for @force_update_close_app.
  ///
  /// In en, this message translates to:
  /// **'Close App'**
  String get force_update_close_app;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get update_now;

  /// No description provided for @update_available_message.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available. Update now for the best experience.'**
  String get update_available_message;

  /// No description provided for @save_pricing.
  ///
  /// In en, this message translates to:
  /// **'Save Pricing'**
  String get save_pricing;

  /// No description provided for @no_areas_available.
  ///
  /// In en, this message translates to:
  /// **'No areas available'**
  String get no_areas_available;

  /// No description provided for @request_products_included.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Products Included'**
  String get request_products_included;

  /// No description provided for @request_products_not_included.
  ///
  /// In en, this message translates to:
  /// **'No Cleaning Products Included'**
  String get request_products_not_included;

  /// No description provided for @request_accept_job.
  ///
  /// In en, this message translates to:
  /// **'Accept Job'**
  String get request_accept_job;

  /// No description provided for @submit_bit.
  ///
  /// In en, this message translates to:
  /// **'Submit Bid'**
  String get submit_bit;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role: '**
  String get role;

  /// No description provided for @your_care_business.
  ///
  /// In en, this message translates to:
  /// **'Your Care Business'**
  String get your_care_business;

  /// No description provided for @upcoming_jobs.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Jobs'**
  String get upcoming_jobs;

  /// No description provided for @cleaning_requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get cleaning_requests;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @staff_management.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get staff_management;

  /// No description provided for @user_management.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get user_management;

  /// No description provided for @team_management.
  ///
  /// In en, this message translates to:
  /// **'Team Management'**
  String get team_management;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'requests'**
  String get requests;

  /// No description provided for @job_details.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get job_details;

  /// No description provided for @assigned_team.
  ///
  /// In en, this message translates to:
  /// **'Assigned Team'**
  String get assigned_team;

  /// No description provided for @no_team_assigned.
  ///
  /// In en, this message translates to:
  /// **'No team assigned yet'**
  String get no_team_assigned;

  /// No description provided for @start_job.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get start_job;

  /// No description provided for @general_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get general_save;

  /// No description provided for @complete_job.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get complete_job;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @inprogress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inprogress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get profile_title;

  /// No description provided for @business_description.
  ///
  /// In en, this message translates to:
  /// **'Company Description'**
  String get business_description;

  /// No description provided for @business_service_area.
  ///
  /// In en, this message translates to:
  /// **'Service Areas'**
  String get business_service_area;

  /// No description provided for @business_gallery.
  ///
  /// In en, this message translates to:
  /// **'Company Image Gallery'**
  String get business_gallery;

  /// No description provided for @business_name.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get business_name;

  /// No description provided for @business_address.
  ///
  /// In en, this message translates to:
  /// **'Company\'s Address'**
  String get business_address;

  /// No description provided for @business_phone.
  ///
  /// In en, this message translates to:
  /// **'Company\'s Number'**
  String get business_phone;

  /// No description provided for @business_website.
  ///
  /// In en, this message translates to:
  /// **'Company\'s Website'**
  String get business_website;

  /// No description provided for @business_email.
  ///
  /// In en, this message translates to:
  /// **'Company\'s Email'**
  String get business_email;

  /// No description provided for @service_descriptions.
  ///
  /// In en, this message translates to:
  /// **'Service Descriptions'**
  String get service_descriptions;

  /// No description provided for @covered_services_section_title.
  ///
  /// In en, this message translates to:
  /// **'Covered Service Items'**
  String get covered_services_section_title;

  /// No description provided for @covered_services_add_custom.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Service'**
  String get covered_services_add_custom;

  /// No description provided for @covered_services_edit_custom.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get covered_services_edit_custom;

  /// No description provided for @covered_services_delete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service?'**
  String get covered_services_delete_confirmation;

  /// No description provided for @covered_services_title_en.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get covered_services_title_en;

  /// No description provided for @covered_services_title_ar.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get covered_services_title_ar;

  /// No description provided for @form_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get form_required;

  /// No description provided for @deep_cleaning_description.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning Description'**
  String get deep_cleaning_description;

  /// No description provided for @house_cleaning_description.
  ///
  /// In en, this message translates to:
  /// **'House Cleaning Description'**
  String get house_cleaning_description;

  /// No description provided for @upholstery_cleaning_description.
  ///
  /// In en, this message translates to:
  /// **'Upholstery Cleaning Description'**
  String get upholstery_cleaning_description;

  /// No description provided for @enter_bid.
  ///
  /// In en, this message translates to:
  /// **'Enter your bid'**
  String get enter_bid;

  /// No description provided for @enter_timeline.
  ///
  /// In en, this message translates to:
  /// **'Expected timeline'**
  String get enter_timeline;

  /// No description provided for @enter_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get enter_note;

  /// No description provided for @submit_bid.
  ///
  /// In en, this message translates to:
  /// **'Submit Bid'**
  String get submit_bid;

  /// No description provided for @bid_submitted.
  ///
  /// In en, this message translates to:
  /// **'Bid Submitted'**
  String get bid_submitted;

  /// No description provided for @navigate_back_to_requests.
  ///
  /// In en, this message translates to:
  /// **'Back to Requests'**
  String get navigate_back_to_requests;

  /// No description provided for @cleaner.
  ///
  /// In en, this message translates to:
  /// **'Cleaner'**
  String get cleaner;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @select_cleaners.
  ///
  /// In en, this message translates to:
  /// **'Select Cleaners'**
  String get select_cleaners;

  /// No description provided for @job_accepted.
  ///
  /// In en, this message translates to:
  /// **'Job Accepted'**
  String get job_accepted;

  /// No description provided for @create_user_title.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get create_user_title;

  /// No description provided for @user_created.
  ///
  /// In en, this message translates to:
  /// **'User Created Successfully'**
  String get user_created;

  /// No description provided for @user_photo.
  ///
  /// In en, this message translates to:
  /// **'User Photo'**
  String get user_photo;

  /// No description provided for @save_user.
  ///
  /// In en, this message translates to:
  /// **'Save User'**
  String get save_user;

  /// No description provided for @edit_team.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get edit_team;

  /// No description provided for @new_team.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get new_team;

  /// No description provided for @team_name.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get team_name;

  /// No description provided for @select_team_members.
  ///
  /// In en, this message translates to:
  /// **'Select Team Member'**
  String get select_team_members;

  /// No description provided for @general_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get general_save_changes;

  /// No description provided for @create_team.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get create_team;

  /// No description provided for @create_user.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get create_user;

  /// No description provided for @staff_title.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff_title;

  /// No description provided for @team_label.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get team_label;

  /// No description provided for @no_teams_available.
  ///
  /// In en, this message translates to:
  /// **'No Teams Available'**
  String get no_teams_available;

  /// No description provided for @user_info_permission.
  ///
  /// In en, this message translates to:
  /// **'User & Permission Management'**
  String get user_info_permission;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @total_requests_label.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get total_requests_label;

  /// No description provided for @total_revenue_label.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get total_revenue_label;

  /// No description provided for @average_requests_label.
  ///
  /// In en, this message translates to:
  /// **'Avg / Request'**
  String get average_requests_label;

  /// No description provided for @statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics_title;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} day} other {{n} days}}'**
  String days(int n);

  /// No description provided for @upholstery_cleaning.
  ///
  /// In en, this message translates to:
  /// **'Furniture Cleaning'**
  String get upholstery_cleaning;

  /// No description provided for @upholstery_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get upholstery_details;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @exclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get exclusive;

  /// No description provided for @furniture_included.
  ///
  /// In en, this message translates to:
  /// **'Property has furniture'**
  String get furniture_included;

  /// No description provided for @company_profile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get company_profile;

  /// No description provided for @job_completed.
  ///
  /// In en, this message translates to:
  /// **'Job completed successfully'**
  String get job_completed;

  /// No description provided for @number_of_visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get number_of_visits;

  /// No description provided for @weekly_availability_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly Availability'**
  String get weekly_availability_title;

  /// No description provided for @fixed_schedule_management.
  ///
  /// In en, this message translates to:
  /// **'Fixed Schedule Management'**
  String get fixed_schedule_management;

  /// No description provided for @settings_repeat_every.
  ///
  /// In en, this message translates to:
  /// **'Settings below will repeat every {day}'**
  String settings_repeat_every(Object day);

  /// No description provided for @closed_on_day.
  ///
  /// In en, this message translates to:
  /// **'Closed on {day}'**
  String closed_on_day(Object day);

  /// No description provided for @no_services_day.
  ///
  /// In en, this message translates to:
  /// **'No services provided this day'**
  String get no_services_day;

  /// No description provided for @apply_day_to_week.
  ///
  /// In en, this message translates to:
  /// **'Apply {day} to entire week'**
  String apply_day_to_week(Object day);

  /// No description provided for @time_slots.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get time_slots;

  /// No description provided for @add_slot.
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get add_slot;

  /// No description provided for @assigned_employees.
  ///
  /// In en, this message translates to:
  /// **'Assigned Employees'**
  String get assigned_employees;

  /// No description provided for @total_label.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total_label;

  /// No description provided for @save_weekly_schedule.
  ///
  /// In en, this message translates to:
  /// **'Save Weekly Schedule'**
  String get save_weekly_schedule;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @morning_service.
  ///
  /// In en, this message translates to:
  /// **'Morning Service'**
  String get morning_service;

  /// No description provided for @midday_service.
  ///
  /// In en, this message translates to:
  /// **'Midday Service'**
  String get midday_service;

  /// No description provided for @evening_service.
  ///
  /// In en, this message translates to:
  /// **'Evening Service'**
  String get evening_service;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @kwd.
  ///
  /// In en, this message translates to:
  /// **'KWD'**
  String get kwd;
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
      'that was used.');
}
