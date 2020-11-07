import 'dart:ui';
import 'package:entropy_client/constants.dart';
import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phone_number/phone_number.dart' as phoneNoParser;
import '../showToastWithMessage.dart';
import '../loadingPage.dart';
import '../services/sendSms.dart';
import 'contactPageWidgets.dart';
import 'saveAndReadContacts.dart';
import '../main.dart' show AppLocalizations;

/// Deals with contacts
/// 
/// This is the page where you see, add or remove "close" contacts
/// 
/// Author: David Pescariu @davidp-ro

Map<String, String> contacts = Map<String, String>();

/// Export the contacts [Map] for the sms sender
///
/// Returns [Map] - [contacts] with the contacts
Future<Map<String, String>> exportContacts() async {
  if (contacts == {}) {
    String contactsRaw = await readContacts();
    contactsRaw = contactsRaw.substring(1, contactsRaw.length - 1);
    List<String> _contacts = contactsRaw.split(',');

    _contacts.forEach((contact) {
      if (contact.substring(0, 2) == "To") {
        // The demo card, just add it, no formatting
        contacts[contact.split(":")[0]] = contact.split(":")[1];
      } else {
        contacts[contact.split(":")[0].trim()] = contact.split(":")[1].trim();
      }
    });
  }

  return contacts;
}

/***************************** "Private" methods ******************************/

/// Open the dialer with a given phone number
///
/// Param [phoneNumber] - [String] the phone number
Future<void> _openDialerWithNumber(phoneNumber) async {
  var url = "tel:" + phoneNumber;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showToastWithMessage("$phoneNumber is invalid!");
  }
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  ContactPicker contactPicker = new ContactPicker();
  var built = false;

  /// Get saved contacts and adds them to the [contacts]
  ///
  /// The contacts get added to the [Map] formatted, unless if the
  /// first saved contact is the demo one, then it won't format it.
  _getContacts() async {
    String contactsRaw = await readContacts();
    contactsRaw = contactsRaw.substring(1, contactsRaw.length - 1);
    List<String> _contacts = contactsRaw.split(',');

    _contacts.forEach((contact) {
      if (contact.substring(0, 2) == "To") {
        // The demo card, just add it, no formatting
        contacts[contact.split(":")[0]] = contact.split(":")[1];
      } else {
        contacts[contact.split(":")[0].trim()] = contact.split(":")[1].trim();
      }
    });
  }

  /// Save [contacts] to the contact file
  _saveContacts() async {
    await writeContacts(contacts.toString());
  }

  /// Add a contact
  ///
  /// Param [contact] - [Contact] the contact that gets added
  /// If it is null then just display a toast, otherwise add
  /// it with the phone number trimmed
  _addContact(Contact contact) async {
    if (contact == null) {
      return showToastWithMessage("No contact selected!");
    } else {
      var name = contact.fullName;
      var phone = contact.phoneNumber.toString().trim();

      /// Using Regex to remove the () part of the number, then replacing
      /// the whitespace that's still there so we can keep consistency.
      RegExp typeOfContact = new RegExp(r"\([^()]*\)");
      int foundIndex = typeOfContact.firstMatch(phone).start;
      phone = phone.substring(0, foundIndex).replaceAll(" ", "");

      if (phone.length == 10) {
        // Number is already 10 digits, huray!
        contacts[name] = phone;
      } else if (phone.length > 10) {
        // Number sucks
        try {
          phoneNoParser.PhoneNumber phoneParser = phoneNoParser.PhoneNumber();
          Map<dynamic, dynamic> parsed = await phoneParser.parse(phone);
          contacts[name] = parsed["national"].toString().replaceAll(" ", "");
        } catch (e) {
          // phoneParser failed, big surprize, try manually getting the last 10 digits:
          contacts[name] = phone.substring(phone.length - 10);
        }
      } else {
        showToastWithMessage("Invalid phone number! See FAQ");
      }
    }
  }

  /// Remove a contact
  ///
  /// Param [index] - [int] The index of the contact that gets removed
  _removeContact(int index) {
    final key = contacts.keys.elementAt(index);
    contacts.remove(key);
  }

  /// Open the dialer with the number pre-dialed for a contact
  ///
  /// Param [index] - [int] The index of the contact that gets pre-dialed
  _callContact(int index) {
    final phoneNumber = contacts.values.elementAt(index);
    _openDialerWithNumber(phoneNumber);
  }

  /// Using [FutureBuilder] and showing a loading screen while loading
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _getContacts(),
        builder: (context, snapshot) {
          if (contacts.length > 0) {
            return new Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [GRADIENT_START, GRADIENT_END],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.5, 0.5),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: new Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: new AppBar(
                      leading: new IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: new Text(
                        AppLocalizations.of(context).translate('contact-title'),
                        style: TextStyle(
                            fontFamily: FONT_FAMILY,
                            fontWeight: FontWeight.normal),
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.transparent),
                  body: new Column(
                    children: <Widget>[
                      new Expanded(
                        child: new ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: _itemBuilder,
                        ),
                      ),
                      new ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new SendTestSMS(
                            onPressed: () => handleSMSCall("test"),
                          ),
                          new AddButton(onPressed: () async {
                            _addContact(await contactPicker.selectContact());
                            _saveContacts();
                            setState(() {});
                          }),
                        ],
                      )
                    ],
                  ),
                ));
          } else {
            return LoadingPage();
          }
        });
  }

  /// Builds the ListView with the contacts
  ///
  /// Params [context] and [index] given by [itemBuilder] in [ListView.builder]
  // ignore: missing_return, Intentional because of conditional building
  Widget _itemBuilder(BuildContext context, int index) {
    if (!built) {
      if (index == contacts.length) {
        built = true;
      } else {
        return new InkWell(
          child: new ContactCard(
            contactName: contacts.keys.elementAt(index),
            contactPhone: contacts.values.elementAt(index),
            onPressedSmsStatus: () {
              if (contacts.keys.elementAt(index).substring(0, 2) == "To") {
                // The demo card
                showToastWithMessage(
                    "You would use this button to call a contact");
              } else {
                _callContact(index);
              }
            },
            onPressedRemove: () {
              if (contacts.keys.elementAt(index).substring(0, 2) == "To" &&
                  contacts.length == 1) {
                // The demo card is the only card present
                showToastWithMessage(
                    "Please add a new contact before removing me");
              } else {
                _removeContact(index);
                _saveContacts();
                setState(() {});
              }
            },
          ),
        );
      }
    }
  }
}
