class Result {
  String? vid;
  String? audioName;
  String? thumbnail;
  String? kMp3;
  // String? kMp4_1080p;
  // String? kMp4_720p;
  // String? kMp4_480p;
  // String? kMp4_360p;
  // String? kMp4_144p;
  String? kMp4_auto;

  Result({
    this.vid,
    this.audioName,
    this.thumbnail,
    this.kMp3,
    // this.kMp4_1080p,
    // this.kMp4_720p,
    // this.kMp4_480p,
    // this.kMp4_360p,
    // this.kMp4_144p,
    this.kMp4_auto,
  });

  Result.convertResult(String input) {
    vid = RegExp(r'"vid":"([A-Za-z0-9_-]+)"').firstMatch(input)?.group(1)!;
    audioName = RegExp(r'"title":"([^"]+)"').firstMatch(input)?.group(1);
    thumbnail =
        "https://i.ytimg.com/vi/${RegExp(r'"vid":"([A-Za-z0-9_-]+)"').firstMatch(input)?.group(1)!}/0.jpg";
    kMp3 = RegExp(r'"k":"(\S+)"')
        .firstMatch(RegExp(r'"mp3128":{.*?}').firstMatch(input)?.group(0) ?? '')
        ?.group(1)
        ?.replaceAll("\\/", "/")
        .replaceAll('"', "");
    // kMp4_1080p = RegExp(r'"k":"(\S+)"')
    //     .firstMatch(RegExp(r'"299":{.*?}').firstMatch(input)?.group(0) ?? '')
    //     ?.group(1)
    //     ?.replaceAll("\\/", "/")
    //     .replaceAll('"', "");
    // kMp4_720p = RegExp(r'"k":"(\S+)"')
    //     .firstMatch(RegExp(r'"160":{.*?}').firstMatch(input)?.group(0) ?? '')
    //     ?.group(1)
    //     ?.replaceAll("\\/", "/")
    //     .replaceAll('"', "");
    // kMp4_480p = RegExp(r'"k":"(\S+)"')
    //     .firstMatch(RegExp(r'"135":{.*?}').firstMatch(input)?.group(0) ?? '')
    //     ?.group(1)
    //     ?.replaceAll("\\/", "/")
    //     .replaceAll('"', "");
    // kMp4_360p = RegExp(r'"k":"(\S+)"')
    //     .firstMatch(RegExp(r'"133":{.*?}').firstMatch(input)?.group(0) ?? '')
    //     ?.group(1)
    //     ?.replaceAll("\\/", "/")
    //     .replaceAll('"', "");
    // kMp4_144p = RegExp(r'"k":"(\S+)"')
    //     .firstMatch(
    //         RegExp(r'"3gp@144p":{.*?}').firstMatch(input)?.group(0) ?? '')
    //     ?.group(1)
    //     ?.replaceAll("\\/", "/")
    //     .replaceAll('"', "");
    kMp4_auto = RegExp(r'"k":"(\S+)"')
        .firstMatch(RegExp(r'"auto":{.*?}').firstMatch(input)?.group(0) ?? '')
        ?.group(1)
        ?.replaceAll("\\/", "/")
        .replaceAll('"', "");
  }
}
