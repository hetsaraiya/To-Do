import 'package:flutter/material.dart';
import 'package:todoapp/Widgets/todo_container.dart';
import 'package:todoapp/constants/api.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todoapp/Widgets/app_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:pie_chart/pie_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:todoapp/ad_helper.dart';
import 'package:todoapp/pages/cookies.dart';


import '../Models/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double done = 0;
  List<Todo> myTodos = [];
  bool isLoading = true;
  BannerAd? _bannerAd;

  InterstitialAd? _interstitialAd;
  final requestConfiguration = RequestConfiguration(
    testDeviceIds: <String>["E1509048A26CF3A6C24B07B44796AC4A"],
  );

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _HomePageState();
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

  fetchdata() async {
    try {
      http.Response response = await http.get(Uri.parse(api));
      var data = json.decode(response.body);
      data.forEach((todo) {
        Todo t = Todo(
          id: todo['id'],
          title: todo['title'],
          desc: todo['desc'],
          isDone: todo['isDone'],
          date: todo['date'],
        );
        if (todo['isDone']) {
          done += 1;
        }
        myTodos.add(t);
      });
      // ignore: avoid_print
      print(myTodos.length);
      setState(() {
        isLoading = false;
      });
      _loadInterstitialAd();
    } catch (e) {
      print("Error is $e");
    }
  }

  // ignore: non_constant_identifier_names
  void delete_todo(String id) async {
    try {
      // ignore: unused_local_variable, prefer_interpolation_to_compose_strings
      http.Response response = await http.delete(Uri.parse(api + "/" + id));
      _interstitialAd?.show();
      setState(() {
        myTodos = [];
      });
      fetchdata();
    } catch (e) {
      print(e);
    }
  }

  // void post_data({String title = "", String desc = ""}) async {
  //   try {
  //     http.Response response = await http.post(Uri.parse(api),
  //         headers: <String, String>{
  //           'content-type': 'application/json; charset=utf-8'
  //         },
  //         body: jsonEncode(<String, dynamic>{
  //           'title': title,
  //           'desc': desc,
  //         }));
  //     if (response.statusCode == 201) {
  //       _interstitialAd?.show();
  //       setState(() {
  //         myTodos = [];

  //       });
  //       fetchdata();
  //     } else {
  //       print(response.statusCode);
  //     }
  //   } catch (e) {}
  // }
  // ignore: non_constant_identifier_names
  void post_data(
      {String title = "",
      String desc = "",
      required BuildContext context}) async {
    try {
      http.Response response = await http.post(Uri.parse(api),
          headers: <String, String>{
            'content-type': 'application/json; charset=utf-8'
          },
          body: jsonEncode(<String, dynamic>{
            'title': title,
            'desc': desc,
          }));
      if (response.statusCode == 201) {
        _interstitialAd?.show();
        setState(() {
          myTodos = [];
        });
        fetchdata();

        // Close the modal sheet
        Navigator.pop(context);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  void showModel() {
    String title = "";
    String desc = "";
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'Add Your ToDo',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        desc = value;
                      });
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'description'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        post_data(title: title, desc: desc, context: context),
                    child: const Text('Add TodDo'),
                  )
                ],
              ),
            ),
          );
        });
  }

  

  @override
  void initState() {
    fetchdata();

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
        children: <Widget>[
          Center(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CookiesPage()));
                  },
                  child: const Text('Cookies'))),
          PieChart(
            dataMap: {
              "Done": done,
              "Incomplete": (myTodos.length - done).toDouble()
            },
          ),
          isLoading
              ? Container(
                  padding: const EdgeInsets.all(50),
                  child: const CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView(
                      shrinkWrap: true,
                      children: myTodos
                          .map((e) => TodoContainer(
                              onPresss: () => delete_todo(e.id.toString()),
                              id: e.id,
                              title: e.title,
                              desc: e.desc,
                              isDone: e.isDone))
                          .toList()),
                ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModel();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
