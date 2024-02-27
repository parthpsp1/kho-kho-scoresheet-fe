import 'package:url_launcher/url_launcher.dart';

void openLinkedInProfileVarun() async {
  const String linkedInProfileUrl = 'linkedin://profile/varun-pardeshi';

  if (await canLaunchUrl(Uri.parse(linkedInProfileUrl))) {
    await launchUrl(Uri.parse(linkedInProfileUrl));
  } else {
    const String browserUrl = 'https://www.linkedin.com/in/varun-pardeshi';
    if (await canLaunchUrl(Uri.parse(browserUrl))) {
      await launchUrl(Uri.parse(browserUrl));
    } else {
      throw 'Could not launch LinkedIn profile';
    }
  }
}

void openLinkedInProfileParth() async {
  const String linkedInProfileUrl = 'linkedin://profile/parth-s-pujari';

  if (await canLaunchUrl(Uri.parse(linkedInProfileUrl))) {
    await launchUrl(Uri.parse(linkedInProfileUrl));
  } else {
    const String browserUrl = 'https://www.linkedin.com/in/parth-s-pujari';
    if (await canLaunchUrl(Uri.parse(browserUrl))) {
      await launchUrl(Uri.parse(browserUrl));
    } else {
      throw 'Could not launch LinkedIn profile';
    }
  }
}
