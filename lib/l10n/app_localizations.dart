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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @previewLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and password.'**
  String get previewLoginRequired;

  /// No description provided for @previewLoginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your DEV phone number and password, and that your account is active.'**
  String get previewLoginInvalid;

  /// No description provided for @previewLoginUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the DEV server. Please try again.'**
  String get previewLoginUnavailable;

  /// No description provided for @previewLoginCompanyRequired.
  ///
  /// In en, this message translates to:
  /// **'This account cannot open the company preview. Sign in with a DEV business owner or manager linked to a business.'**
  String get previewLoginCompanyRequired;

  /// No description provided for @previewLoginSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'The login session could not be loaded. Refresh the page and try again.'**
  String get previewLoginSessionFailed;

  /// No description provided for @previewLoginRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many sign-in attempts. Please wait before trying again.'**
  String get previewLoginRateLimit;

  /// No description provided for @documentsCenter.
  ///
  /// In en, this message translates to:
  /// **'Documents Center'**
  String get documentsCenter;

  /// No description provided for @documentPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get documentPolicy;

  /// No description provided for @documentContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get documentContract;

  /// No description provided for @documentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get documentOther;

  /// No description provided for @documentDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get documentDownload;

  /// No description provided for @documentView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get documentView;

  /// No description provided for @documentPreviewError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this document.'**
  String get documentPreviewError;

  /// No description provided for @documentPreviewTimeout.
  ///
  /// In en, this message translates to:
  /// **'Opening this document took too long. Try downloading it instead.'**
  String get documentPreviewTimeout;

  /// No description provided for @documentPreviewUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Preview is unavailable for this file type. You can download the file instead.'**
  String get documentPreviewUnsupported;

  /// No description provided for @documentDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Document downloaded'**
  String get documentDownloaded;

  /// No description provided for @documentRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get documentRefresh;

  /// No description provided for @documentSearch.
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get documentSearch;

  /// No description provided for @documentCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get documentCategory;

  /// No description provided for @documentAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get documentAllCategories;

  /// No description provided for @documentShared.
  ///
  /// In en, this message translates to:
  /// **'All businesses'**
  String get documentShared;

  /// No description provided for @documentForYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Your business'**
  String get documentForYourBusiness;

  /// No description provided for @documentRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get documentRetry;

  /// No description provided for @documentsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load or download documents. Please try again.'**
  String get documentsError;

  /// No description provided for @documentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get documentsEmpty;

  /// No description provided for @documentPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get documentPrevious;

  /// No description provided for @documentNext.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get documentNext;

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
  /// **'End time must be after start time'**
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

  /// No description provided for @request_status_updated.
  ///
  /// In en, this message translates to:
  /// **'Status was updated'**
  String get request_status_updated;

  /// No description provided for @request_location_reminder.
  ///
  /// In en, this message translates to:
  /// **'Please double-check the customer\'s map location before sending the team.'**
  String get request_location_reminder;

  /// No description provided for @refresh_request_details.
  ///
  /// In en, this message translates to:
  /// **'Refresh request details'**
  String get refresh_request_details;

  /// No description provided for @request_visit_id_missing.
  ///
  /// In en, this message translates to:
  /// **'This visit is missing its ID. Refresh the request details and try again.'**
  String get request_visit_id_missing;

  /// No description provided for @request_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get request_paid;

  /// No description provided for @request_not_paid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get request_not_paid;

  /// No description provided for @request_share_furniture_item.
  ///
  /// In en, this message translates to:
  /// **'Item: {item}\nSize: {size}\nQuantity: {quantity}'**
  String request_share_furniture_item(String item, String size, String quantity);

  /// No description provided for @open_in_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get open_in_google_maps;

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

  /// No description provided for @price_must_be_zero_or_greater.
  ///
  /// In en, this message translates to:
  /// **'Price must be zero or greater'**
  String get price_must_be_zero_or_greater;

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

  /// No description provided for @service_frequency.
  ///
  /// In en, this message translates to:
  /// **'Service Frequency'**
  String get service_frequency;

  /// No description provided for @discount_percentage.
  ///
  /// In en, this message translates to:
  /// **'Discount Percentage'**
  String get discount_percentage;

  /// No description provided for @frequency_visits_per_week.
  ///
  /// In en, this message translates to:
  /// **'visit'**
  String get frequency_visits_per_week;

  /// No description provided for @enter_all_frequency_discounts.
  ///
  /// In en, this message translates to:
  /// **'Enter all service frequency discounts.'**
  String get enter_all_frequency_discounts;

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

  /// No description provided for @business_setup_tour_restart.
  ///
  /// In en, this message translates to:
  /// **'Show setup guide'**
  String get business_setup_tour_restart;

  /// No description provided for @business_setup_tour_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip guide'**
  String get business_setup_tour_skip;

  /// No description provided for @business_setup_tour_previous.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get business_setup_tour_previous;

  /// No description provided for @business_setup_tour_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get business_setup_tour_next;

  /// No description provided for @business_setup_tour_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get business_setup_tour_done;

  /// No description provided for @business_setup_tour_profile.
  ///
  /// In en, this message translates to:
  /// **'Start here: add your logo, company details, service descriptions, and the services you provide.'**
  String get business_setup_tour_profile;

  /// No description provided for @business_setup_tour_housekeeping.
  ///
  /// In en, this message translates to:
  /// **'Set hourly pricing and area fees, then define when your team is available.'**
  String get business_setup_tour_housekeeping;

  /// No description provided for @business_setup_tour_car_wash.
  ///
  /// In en, this message translates to:
  /// **'Create wash packages, assign them to vehicle types, add area fees, and set service availability.'**
  String get business_setup_tour_car_wash;

  /// No description provided for @business_setup_tour_furniture.
  ///
  /// In en, this message translates to:
  /// **'Activate the furniture types you clean, price every supported size, and set service availability.'**
  String get business_setup_tour_furniture;

  /// No description provided for @business_setup_tour_auto_bid.
  ///
  /// In en, this message translates to:
  /// **'For deep cleaning, enable automatic bidding and define the prices and expected duration.'**
  String get business_setup_tour_auto_bid;

  /// No description provided for @business_setup_tour_staff.
  ///
  /// In en, this message translates to:
  /// **'Create staff accounts and teams, assign permissions, and review the employee calendar.'**
  String get business_setup_tour_staff;

  /// No description provided for @business_setup_tour_requests.
  ///
  /// In en, this message translates to:
  /// **'Review new customer requests and submit or accept work according to the service.'**
  String get business_setup_tour_requests;

  /// No description provided for @business_setup_tour_jobs.
  ///
  /// In en, this message translates to:
  /// **'Manage confirmed jobs here, from assignment and start through completion.'**
  String get business_setup_tour_jobs;

  /// No description provided for @business_inner_tour_housekeeping_pricing.
  ///
  /// In en, this message translates to:
  /// **'Set hourly and duration-based prices, repeat-booking discounts, cleaning-product charges, and area fees.'**
  String get business_inner_tour_housekeeping_pricing;

  /// No description provided for @business_inner_tour_housekeeping_availability.
  ///
  /// In en, this message translates to:
  /// **'Choose the days and time slots when your housekeeping team can accept bookings.'**
  String get business_inner_tour_housekeeping_availability;

  /// No description provided for @business_inner_tour_car_wash_packages.
  ///
  /// In en, this message translates to:
  /// **'Create reusable wash packages, then assign each package to the vehicle types you support.'**
  String get business_inner_tour_car_wash_packages;

  /// No description provided for @business_inner_tour_car_wash_hours.
  ///
  /// In en, this message translates to:
  /// **'Define the weekly days and time slots when customers can book car washing.'**
  String get business_inner_tour_car_wash_hours;

  /// No description provided for @business_inner_tour_staff_create_user.
  ///
  /// In en, this message translates to:
  /// **'Create a staff account and grant only the permissions needed for that role.'**
  String get business_inner_tour_staff_create_user;

  /// No description provided for @business_inner_tour_staff_manage_users.
  ///
  /// In en, this message translates to:
  /// **'Review staff accounts, update permissions, and enable or disable access.'**
  String get business_inner_tour_staff_manage_users;

  /// No description provided for @business_inner_tour_staff_create_team.
  ///
  /// In en, this message translates to:
  /// **'Group staff into a team that can be assigned to customer requests.'**
  String get business_inner_tour_staff_create_team;

  /// No description provided for @business_inner_tour_staff_manage_teams.
  ///
  /// In en, this message translates to:
  /// **'Review and update the teams available for job assignment.'**
  String get business_inner_tour_staff_manage_teams;

  /// No description provided for @business_inner_tour_staff_calendar.
  ///
  /// In en, this message translates to:
  /// **'Use the employee calendar to review scheduled work and team workload.'**
  String get business_inner_tour_staff_calendar;

  /// No description provided for @business_inner_tour_profile_identity.
  ///
  /// In en, this message translates to:
  /// **'Add a clear logo and complete the company contact details shown to customers.'**
  String get business_inner_tour_profile_identity;

  /// No description provided for @business_inner_tour_profile_services.
  ///
  /// In en, this message translates to:
  /// **'Open each offered service to choose and describe the exact work your company covers.'**
  String get business_inner_tour_profile_services;

  /// No description provided for @business_inner_tour_profile_areas.
  ///
  /// In en, this message translates to:
  /// **'Select every area your company serves. These areas control where customers can find you.'**
  String get business_inner_tour_profile_areas;

  /// No description provided for @business_inner_tour_profile_save.
  ///
  /// In en, this message translates to:
  /// **'Save after updating company details, coverage, service descriptions, or media.'**
  String get business_inner_tour_profile_save;

  /// No description provided for @business_inner_tour_upholstery_type.
  ///
  /// In en, this message translates to:
  /// **'Expand a furniture type to set size prices, and use its switch to offer or hide that type.'**
  String get business_inner_tour_upholstery_type;

  /// No description provided for @business_inner_tour_upholstery_save.
  ///
  /// In en, this message translates to:
  /// **'Save after activating furniture types and entering a valid price for every supported size.'**
  String get business_inner_tour_upholstery_save;

  /// No description provided for @business_inner_tour_requests.
  ///
  /// In en, this message translates to:
  /// **'Expand a request to review its details, then open it to accept the work or submit a bid when applicable.'**
  String get business_inner_tour_requests;

  /// No description provided for @business_inner_tour_jobs_statuses.
  ///
  /// In en, this message translates to:
  /// **'Switch between confirmed, in-progress, completed, and cancelled jobs.'**
  String get business_inner_tour_jobs_statuses;

  /// No description provided for @business_inner_tour_jobs_list.
  ///
  /// In en, this message translates to:
  /// **'Open a job to assign staff, manage its status, contact the customer, or add an extra invoice when allowed.'**
  String get business_inner_tour_jobs_list;

  /// No description provided for @business_inner_tour_area_fees.
  ///
  /// In en, this message translates to:
  /// **'Set the additional travel fee for each service area. Leave unsupported areas without an active fee.'**
  String get business_inner_tour_area_fees;

  /// No description provided for @business_inner_tour_schedule_days.
  ///
  /// In en, this message translates to:
  /// **'Select a day to review and configure its availability.'**
  String get business_inner_tour_schedule_days;

  /// No description provided for @business_inner_tour_schedule_day_status.
  ///
  /// In en, this message translates to:
  /// **'Mark the selected day open or closed before editing its time slots.'**
  String get business_inner_tour_schedule_day_status;

  /// No description provided for @business_inner_tour_schedule_apply_week.
  ///
  /// In en, this message translates to:
  /// **'Use this only when the selected day\'s schedule should replace every other day in the week.'**
  String get business_inner_tour_schedule_apply_week;

  /// No description provided for @business_inner_tour_schedule_slots.
  ///
  /// In en, this message translates to:
  /// **'Add and edit the booking time slots available on the selected day.'**
  String get business_inner_tour_schedule_slots;

  /// No description provided for @business_inner_tour_schedule_save.
  ///
  /// In en, this message translates to:
  /// **'Save the complete weekly schedule after reviewing every day.'**
  String get business_inner_tour_schedule_save;

  /// No description provided for @business_inner_tour_car_wash_sections.
  ///
  /// In en, this message translates to:
  /// **'Move between reusable packages, vehicle assignments, and delivery fees by area.'**
  String get business_inner_tour_car_wash_sections;

  /// No description provided for @business_inner_tour_car_wash_package_editor.
  ///
  /// In en, this message translates to:
  /// **'Create package details here. Next, assign saved packages to vehicle types and configure area fees.'**
  String get business_inner_tour_car_wash_package_editor;

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

  /// No description provided for @submitted_bid_title.
  ///
  /// In en, this message translates to:
  /// **'Submitted Bid'**
  String get submitted_bid_title;

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

  /// No description provided for @total_income_label.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get total_income_label;

  /// No description provided for @total_fees_label.
  ///
  /// In en, this message translates to:
  /// **'Total Fees'**
  String get total_fees_label;

  /// No description provided for @total_income_after_fee_label.
  ///
  /// In en, this message translates to:
  /// **'Total Income After Fee'**
  String get total_income_after_fee_label;

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

  /// No description provided for @request_types_title.
  ///
  /// In en, this message translates to:
  /// **'Request Types'**
  String get request_types_title;

  /// No description provided for @request_status_title.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get request_status_title;

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

  /// No description provided for @hourly_availability.
  ///
  /// In en, this message translates to:
  /// **'Hourly Availability'**
  String get hourly_availability;

  /// No description provided for @availability_hourly_hint.
  ///
  /// In en, this message translates to:
  /// **'Enable the hours when customers can book, then set how many workers are available during each hour.'**
  String get availability_hourly_hint;

  /// No description provided for @availability_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get availability_enabled;

  /// No description provided for @availability_disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get availability_disabled;

  /// No description provided for @availability_enabled_hours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours enabled'**
  String availability_enabled_hours(int count);

  /// No description provided for @availability_no_hours_enabled.
  ///
  /// In en, this message translates to:
  /// **'No hours enabled'**
  String get availability_no_hours_enabled;

  /// No description provided for @availability_enable_all.
  ///
  /// In en, this message translates to:
  /// **'Enable all'**
  String get availability_enable_all;

  /// No description provided for @availability_disable_all.
  ///
  /// In en, this message translates to:
  /// **'Disable all'**
  String get availability_disable_all;

  /// No description provided for @availability_apply_other_days.
  ///
  /// In en, this message translates to:
  /// **'Apply to other days'**
  String get availability_apply_other_days;

  /// No description provided for @availability_apply_schedule_title.
  ///
  /// In en, this message translates to:
  /// **'Apply {day}\'s schedule'**
  String availability_apply_schedule_title(String day);

  /// No description provided for @availability_select_days_hint.
  ///
  /// In en, this message translates to:
  /// **'Select every day that should receive this schedule.'**
  String get availability_select_days_hint;

  /// No description provided for @availability_select_all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get availability_select_all;

  /// No description provided for @availability_apply_selected.
  ///
  /// In en, this message translates to:
  /// **'Apply to selected days'**
  String get availability_apply_selected;

  /// No description provided for @availability_copy_warning.
  ///
  /// In en, this message translates to:
  /// **'Existing changes for selected days will be replaced. Each day can still be edited independently afterward.'**
  String get availability_copy_warning;

  /// No description provided for @availability_schedule_copied.
  ///
  /// In en, this message translates to:
  /// **'Schedule copied to the selected days'**
  String get availability_schedule_copied;

  /// No description provided for @availability_unsaved_changes.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved availability changes.'**
  String get availability_unsaved_changes;

  /// No description provided for @availability_save_before_leaving.
  ///
  /// In en, this message translates to:
  /// **'Please save your changes before leaving.'**
  String get availability_save_before_leaving;

  /// No description provided for @availability_discard_title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get availability_discard_title;

  /// No description provided for @availability_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get availability_discard;

  /// No description provided for @availability_saved.
  ///
  /// In en, this message translates to:
  /// **'Availability saved'**
  String get availability_saved;

  /// No description provided for @availability_no_changes.
  ///
  /// In en, this message translates to:
  /// **'There are no changes to save'**
  String get availability_no_changes;

  /// No description provided for @availability_invalid_workers.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 1 worker for every enabled hour.'**
  String get availability_invalid_workers;

  /// No description provided for @availability_changed_days.
  ///
  /// In en, this message translates to:
  /// **'{count} days changed'**
  String availability_changed_days(int count);

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

  /// No description provided for @chat_with_customer.
  ///
  /// In en, this message translates to:
  /// **'Chat with customer'**
  String get chat_with_customer;

  /// No description provided for @chat_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Chat created successfully'**
  String get chat_created_successfully;

  /// No description provided for @chat_fab_title.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_fab_title;

  /// No description provided for @chat_minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get chat_minimize;

  /// No description provided for @chat_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get chat_close;

  /// No description provided for @chat_close_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to close this chat?'**
  String get chat_close_confirmation;

  /// No description provided for @chat_close_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to close chat'**
  String get chat_close_failed;

  /// No description provided for @chat_no_conversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chat_no_conversations;

  /// No description provided for @chat_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_no_messages;

  /// No description provided for @chat_closed_status.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get chat_closed_status;

  /// No description provided for @chat_closed.
  ///
  /// In en, this message translates to:
  /// **'Chat closed'**
  String get chat_closed;

  /// No description provided for @chat_status_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get chat_status_connected;

  /// No description provided for @chat_status_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get chat_status_connecting;

  /// No description provided for @chat_status_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get chat_status_disconnected;

  /// No description provided for @chat_status_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get chat_status_error;

  /// No description provided for @chat_type_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chat_type_message;

  /// No description provided for @chat_load_older_messages.
  ///
  /// In en, this message translates to:
  /// **'Load older messages'**
  String get chat_load_older_messages;

  /// No description provided for @chat_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get chat_send_failed;

  /// No description provided for @chat_request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get chat_request;

  /// No description provided for @chat_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get chat_type;

  /// No description provided for @chat_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chat_status;

  /// No description provided for @chat_customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get chat_customer;

  /// No description provided for @chat_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get chat_phone;

  /// No description provided for @chat_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get chat_price;

  /// No description provided for @car_wash_configuration.
  ///
  /// In en, this message translates to:
  /// **'Car Wash Configuration'**
  String get car_wash_configuration;

  /// No description provided for @car_wash_pricing.
  ///
  /// In en, this message translates to:
  /// **'Car Wash Pricing'**
  String get car_wash_pricing;

  /// No description provided for @car_wash_packages_and_pricing.
  ///
  /// In en, this message translates to:
  /// **'Packages, Vehicles & Fees'**
  String get car_wash_packages_and_pricing;

  /// No description provided for @car_wash_packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get car_wash_packages;

  /// No description provided for @car_wash_packages_hint.
  ///
  /// In en, this message translates to:
  /// **'Create each package once, set its price for every vehicle type, then assign it to the vehicle types you support.'**
  String get car_wash_packages_hint;

  /// No description provided for @car_wash_vehicle_pricing.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type Pricing'**
  String get car_wash_vehicle_pricing;

  /// No description provided for @car_wash_vehicle_pricing_hint.
  ///
  /// In en, this message translates to:
  /// **'Set this package\'s price separately for every vehicle type.'**
  String get car_wash_vehicle_pricing_hint;

  /// No description provided for @car_wash_vehicle_price_not_set.
  ///
  /// In en, this message translates to:
  /// **'No price is configured for this vehicle type'**
  String get car_wash_vehicle_price_not_set;

  /// No description provided for @car_wash_vehicle_assignments.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Types'**
  String get car_wash_vehicle_assignments;

  /// No description provided for @car_wash_vehicle_assignments_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose which reusable packages are offered for each vehicle type.'**
  String get car_wash_vehicle_assignments_hint;

  /// No description provided for @car_wash_area_fees.
  ///
  /// In en, this message translates to:
  /// **'Area Fees'**
  String get car_wash_area_fees;

  /// No description provided for @car_wash_area_fees_hint.
  ///
  /// In en, this message translates to:
  /// **'Set an optional delivery fee for each service area.'**
  String get car_wash_area_fees_hint;

  /// No description provided for @car_wash_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Car Wash Availability'**
  String get car_wash_working_hours;

  /// No description provided for @vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicle_type;

  /// No description provided for @package_label.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package_label;

  /// No description provided for @save_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Save Working Hours'**
  String get save_working_hours;

  /// No description provided for @pricing_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Pricing saved successfully'**
  String get pricing_saved_successfully;

  /// No description provided for @working_hours_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Working hours saved successfully'**
  String get working_hours_saved_successfully;

  /// No description provided for @no_car_wash_options.
  ///
  /// In en, this message translates to:
  /// **'No car wash options available'**
  String get no_car_wash_options;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// No description provided for @car_wash_description_en.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get car_wash_description_en;

  /// No description provided for @car_wash_description_ar.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get car_wash_description_ar;

  /// No description provided for @add_car_wash_package.
  ///
  /// In en, this message translates to:
  /// **'Add Package'**
  String get add_car_wash_package;

  /// No description provided for @remove_package.
  ///
  /// In en, this message translates to:
  /// **'Remove Package'**
  String get remove_package;

  /// No description provided for @no_vehicle_packages.
  ///
  /// In en, this message translates to:
  /// **'No packages added for this vehicle type'**
  String get no_vehicle_packages;

  /// No description provided for @create_car_wash_package.
  ///
  /// In en, this message translates to:
  /// **'Create Package'**
  String get create_car_wash_package;

  /// No description provided for @edit_car_wash_package.
  ///
  /// In en, this message translates to:
  /// **'Edit Package'**
  String get edit_car_wash_package;

  /// No description provided for @delete_car_wash_package.
  ///
  /// In en, this message translates to:
  /// **'Delete Package'**
  String get delete_car_wash_package;

  /// No description provided for @delete_car_wash_package_message.
  ///
  /// In en, this message translates to:
  /// **'Delete this package? It will no longer be available for any vehicle type.'**
  String get delete_car_wash_package_message;

  /// No description provided for @package_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Package created successfully'**
  String get package_created_successfully;

  /// No description provided for @package_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Package updated successfully'**
  String get package_updated_successfully;

  /// No description provided for @package_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Package deleted successfully'**
  String get package_deleted_successfully;

  /// No description provided for @no_car_wash_packages.
  ///
  /// In en, this message translates to:
  /// **'No packages created yet'**
  String get no_car_wash_packages;

  /// No description provided for @package_title_required.
  ///
  /// In en, this message translates to:
  /// **'Enter the package title in English and Arabic'**
  String get package_title_required;

  /// No description provided for @invalid_discount_percentage.
  ///
  /// In en, this message translates to:
  /// **'Discount must be between 0 and 100'**
  String get invalid_discount_percentage;

  /// No description provided for @car_wash_package_enabled.
  ///
  /// In en, this message translates to:
  /// **'Package enabled'**
  String get car_wash_package_enabled;

  /// No description provided for @car_wash_package_enabled_hint.
  ///
  /// In en, this message translates to:
  /// **'Enabled packages are available to customers. Disabled packages are hidden.'**
  String get car_wash_package_enabled_hint;

  /// No description provided for @package_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Package Availability'**
  String get package_working_hours;

  /// No description provided for @package_working_hours_hint.
  ///
  /// In en, this message translates to:
  /// **'Optionally add the days and time slots when this package can be booked.'**
  String get package_working_hours_hint;

  /// No description provided for @package_availability_not_set.
  ///
  /// In en, this message translates to:
  /// **'No availability slots added'**
  String get package_availability_not_set;

  /// No description provided for @package_time_slots.
  ///
  /// In en, this message translates to:
  /// **'time slots'**
  String get package_time_slots;

  /// No description provided for @package_duration_minutes.
  ///
  /// In en, this message translates to:
  /// **'Package Duration'**
  String get package_duration_minutes;

  /// No description provided for @package_duration_minutes_hint.
  ///
  /// In en, this message translates to:
  /// **'How long one booking takes, in minutes'**
  String get package_duration_minutes_hint;

  /// No description provided for @duration_must_be_positive.
  ///
  /// In en, this message translates to:
  /// **'Duration must be greater than zero'**
  String get duration_must_be_positive;

  /// No description provided for @minutes_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes_short;

  /// No description provided for @add_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get add_time_slot;

  /// No description provided for @edit_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Edit Time Slot'**
  String get edit_time_slot;

  /// No description provided for @overlapping_time_slot.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps another slot on the same day'**
  String get overlapping_time_slot;

  /// No description provided for @save_package.
  ///
  /// In en, this message translates to:
  /// **'Save Package'**
  String get save_package;

  /// No description provided for @create_package_first.
  ///
  /// In en, this message translates to:
  /// **'Create at least one package before assigning packages to vehicles.'**
  String get create_package_first;

  /// No description provided for @assign_packages_to_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Select the packages offered for this vehicle type'**
  String get assign_packages_to_vehicle;

  /// No description provided for @save_package_assignments.
  ///
  /// In en, this message translates to:
  /// **'Save Assignments'**
  String get save_package_assignments;

  /// No description provided for @package_assignments_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Vehicle package assignments saved successfully'**
  String get package_assignments_saved_successfully;

  /// No description provided for @delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get delivery_fee;

  /// No description provided for @fee_not_set.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get fee_not_set;

  /// No description provided for @set_delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Set Delivery Fee'**
  String get set_delivery_fee;

  /// No description provided for @edit_delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Edit Delivery Fee'**
  String get edit_delivery_fee;

  /// No description provided for @remove_delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Remove Delivery Fee'**
  String get remove_delivery_fee;

  /// No description provided for @remove_delivery_fee_message.
  ///
  /// In en, this message translates to:
  /// **'Remove the delivery fee for this area?'**
  String get remove_delivery_fee_message;

  /// No description provided for @fee_cannot_be_negative.
  ///
  /// In en, this message translates to:
  /// **'Fee cannot be negative'**
  String get fee_cannot_be_negative;

  /// No description provided for @area_fee_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Area fee saved successfully'**
  String get area_fee_saved_successfully;

  /// No description provided for @area_fee_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Area fee removed successfully'**
  String get area_fee_deleted_successfully;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @upholstery_configuration.
  ///
  /// In en, this message translates to:
  /// **'Furniture Cleaning Configuration'**
  String get upholstery_configuration;

  /// No description provided for @upholstery_pricing.
  ///
  /// In en, this message translates to:
  /// **'Furniture Cleaning Pricing'**
  String get upholstery_pricing;

  /// No description provided for @upholstery_description_en.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get upholstery_description_en;

  /// No description provided for @upholstery_description_ar.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get upholstery_description_ar;

  /// No description provided for @add_upholstery_package.
  ///
  /// In en, this message translates to:
  /// **'Add Package'**
  String get add_upholstery_package;

  /// No description provided for @no_upholstery_types.
  ///
  /// In en, this message translates to:
  /// **'No furniture types are available'**
  String get no_upholstery_types;

  /// No description provided for @no_upholstery_packages.
  ///
  /// In en, this message translates to:
  /// **'No packages added for this furniture type'**
  String get no_upholstery_packages;

  /// No description provided for @upholstery_size_pricing_hint.
  ///
  /// In en, this message translates to:
  /// **'Enable each furniture type your company cleans, then set the price and optional discount for every size.'**
  String get upholstery_size_pricing_hint;

  /// No description provided for @offer_upholstery_type.
  ///
  /// In en, this message translates to:
  /// **'Offer cleaning for this furniture type'**
  String get offer_upholstery_type;

  /// No description provided for @no_upholstery_sizes.
  ///
  /// In en, this message translates to:
  /// **'No sizes are configured for this furniture type'**
  String get no_upholstery_sizes;

  /// No description provided for @additional_upholstery_packages.
  ///
  /// In en, this message translates to:
  /// **'Existing additional packages'**
  String get additional_upholstery_packages;

  /// No description provided for @car_wash_service.
  ///
  /// In en, this message translates to:
  /// **'Car Wash'**
  String get car_wash_service;

  /// No description provided for @car_wash_request_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles and Packages'**
  String get car_wash_request_vehicles;

  /// No description provided for @no_car_wash_vehicle_details.
  ///
  /// In en, this message translates to:
  /// **'No vehicle details are available for this request.'**
  String get no_car_wash_vehicle_details;

  /// No description provided for @original_order_total.
  ///
  /// In en, this message translates to:
  /// **'Original order total'**
  String get original_order_total;

  /// No description provided for @create_extra_invoice.
  ///
  /// In en, this message translates to:
  /// **'Create extra invoice'**
  String get create_extra_invoice;

  /// No description provided for @extra_invoice.
  ///
  /// In en, this message translates to:
  /// **'Extra invoice'**
  String get extra_invoice;

  /// No description provided for @extra_invoice_amount.
  ///
  /// In en, this message translates to:
  /// **'Extra amount'**
  String get extra_invoice_amount;

  /// No description provided for @extra_invoice_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get extra_invoice_reason;

  /// No description provided for @extra_invoice_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'For example, an additional service requested on site'**
  String get extra_invoice_reason_hint;

  /// No description provided for @extra_invoice_customer_payment_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the additional service amount and reason. The customer will receive an invoice to pay from the request details screen.'**
  String get extra_invoice_customer_payment_hint;

  /// No description provided for @extra_invoice_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Extra invoice created successfully'**
  String get extra_invoice_created_successfully;

  /// No description provided for @extra_invoice_amount_required.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get extra_invoice_amount_required;

  /// No description provided for @extra_invoice_reason_required.
  ///
  /// In en, this message translates to:
  /// **'Enter a reason for the extra invoice'**
  String get extra_invoice_reason_required;

  /// No description provided for @extra_invoice_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for extra payment'**
  String get extra_invoice_payment_pending;

  /// No description provided for @extra_invoice_payment_pending_hint.
  ///
  /// In en, this message translates to:
  /// **'The customer must pay this invoice from the request details screen before another one can be created.'**
  String get extra_invoice_payment_pending_hint;

  /// No description provided for @extra_invoice_payments_successful.
  ///
  /// In en, this message translates to:
  /// **'Extra invoice payments successful'**
  String get extra_invoice_payments_successful;

  /// No description provided for @extra_invoice_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get extra_invoice_paid;

  /// No description provided for @extra_invoice_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get extra_invoice_pending;

  /// No description provided for @extra_invoice_total_paid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get extra_invoice_total_paid;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @laundry_service.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get laundry_service;

  /// No description provided for @laundry_catalog.
  ///
  /// In en, this message translates to:
  /// **'Laundry price list'**
  String get laundry_catalog;

  /// No description provided for @laundry_setup_help.
  ///
  /// In en, this message translates to:
  /// **'Enable your items, choose their services and set prices. Service names are managed globally by admin. You can also add your own items.'**
  String get laundry_setup_help;

  /// No description provided for @laundry_add_item.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get laundry_add_item;

  /// No description provided for @laundry_edit_item.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get laundry_edit_item;

  /// No description provided for @laundry_empty_catalog.
  ///
  /// In en, this message translates to:
  /// **'Add your first laundry item to start building your price list.'**
  String get laundry_empty_catalog;

  /// No description provided for @laundry_name_en.
  ///
  /// In en, this message translates to:
  /// **'Item name in English'**
  String get laundry_name_en;

  /// No description provided for @laundry_name_ar.
  ///
  /// In en, this message translates to:
  /// **'Item name in Arabic'**
  String get laundry_name_ar;

  /// No description provided for @laundry_unit.
  ///
  /// In en, this message translates to:
  /// **'Pricing unit'**
  String get laundry_unit;

  /// No description provided for @laundry_unit_item.
  ///
  /// In en, this message translates to:
  /// **'Per item'**
  String get laundry_unit_item;

  /// No description provided for @laundry_unit_meter.
  ///
  /// In en, this message translates to:
  /// **'Per meter'**
  String get laundry_unit_meter;

  /// No description provided for @laundry_unit_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom unit'**
  String get laundry_unit_custom;

  /// No description provided for @laundry_unit_label.
  ///
  /// In en, this message translates to:
  /// **'Custom unit label'**
  String get laundry_unit_label;

  /// No description provided for @laundry_price.
  ///
  /// In en, this message translates to:
  /// **'Unit price (KWD)'**
  String get laundry_price;

  /// No description provided for @laundry_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get laundry_active;

  /// No description provided for @laundry_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get laundry_inactive;

  /// No description provided for @laundry_sizes.
  ///
  /// In en, this message translates to:
  /// **'Size-based prices'**
  String get laundry_sizes;

  /// No description provided for @laundry_add_size.
  ///
  /// In en, this message translates to:
  /// **'Add size'**
  String get laundry_add_size;

  /// No description provided for @laundry_size_en.
  ///
  /// In en, this message translates to:
  /// **'Size in English'**
  String get laundry_size_en;

  /// No description provided for @laundry_size_ar.
  ///
  /// In en, this message translates to:
  /// **'Size in Arabic'**
  String get laundry_size_ar;

  /// No description provided for @laundry_deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate item'**
  String get laundry_deactivate;

  /// No description provided for @laundry_deactivate_confirm.
  ///
  /// In en, this message translates to:
  /// **'Deactivate this item? It will no longer appear in the customer price list. Existing orders keep their prices.'**
  String get laundry_deactivate_confirm;

  /// No description provided for @laundry_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get laundry_required;

  /// No description provided for @laundry_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount from 0 to 10,000 with up to 3 decimal places'**
  String get laundry_valid_number;

  /// No description provided for @laundry_valid_quantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity from 0.001 to 10,000 with up to 3 decimal places'**
  String get laundry_valid_quantity;

  /// No description provided for @laundry_order.
  ///
  /// In en, this message translates to:
  /// **'Laundry order'**
  String get laundry_order;

  /// No description provided for @laundry_pickup_first.
  ///
  /// In en, this message translates to:
  /// **'Pickup first, invoice later'**
  String get laundry_pickup_first;

  /// No description provided for @laundry_upfront.
  ///
  /// In en, this message translates to:
  /// **'Items paid upfront'**
  String get laundry_upfront;

  /// No description provided for @laundry_pending_pickup.
  ///
  /// In en, this message translates to:
  /// **'Pick up bag'**
  String get laundry_pending_pickup;

  /// No description provided for @laundry_pickup_accepted.
  ///
  /// In en, this message translates to:
  /// **'Pickup accepted'**
  String get laundry_pickup_accepted;

  /// No description provided for @laundry_pickup_rejected.
  ///
  /// In en, this message translates to:
  /// **'Pickup rejected'**
  String get laundry_pickup_rejected;

  /// No description provided for @laundry_picked_up.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get laundry_picked_up;

  /// No description provided for @laundry_invoice_sent.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get laundry_invoice_sent;

  /// No description provided for @laundry_ready_for_delivery.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get laundry_ready_for_delivery;

  /// No description provided for @laundry_out_for_delivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get laundry_out_for_delivery;

  /// No description provided for @laundry_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get laundry_delivered;

  /// No description provided for @laundry_accept_pickup.
  ///
  /// In en, this message translates to:
  /// **'Accept pickup'**
  String get laundry_accept_pickup;

  /// No description provided for @laundry_reject_pickup.
  ///
  /// In en, this message translates to:
  /// **'Reject pickup'**
  String get laundry_reject_pickup;

  /// No description provided for @laundry_mark_picked_up.
  ///
  /// In en, this message translates to:
  /// **'Mark as picked up'**
  String get laundry_mark_picked_up;

  /// No description provided for @laundry_start_work.
  ///
  /// In en, this message translates to:
  /// **'Start laundry'**
  String get laundry_start_work;

  /// No description provided for @laundry_mark_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get laundry_mark_ready;

  /// No description provided for @laundry_start_delivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get laundry_start_delivery;

  /// No description provided for @laundry_mark_delivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get laundry_mark_delivered;

  /// No description provided for @laundry_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete order'**
  String get laundry_complete;

  /// No description provided for @laundry_waiting_payment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for customer payment. Refresh to check payment status.'**
  String get laundry_waiting_payment;

  /// No description provided for @laundry_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get laundry_payment_pending;

  /// No description provided for @laundry_payment_unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get laundry_payment_unpaid;

  /// No description provided for @laundry_payment_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get laundry_payment_refunded;

  /// No description provided for @laundry_bags.
  ///
  /// In en, this message translates to:
  /// **'Number of bags'**
  String get laundry_bags;

  /// No description provided for @laundry_pickup_time.
  ///
  /// In en, this message translates to:
  /// **'Pickup date and time'**
  String get laundry_pickup_time;

  /// No description provided for @laundry_items.
  ///
  /// In en, this message translates to:
  /// **'Laundry items'**
  String get laundry_items;

  /// No description provided for @laundry_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get laundry_quantity;

  /// No description provided for @laundry_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get laundry_size;

  /// No description provided for @laundry_no_items.
  ///
  /// In en, this message translates to:
  /// **'Pickup without an item list'**
  String get laundry_no_items;

  /// No description provided for @laundry_invoice.
  ///
  /// In en, this message translates to:
  /// **'Laundry invoice'**
  String get laundry_invoice;

  /// No description provided for @laundry_create_invoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get laundry_create_invoice;

  /// No description provided for @laundry_edit_invoice.
  ///
  /// In en, this message translates to:
  /// **'Edit draft invoice'**
  String get laundry_edit_invoice;

  /// No description provided for @laundry_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get laundry_draft;

  /// No description provided for @laundry_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get laundry_sent;

  /// No description provided for @laundry_save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get laundry_save_draft;

  /// No description provided for @laundry_send_invoice.
  ///
  /// In en, this message translates to:
  /// **'Send invoice'**
  String get laundry_send_invoice;

  /// No description provided for @laundry_invoice_help.
  ///
  /// In en, this message translates to:
  /// **'Choose items from your active catalog. Prices are calculated from your company price list when you save.'**
  String get laundry_invoice_help;

  /// No description provided for @laundry_pickup_fee.
  ///
  /// In en, this message translates to:
  /// **'Pickup fee (KWD)'**
  String get laundry_pickup_fee;

  /// No description provided for @laundry_delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee (KWD)'**
  String get laundry_delivery_fee;

  /// No description provided for @laundry_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount (KWD)'**
  String get laundry_discount;

  /// No description provided for @laundry_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get laundry_subtotal;

  /// No description provided for @laundry_platform_fees.
  ///
  /// In en, this message translates to:
  /// **'Platform fees'**
  String get laundry_platform_fees;

  /// No description provided for @laundry_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get laundry_total;

  /// No description provided for @laundry_invoice_empty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one laundry item'**
  String get laundry_invoice_empty;

  /// No description provided for @laundry_invoice_unavailable_item.
  ///
  /// In en, this message translates to:
  /// **'This invoice contains an inactive or changed item. Remove it and select an active catalog item.'**
  String get laundry_invoice_unavailable_item;

  /// No description provided for @laundry_cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get laundry_cancel_order;

  /// No description provided for @laundry_confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Confirm this order status change?'**
  String get laundry_confirm_action;

  /// No description provided for @laundry_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh order'**
  String get laundry_refresh;

  /// No description provided for @laundry_payment_status.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get laundry_payment_status;

  /// No description provided for @laundry_invoice_status.
  ///
  /// In en, this message translates to:
  /// **'Invoice status'**
  String get laundry_invoice_status;

  /// No description provided for @laundry_customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get laundry_customer;

  /// No description provided for @laundry_empty_orders.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get laundry_empty_orders;

  /// No description provided for @laundry_estimated_total.
  ///
  /// In en, this message translates to:
  /// **'Estimated total before platform fees'**
  String get laundry_estimated_total;

  /// No description provided for @laundry_duplicate_items.
  ///
  /// In en, this message translates to:
  /// **'Combine quantities for the same item and size in one line.'**
  String get laundry_duplicate_items;

  /// No description provided for @laundry_whole_quantity.
  ///
  /// In en, this message translates to:
  /// **'Use a whole number of items.'**
  String get laundry_whole_quantity;

  /// No description provided for @laundry_enable_service.
  ///
  /// In en, this message translates to:
  /// **'Offer Laundry Service'**
  String get laundry_enable_service;

  /// No description provided for @laundry_enable_service_help.
  ///
  /// In en, this message translates to:
  /// **'Enable Laundry, select your service areas, then save this profile. Configure items and prices below before accepting orders.'**
  String get laundry_enable_service_help;

  /// No description provided for @laundry_revenue.
  ///
  /// In en, this message translates to:
  /// **'Laundry revenue'**
  String get laundry_revenue;

  /// No description provided for @laundry_service_disabled_title.
  ///
  /// In en, this message translates to:
  /// **'Laundry is not enabled for customers'**
  String get laundry_service_disabled_title;

  /// No description provided for @laundry_service_disabled_help.
  ///
  /// In en, this message translates to:
  /// **'Prepare your items and prices here, then enable Laundry in Company Profile, select your service areas and save the profile to receive orders.'**
  String get laundry_service_disabled_help;

  /// No description provided for @laundry_admin_products.
  ///
  /// In en, this message translates to:
  /// **'Admin products'**
  String get laundry_admin_products;

  /// No description provided for @laundry_custom_items.
  ///
  /// In en, this message translates to:
  /// **'Your custom items'**
  String get laundry_custom_items;

  /// No description provided for @laundry_unavailable_admin.
  ///
  /// In en, this message translates to:
  /// **'Unavailable — disabled by admin'**
  String get laundry_unavailable_admin;

  /// No description provided for @laundry_edit_prices.
  ///
  /// In en, this message translates to:
  /// **'Edit prices'**
  String get laundry_edit_prices;

  /// No description provided for @laundry_admin_product_help.
  ///
  /// In en, this message translates to:
  /// **'The item and service names are managed by admin. Enable services for this item and enter your prices. Each price must be greater than zero.'**
  String get laundry_admin_product_help;

  /// No description provided for @laundry_use_default_price.
  ///
  /// In en, this message translates to:
  /// **'Use admin default price'**
  String get laundry_use_default_price;

  /// No description provided for @laundry_default_price.
  ///
  /// In en, this message translates to:
  /// **'Admin price'**
  String get laundry_default_price;

  /// No description provided for @laundry_company_price.
  ///
  /// In en, this message translates to:
  /// **'Your price (KWD)'**
  String get laundry_company_price;

  /// No description provided for @laundry_reset_prices.
  ///
  /// In en, this message translates to:
  /// **'Reset all prices to admin defaults'**
  String get laundry_reset_prices;

  /// No description provided for @laundry_send_invoice_confirm.
  ///
  /// In en, this message translates to:
  /// **'Send this invoice to the customer? Items and prices cannot be changed after sending.'**
  String get laundry_send_invoice_confirm;

  /// No description provided for @registrationGiftApplied.
  ///
  /// In en, this message translates to:
  /// **'Registration gift applied • Funded by your company'**
  String get registrationGiftApplied;

  /// No description provided for @registrationGiftAppliedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD registration gift applied • Funded by your company'**
  String registrationGiftAppliedAmount(String amount);

  /// No description provided for @registrationGiftReserved.
  ///
  /// In en, this message translates to:
  /// **'Registration gift reserved • Funded by your company'**
  String get registrationGiftReserved;

  /// No description provided for @registrationGiftReservedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD registration gift reserved • Funded by your company'**
  String registrationGiftReservedAmount(String amount);

  /// No description provided for @campaignDiscountAppliedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD discount applied'**
  String campaignDiscountAppliedAmount(String amount);

  /// No description provided for @campaignDiscountReservedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD discount reserved'**
  String campaignDiscountReservedAmount(String amount);

  /// No description provided for @campaignCashbackAppliedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD cashback applied'**
  String campaignCashbackAppliedAmount(String amount);

  /// No description provided for @campaignCashbackReservedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KD cashback reserved'**
  String campaignCashbackReservedAmount(String amount);

  /// No description provided for @laundry_same_day.
  ///
  /// In en, this message translates to:
  /// **'Same Day'**
  String get laundry_same_day;

  /// No description provided for @laundry_same_day_help.
  ///
  /// In en, this message translates to:
  /// **'Offer same-day service for orders booked before your cutoff time. Orders booked at or after the cutoff are not eligible.'**
  String get laundry_same_day_help;

  /// No description provided for @laundry_same_day_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable same-day service'**
  String get laundry_same_day_enable;

  /// No description provided for @laundry_same_day_cutoff.
  ///
  /// In en, this message translates to:
  /// **'Booking cutoff'**
  String get laundry_same_day_cutoff;

  /// No description provided for @laundry_same_day_select_cutoff.
  ///
  /// In en, this message translates to:
  /// **'Set booking cutoff'**
  String get laundry_same_day_select_cutoff;

  /// No description provided for @laundry_same_day_kuwait_time.
  ///
  /// In en, this message translates to:
  /// **'Kuwait time (24-hour format)'**
  String get laundry_same_day_kuwait_time;

  /// No description provided for @laundry_same_day_cutoff_required.
  ///
  /// In en, this message translates to:
  /// **'Choose a booking cutoff before enabling same-day service.'**
  String get laundry_same_day_cutoff_required;

  /// No description provided for @laundry_same_day_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load same-day settings. Please try again.'**
  String get laundry_same_day_load_error;

  /// No description provided for @laundry_same_day_save_error.
  ///
  /// In en, this message translates to:
  /// **'Settings were not saved. Please try again.'**
  String get laundry_same_day_save_error;

  /// No description provided for @laundry_same_day_saved.
  ///
  /// In en, this message translates to:
  /// **'Same-day settings saved'**
  String get laundry_same_day_saved;

  /// No description provided for @laundry_shared_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get laundry_shared_services;

  /// No description provided for @laundry_item_service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get laundry_item_service;

  /// No description provided for @laundry_shared_services_help.
  ///
  /// In en, this message translates to:
  /// **'Enable the services you offer for this item and set each price. Service names are shared and managed by admin.'**
  String get laundry_shared_services_help;

  /// No description provided for @laundry_no_shared_services.
  ///
  /// In en, this message translates to:
  /// **'No services have been created by admin yet.'**
  String get laundry_no_shared_services;

  /// No description provided for @laundry_item_needs_service.
  ///
  /// In en, this message translates to:
  /// **'Enable and price at least one service before this item appears to customers.'**
  String get laundry_item_needs_service;

  /// No description provided for @laundry_legacy_pricing_help.
  ///
  /// In en, this message translates to:
  /// **'Existing item prices and options remain bookable when these services are off. Turn off the item to stop all bookings.'**
  String get laundry_legacy_pricing_help;

  /// No description provided for @laundry_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get laundry_category;

  /// No description provided for @laundry_all_categories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get laundry_all_categories;

  /// No description provided for @laundry_uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get laundry_uncategorized;

  /// No description provided for @laundry_search_items.
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get laundry_search_items;

  /// No description provided for @laundry_no_matching_items.
  ///
  /// In en, this message translates to:
  /// **'No items match this category or search.'**
  String get laundry_no_matching_items;

  /// No description provided for @laundry_catalog_setup_needed.
  ///
  /// In en, this message translates to:
  /// **'Enable and price items in your Laundry catalog before creating an invoice.'**
  String get laundry_catalog_setup_needed;

  /// No description provided for @laundry_bag_items_help.
  ///
  /// In en, this message translates to:
  /// **'Bag pickup — inspect the collected laundry, then add its items and services to the invoice.'**
  String get laundry_bag_items_help;

  /// No description provided for @laundry_invoice_category_help.
  ///
  /// In en, this message translates to:
  /// **'Choose a category to find items faster. Changing it only resets this invoice line.'**
  String get laundry_invoice_category_help;

  /// No description provided for @laundry_invoice_invalid_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount cannot exceed the items and collection/delivery fees.'**
  String get laundry_invoice_invalid_discount;

  /// No description provided for @laundry_invoice_estimate_help.
  ///
  /// In en, this message translates to:
  /// **'The server confirms current prices and platform fees when you save.'**
  String get laundry_invoice_estimate_help;

  /// No description provided for @laundry_company_price_required.
  ///
  /// In en, this message translates to:
  /// **'Enter a company price'**
  String get laundry_company_price_required;

  /// No description provided for @laundry_reload_invoice.
  ///
  /// In en, this message translates to:
  /// **'Reload saved invoice'**
  String get laundry_reload_invoice;

  /// No description provided for @laundry_reload_invoice_confirm.
  ///
  /// In en, this message translates to:
  /// **'Discard your unsaved invoice changes and review the latest saved invoice?'**
  String get laundry_reload_invoice_confirm;

  /// No description provided for @laundry_manage_catalog.
  ///
  /// In en, this message translates to:
  /// **'Manage Laundry catalog'**
  String get laundry_manage_catalog;

  /// No description provided for @laundry_configuration.
  ///
  /// In en, this message translates to:
  /// **'Laundry Configuration'**
  String get laundry_configuration;

  /// No description provided for @laundry_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get laundry_working_hours;

  /// No description provided for @laundry_pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get laundry_pricing;

  /// No description provided for @laundry_configuration_help.
  ///
  /// In en, this message translates to:
  /// **'Set your working hours, booking availability and item prices.'**
  String get laundry_configuration_help;

  /// No description provided for @laundry_working_hours_help.
  ///
  /// In en, this message translates to:
  /// **'Choose when customers can book a pickup. Hours repeat each week in Kuwait time.'**
  String get laundry_working_hours_help;

  /// No description provided for @laundry_available.
  ///
  /// In en, this message translates to:
  /// **'Available for bookings'**
  String get laundry_available;

  /// No description provided for @laundry_availability_help.
  ///
  /// In en, this message translates to:
  /// **'When switched off, customers see Fully booked and cannot book your company.'**
  String get laundry_availability_help;

  /// No description provided for @laundry_settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Laundry settings saved'**
  String get laundry_settings_saved;

  /// No description provided for @laundry_settings_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load laundry settings. Please try again.'**
  String get laundry_settings_load_error;

  /// No description provided for @laundry_hours_invalid.
  ///
  /// In en, this message translates to:
  /// **'Each time slot must end after it starts, without overlapping another slot on the same day. Use a separate slot on the next day for overnight hours. Use no more than 168 time slots per week.'**
  String get laundry_hours_invalid;

  /// No description provided for @laundry_hours_unrestricted.
  ///
  /// In en, this message translates to:
  /// **'No working hours have been set yet. Bookings are currently allowed all week. Edit the days below to limit pickup times.'**
  String get laundry_hours_unrestricted;

  /// No description provided for @laundry_day_open.
  ///
  /// In en, this message translates to:
  /// **'Open for pickups'**
  String get laundry_day_open;

  /// No description provided for @laundry_day_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed for pickups'**
  String get laundry_day_closed;

  /// No description provided for @laundry_minimum_charge.
  ///
  /// In en, this message translates to:
  /// **'Minimum order amount'**
  String get laundry_minimum_charge;

  /// No description provided for @laundry_minimum_charge_help.
  ///
  /// In en, this message translates to:
  /// **'Customers must add enough items to reach this amount. Pickup and delivery fees do not count. Bag pickups can be booked without items, but the invoice must meet this minimum before sending. Set 0 for no minimum.'**
  String get laundry_minimum_charge_help;

  /// No description provided for @laundry_minimum_charge_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount from 0 to 100000 KWD with up to 3 decimal places.'**
  String get laundry_minimum_charge_invalid;

  /// No description provided for @laundry_minimum_invoice_help.
  ///
  /// In en, this message translates to:
  /// **'Add enough items to reach the minimum before sending. Fees do not count; you can still save a draft.'**
  String get laundry_minimum_invoice_help;

  /// No description provided for @laundry_items_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Items subtotal'**
  String get laundry_items_subtotal;

  /// No description provided for @laundry_catalog_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading invoice items…'**
  String get laundry_catalog_loading;

  /// No description provided for @laundry_catalog_load_timeout.
  ///
  /// In en, this message translates to:
  /// **'Loading items took too long. Check your connection and try again. Your changes are kept.'**
  String get laundry_catalog_load_timeout;

  /// No description provided for @laundry_catalog_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load the item list. Try again. Your changes are kept.'**
  String get laundry_catalog_load_error;

  /// No description provided for @laundry_bulk_prices.
  ///
  /// In en, this message translates to:
  /// **'Update multiple prices'**
  String get laundry_bulk_prices;

  /// No description provided for @laundry_bulk_prices_help.
  ///
  /// In en, this message translates to:
  /// **'Edit prices and item availability, then save all your changes together. Service availability stays the same.'**
  String get laundry_bulk_prices_help;

  /// No description provided for @laundry_bulk_prices_save.
  ///
  /// In en, this message translates to:
  /// **'Save all changes'**
  String get laundry_bulk_prices_save;

  /// No description provided for @laundry_bulk_prices_error.
  ///
  /// In en, this message translates to:
  /// **'Could not save the changes. Your edits are kept. Please try again.'**
  String get laundry_bulk_prices_error;

  /// No description provided for @laundry_bulk_prices_unsaved.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes to prices or item availability.'**
  String get laundry_bulk_prices_unsaved;

  /// No description provided for @laundry_bulk_prices_limit.
  ///
  /// In en, this message translates to:
  /// **'Update up to 200 items at a time. Save these changes before editing more items.'**
  String get laundry_bulk_prices_limit;

  /// No description provided for @laundry_bulk_prices_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price from 0.001 to 10,000 KWD, using up to 3 decimal places.'**
  String get laundry_bulk_prices_invalid;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
