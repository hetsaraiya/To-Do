import 'package:flutter/material.dart';
import 'package:todoapp/Widgets/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:todoapp/ad_helper.dart';

class CookiesPage extends StatefulWidget {
  const CookiesPage({super.key});

  @override
  State<CookiesPage> createState() => _CookiesPageState();
}

class _CookiesPageState extends State<CookiesPage> {
  String netflixUrl = "http://netflix.com";
  String semrushUrl = "http://semrush.com";
  BannerAd? _bannerAd;

  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              const CookiesPage();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          // ignore: avoid_print
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  

  _launchURL(String urls) async {
    _interstitialAd?.show();
    final Uri url = Uri.parse(urls); // Add http:// or https://
    // ignore: deprecated_member_use
    if (!await canLaunch(url.toString())) {
      throw Exception('Could not launch $url');
    }
    // ignore: deprecated_member_use
    await launch(url.toString());
  }

  @override
  void initState() {
    _loadInterstitialAd();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 2, 250, 221),
      appBar: customAppBar(),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(left: 25, right: 25, top: 50),
              height: 500,
              width: 300,
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () => _launchURL(
                          "https://hetsaraiya.page.link/netflix"),
                      child: const Text(
                        "Netflix",
                        style: TextStyle(color: Colors.cyanAccent),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () => _launchURL(
                          "https://hetsaraiya.page.link/semrush"),
                      child: const Text(
                        "SEMRush",
                        style: TextStyle(color: Colors.cyanAccent),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () => _launchURL(
                          "https://hetsaraiya.page.link/Udemy"),
                      child: const Text(
                        "Udemy",
                        style: TextStyle(color: Colors.cyanAccent),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  // ElevatedButton(
                  //     onPressed: () => _launchURL("https://netflix.com"),
                  //     child: const Text(
                  //       "ChrunchyRoll",
                  //       style: TextStyle(color: Colors.cyanAccent),
                  //     )),
                  // const SizedBox(
                  //   height: 30,
                  // ),
                  // ElevatedButton(
                  //     onPressed: () => _launchURL("https://netflix.com"),
                  //     child: const Text(
                  //       "Netflix",
                  //       style: TextStyle(color: Colors.cyanAccent),
                  //     ))
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ))
        ],
      ),
    );
  }
}
