import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:y2mp3/Models/YouTubeVideo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:toast/toast.dart';
import 'package:dio/dio.dart';

class YoutubeMP3 extends StatefulWidget {
  @override
  _YoutubeMP3State createState() => _YoutubeMP3State();
}

List<String> videoTypes = <String>[
  'Audio - mp3',
  'Video - Auto',
  // 'Video - 1080p',
  // 'Video - 720p',
  // 'Video - 480p',
  // 'Video - 360p',
  // 'Video - 144p'
];

class _YoutubeMP3State extends State<YoutubeMP3> {
  TextEditingController videoURL = new TextEditingController();
  Result? video;
  bool isFetching = false;
  bool fetchSuccess = false;
  bool isDownloading = false;
  bool downloadsuccess = false;
  String status = "Download";
  String progress = "";
  String dropdownVideoType = videoTypes.first;
  String ftype = ".${videoTypes.first.split(" - ")[1]}";

  Map<String, String> headers = {
    "X-Requested-With": "XMLHttpRequest",
  };

  Map<String, String>? body;

  void insertBody(String videoURL) {
    body = {"k_query": videoURL, "q_auto": "0", "hl": "en", "k_page": "home"};
  }

  //----------------------------------Get Video Info

  Future<void> getInfo() async {
    insertBody(videoURL.text);
    setState(() {
      progress = "";
      status = "Download";
      downloadsuccess = false;
      isDownloading = false;
      isFetching = true;
      fetchSuccess = false;
    });
    try {
      var response = await http.post(
          Uri.parse("https://www.y2mate.com/mates/analyzeV2/ajax"),
          body: body,
          headers: headers);

      video = Result.convertResult(response.body);
      if (video?.vid == null) {
        setState(() {
          isDownloading = false;
          status = "";
          downloadsuccess = false;
          fetchSuccess = false;
          isFetching = false;
        });
        Toast.show(
          "Cannot find youtube video.",
          duration: 4,
          webTexColor: Colors.red,
          gravity: Toast.bottom,
        );
      } else {
        setState(() {
          isFetching = false;
          fetchSuccess = true;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isFetching = true;
        fetchSuccess = false;
      });
      Toast.show(
        "Cannot find youtube video.",
        duration: 4,
        webTexColor: Colors.red,
        gravity: Toast.bottom,
      );
    }
  }

  //----------------------------------Get Download Link

  Future<void> directURI(String? vid, String? k, String? ftype) async {
    setState(() {
      isDownloading = true;
      status = "Downloading ...";
    });

    if (ftype != null &&
        (
          // ftype.contains('1080') ||
          //   ftype.contains('720') ||
          //   ftype.contains('480') ||
          //   ftype.contains('360') ||
          //   ftype.contains('144') ||
            ftype.contains('Auto'))) {
      ftype = ".mp4";
    }

    try {
      var bodies = {"vid": vid, "k": k};
      var response = await http.post(
          Uri.parse("https://www.y2mate.com/mates/convertV2/index"),
          body: bodies);
      print(response.body);
      if (response.body.contains("Error:")) {
        Toast.show(
          "Cant Download Now \n Please Try Later ...",
          duration: 4,
          webTexColor: Colors.white,
          gravity: Toast.bottom,
        );
        setState(() {
          isDownloading = false;
        });
        return;
      }

      var directURL = RegExp(r'"dlink":\s*"(.+?)"')
          .firstMatch(response.body)
          ?.group(1)
          ?.replaceAll("\\", "");
      print("File Link :" + directURL!);
      downloadVideo(directURL, video?.audioName, ftype);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      Toast.show(
        "Cannot download video. Please try again later.",
        duration: 2,
        backgroundColor: Colors.red,
        webTexColor: Colors.black,
        gravity: Toast.bottom,
      );
    }
  }

//----------------------------------Download Video
  Future<void> downloadVideo(
      String trackURL, String? trackName, String? format) async {
    try {
      Dio dio = Dio();

      var dir = Directory('/storage/emulated/0/Download/Music');

      if (Platform.isIOS) dir = Directory('~/Downloads/Music');

      if (!(await dir.exists())) await dir.create(recursive: true);

      String? directory = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: dir,
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
        folderIconColor: Colors.teal,
      );

      if (format != null && format.contains("Video")) {
        format = ".mp4";
      }

      print("${directory}/" + trackName! + format!);
      if (directory != null) {
        try {
          var file =
              File("${directory}/" + trackName.replaceAll('.', '') + format);
          if (!file.existsSync()) {
            await dio.download(trackURL,
                "${directory}/" + trackName.replaceAll('.', '') + format,
                onReceiveProgress: (rec, total) {
              setState(() {
                progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
              });
            });
          } else {
            Toast.show(
              "File already exists.",
              duration: 10,
              backgroundColor: Colors.red,
              webTexColor: Colors.black,
              gravity: Toast.bottom,
            );
          }
        } catch (e) {
          await dio.download(trackURL, "${directory}/" + Uuid().v4() + format,
              onReceiveProgress: (rec, total) {
            setState(() {
              progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
            });
          });
        }

        setState(() {
          isDownloading = false;
          status = "";
          downloadsuccess = false;
          fetchSuccess = false;
          isFetching = false;
        });
        Toast.show(
          "Download Completed.",
          duration: 10,
          backgroundColor: Colors.green,
          webTexColor: Colors.black,
          gravity: Toast.bottom,
        );
        videoURL.clear();
      } else {
        setState(() {
          isDownloading = false;
          status = "Download ";
        });
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      Toast.show(
        e.toString(),
        duration: 10,
        backgroundColor: Colors.red,
        webTexColor: Colors.black,
        gravity: Toast.bottom,
      );
    }
  }

  void nothingHere() {
    print("Just Nothing");
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: searchBar(),
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        centerTitle: true,
      ),
      body: bodyPart(),
    );
  }

  Widget bodyPart() {
    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Center(
        child: isFetching
            ? progressScreen()
            : fetchSuccess
                ? downloadScreen()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Youtube MP3/Mp4 Downloader",
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "By Suzan",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Icon(
                        FontAwesomeIcons.youtube,
                        color: Colors.redAccent,
                        size: 45.0,
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget progressScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            'Getting Data ...',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        )
      ],
    );
  }

  String getKType() {
    if (dropdownVideoType.contains("Audio")) return video?.kMp3 ?? '';
    if (dropdownVideoType.contains("Auto")) return video?.kMp4_auto ?? '';
    // if (dropdownVideoType.contains("1080")) return video?.kMp4_1080p ?? '';
    // if (dropdownVideoType.contains("720")) return video?.kMp4_720p ?? '';
    // if (dropdownVideoType.contains("480")) return video?.kMp4_480p ?? '';
    // if (dropdownVideoType.contains("360")) return video?.kMp4_360p ?? '';
    // if (dropdownVideoType.contains("144")) return video?.kMp4_144p ?? '';

    return '';
  }

  Widget downloadScreen() {
    var thumbnail = video?.thumbnail.toString();
    var audioName = video?.audioName.toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          height: 300.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(19.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Image(
                  image: NetworkImage(thumbnail.toString()),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              labelTitle("Title : ", audioName.toString()),
              SizedBox(
                height: 8.0,
              ),
              Container(
                height: 40.0,
                width: 200.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.0,
                    ),
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownVideoType,
                      elevation: 16,
                      alignment: Alignment.center,
                      dropdownColor: Colors.redAccent,
                      underline: Container(
                        height: 2,
                      ),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.redAccent),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownVideoType = value!;
                          ftype = ".${value.split(' - ')[1]}";
                        });
                      },
                      items: videoTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
              ),
              TextButton(
                onPressed: () {
                  !downloadsuccess
                      ? directURI(video?.vid.toString(), getKType(), ftype)
                      : nothingHere();
                },
                child: Container(
                  height: 40.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: downloadsuccess == true
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        5.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        status,
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Icon(
                        isDownloading
                            ? FontAwesomeIcons.spinner
                            : downloadsuccess
                                ? FontAwesomeIcons.check
                                : FontAwesomeIcons.download,
                        color: Colors.black,
                        size: 20.0,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  progress,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget labelTitle(String title, String inpute) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 17.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: Text(
            inpute,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(100, 255, 255, 255),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: TextFormField(
              onFieldSubmitted: (newValue) => {if (newValue != "") getInfo()},
              controller: videoURL,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(20),
                  hintText: "Video URL ...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    onPressed: () {
                      videoURL.clear();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  ),
                  icon: IconButton(
                    onPressed: () {
                      FlutterClipboard.paste().then((value) {
                        videoURL.text = value;
                        if (videoURL.text != "") {
                          getInfo();
                        } else {
                          Toast.show(
                            "Invalid youtube link",
                            duration: 4,
                            webTexColor: Colors.red,
                            gravity: Toast.bottom,
                          );
                        }
                      });
                    },
                    icon: Icon(
                      Icons.paste,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
