import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class JumpNavigation {
  static const MethodChannel _channel = const MethodChannel('jump_navigation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 跳转百度地图导航
  /// 参考文档
  /// Android [http://lbsyun.baidu.com/index.php?title=uri/api/android#service-page-anchor10]
  /// iOS [http://lbsyun.baidu.com/index.php?title=uri/api/ios#service-page-anchor7]
  static Future<bool> navigationWithBaiduMap({
    /// 坐标点，location与query二者必须有一个，当有location时，忽略query；
    /// 可选
    /// 经纬度：39.9761,116.3282
    @required double desLat,
    @required double desLng,

    /// 坐标类型，必选参数。
    /// 示例：
    /// coord_type= bd09ll
    /// 允许的值为：
    /// bd09ll（百度经纬度坐标）
    /// bd09mc（百度墨卡托坐标）
    /// gcj02（经国测局加密的坐标）
    /// wgs84（gps获取的原始坐标）
    /// 如开发者不传递正确的坐标类型参数，会导致地点坐标位置偏移。
    // ignore: non_constant_identifier_names
    String coord_type = 'gcj02',

    /// 搜索key，location与query二者必须有一个，当有location时，忽略query；坐标类型参考通用参数：coord_type。
    String query,

    /// 可选
    /// BLK:躲避拥堵(自驾);
    /// TIME:最短时间(自驾);
    /// DIS:最短路程(自驾);
    /// FEE:少走高速(自驾);
    /// HIGHWAY:高速优先;
    /// DEFAULT:推荐（自驾，地图app不选择偏好）;
    /// 默认:地图app所选偏好
    String type = 'DEFAULT',

    /// 可选 途经点参数，最多支持三个途经点，内容为json格式，需要把内容encode后拼接到url中。未编码的参数内容示例如下，其中name为名称，lat为纬度，lng为经度。支持经纬度和名称+经纬度，经纬度作为导航依据，名称只负责展示。
    /// 名称+经纬度：{"viaPoints": [{"name": "北京西站","lat": 39.902463,"lng": 116.327737},{"name": "北京动物园","lat": 39.945136,"lng": 116.346983},{"name": "清华大学","lat": 40.011006,"lng": 116.338897}]}
    String viaPoints,

    /// 统计来源	必选	 参数格式为：andr.companyName.appName 不传此参数，不保证服务
    /// 表示来源，用于统计	必选  必选参数，格式为：ios.companyName.appName 不传此参数，不保证服务
    String src,
  }) async {
    Map<String, dynamic> params = {};
    if ((desLat ?? 0) != 0 && (desLng ?? 0) != 0) {
      params['location'] = '$desLat,$desLng';
    }
    params['coord_type'] = coord_type;
    if ((query ?? '').length > 0) {
      params['query'] = Uri.encodeFull(query);
    }
    params['type'] = type;
    if ((viaPoints ?? '').length > 0) {
      params['viaPoints'] = Uri.encodeFull(viaPoints);
    }
    if ((src ?? '').length > 0) {
      params['src'] = src;
    }

    /// MARK: 直接使用Uri的API进行转换遇到中文字符串有可能失败,故换为遍历拼接
    String queryString = '';
    for (String key in params.keys) {
      queryString += '$key=${params[key]}&';
    }
    if (queryString.length > 0) {
      queryString = queryString.substring(0, queryString.length - 1);
    }
    String uri = 'baidumap://map/navi';
    uri += '${uri.contains('?') ? '&' : '?'}$queryString';
    /*
    String uri = Uri.parse('baidumap://map/navi')
        .replace(
          queryParameters: params,
        )
        .toString();
     */
    print(uri);
    if (Platform.isAndroid) {
      /// TODO:
    } else if (Platform.isIOS) {
      return _channel.invokeMethod('navigationWithBaiduMap', {"uri": uri});
    }
    return false;
  }

  /// 跳转百度地图路径规划
  /// 参考文档
  /// Android [http://lbsyun.baidu.com/index.php?title=uri/api/android#service-page-anchor9]
  /// iOS [http://lbsyun.baidu.com/index.php?title=uri/api/ios#service-page-anchor6]
  static Future<bool> directionWithBaiduMap({
    /// 终点名称或经纬度，或者可同时提供名称和经纬度，此时经纬度优先级高，将作为导航依据，名称只负责展示。
    /// origin和destination二者至少一个有值（默认值是当前定位地址）
    /// latlng:39.98871,116.43234 (注意：坐标先纬度，后经度)
    /// 名称和经纬度：name:天安门|latlng:39.98871,116.43234|addr:北京市东城区东长安街(注意：坐标先纬度，后经度)
    /// 建筑ID和楼层ID： name:天安门|latlng:39.98871,116.43234|building:10041552286161815796|floor:F1（注意：建筑ID和楼层ID必须同时提供，用于是内步行路线规划）
    /// 注意：仅有名称的情况下，请不要带“name:”，只需要destination=“终点名称”
    @required double desLat,
    @required double desLng,
    String desName = 'desName',

    /// 起点名称或经纬度，或者可同时提供名称和经纬度，此时经纬度优先级高，将作为导航依据，名称只负责展示。如果没有origin的情况下，会使用用户定位的坐标点作为起点
    /// origin和destination二者至少一个有值（默认值是当前定位地址）
    /// latlng:39.98871,116.43234 (注意：坐标先纬度，后经度)
    /// 名称和经纬度：name:天安门|latlng:39.98871,116.43234|addr:北京市东城区东长安街(注意：坐标先纬度，后经度)
    /// 建筑ID和楼层ID： name:天安门|latlng:39.98871,116.43234|building:10041552286161815796|floor:F1（注意：建筑ID和楼层ID必须同时提供，用于是内步行路线规划）
    /// 注意：仅有名称的情况下，请不要带“name:”，只需要origin=“起点名称”
    @required double originLat,
    @required double originLng,
    String originName = '起点',

    /// 坐标类型，必选参数。
    /// 示例：
    /// coord_type= bd09ll
    /// 允许的值为：
    /// bd09ll（百度经纬度坐标）
    /// bd09mc（百度墨卡托坐标）
    /// gcj02（经国测局加密的坐标）
    /// wgs84（gps获取的原始坐标）
    /// 如开发者不传递正确的坐标类型参数，会导致地点坐标位置偏移。
    // ignore: non_constant_identifier_names
    String coord_type = 'gcj02',

    /// 导航模式，
    /// 可选transit（公交）、
    /// driving（驾车）、
    /// walking（步行）和riding（骑行）
    /// 默认:driving
    /// 可选
    String mode = 'driving',

    /// 城市名或县名
    /// 可选
    String region,

    /// 起点所在城市或县
    /// 可选
    // ignore: non_constant_identifier_names
    String origin_region,

    /// 终点所在城市或县
    /// 可选
    // ignore: non_constant_identifier_names
    String destination_region,

    /// 公交检索策略，只针对mode字段填写transit情况下有效，值为数字。
    /// 0：推荐路线
    /// 2：少换乘
    /// 3：少步行
    /// 4：不坐地铁
    /// 5：时间短
    /// 6：地铁优先
    /// 可选
    int sy,

    /// 公交结果结果项，只针对公交检索，值为数字，从0开始
    /// 可选
    int index,

    /// 0 图区，1 详情，只针对公交检索有效
    /// 可选
    /// 默认0
    int target = 0,

    /// 驾车路线规划类型
    /// 可选
    /// BLK:躲避拥堵(自驾);
    /// TIME:最短时间(自驾);
    /// DIS:最短路程(自驾);
    /// FEE:少走高速(自驾);
    /// HIGHWAY:高速优先;
    /// DEFAULT:推荐（自驾，地图app不选择偏好）;
    /// 默认:地图app所选偏好
    // ignore: non_constant_identifier_names
    String car_type = 'DEFAULT',

    /// 途经点参数，最多支持三个途经点，内容为json格式，需要把内容encode后拼接到url中。未编码的参数内容示例如下，其中name为名称，lat为纬度，lng为经度。支持名称或经纬度，或者可同时提供名称和经纬度，此时经纬度优先级高，将作为导航依据，名称只负责展示。只有名称：{"viaPoints": [{"name": "北京西站"},{"name": "北京动物园"},{"name": "清华大学"}]}
    /// 名称+经纬度：{"viaPoints": [{"name": "北京西站","lat": 39.902463,"lng": 116.327737},{"name": "北京动物园","lat": 39.945136,"lng": 116.346983},{"name": "清华大学","lat": 40.011006,"lng": 116.338897}]}
    /// 可选
    /// 10.2新增
    String viaPoints,

    /// 统计来源
    /// 必选
    /// 参数格式为：
    /// Android: andr.companyName.appName
    /// iOS: ios.companyName.appName
    /// 不传此参数，不保证服务
    @required String src,
  }) async {
    Map<String, dynamic> params = {};
    if ((desLat ?? 0) != 0 && (desLng ?? 0) != 0) {
      /// TODO: 根据文档 名字 + 经纬度无法调起APP
//      if ((desName ?? '').length > 0) {
//        params['destination'] =
//            'name:$desName|latlng:$desLat,$desLng|addr:';
//      'name:天安门|latlng:39.98871,116.43234|addr:北京市东城区东长安街';
//      'name:天安门|latlng:39.98871,116.43234';
//      } else {
      params['destination'] = '$desLat,$desLng';
//      }
    }
    if ((originLat ?? 0) != 0 && (originLng ?? 0) != 0) {
//      if ((originName ?? '').length > 0) {
//        params['origin'] =
//            'name:${Uri.encodeFull(desName)}|latlng:$desLat,$desLng';
//      } else {
      params['origin'] = '$originLat,$originLng';
//      }
    }
    if ((coord_type ?? '').length > 0) {
      params['coord_type'] = coord_type;
    }
    if ((mode ?? '').length > 0) {
      params['mode'] = mode;
    }
    if ((region ?? '').length > 0) {
      params['region'] = Uri.encodeFull(region);
    }
    if ((origin_region ?? '').length > 0) {
      params['origin_region'] = Uri.encodeFull(origin_region);
    }
    if ((destination_region ?? '').length > 0) {
      params['destination_region'] = Uri.encodeFull(destination_region);
    }
    if (sy != null) {
      params['sy'] = sy;
    }
    if (index != null) {
      params['index'] = index;
    }
    if (target != null) {
      params['target'] = target;
    }
    if ((car_type ?? '').length > 0) {
      params['car_type'] = car_type;
    }
    if ((viaPoints ?? '').length > 0) {
      params['viaPoints'] = Uri.encodeFull(viaPoints);
    }
    if ((src ?? '').length > 0) {
      params['src'] = src;
    }

    /// MARK: 直接使用Uri的API进行转换遇到中文字符串有可能失败,故换为遍历拼接
    String queryString = '';
    for (String key in params.keys) {
      queryString += '$key=${params[key]}&';
    }
    if (queryString.length > 0) {
      queryString = queryString.substring(0, queryString.length - 1);
    }
    String uri = 'baidumap://map/direction';
    uri += '${uri.contains('?') ? '&' : '?'}$queryString';
    print(uri);
    if (Platform.isAndroid) {
      /// TODO:
    } else if (Platform.isIOS) {
      return _channel.invokeMethod('directionWithBaiduMap', {"uri": uri});
    }
    return false;
  }

  /// 跳转高德地图路径规划
  /// 参考文档: [https://lbs.amap.com/api/uri-api/guide/travel/route]
  static Future<bool> navigationWithAMap({
    /// 终点经纬度坐标， 格式为: position=lon,lat[,name]
    /// 是
    ///（1）lon表示经度，lat表示纬度； （2）起终点信息不可全为空，起点为空则自动传入用户当前的位置信息； 3）自动传入当前位置功能只在移动端生效；（4）endpoint 为地点名称，可自定义；
    @required double desLat,
    @required double desLng,
    String desName = '终点',

    /// 起点经纬度坐标， 格式为: position=lon,lat[,name]
    /// 是
    ///（1）lon表示经度，lat表示纬度； （2）起终点信息不可全为空，起点为空则自动传入用户当前的位置信息； （3）自动传入当前位置功能只在移动端生效；（4）startpoint 为地点名称，可自定义；
    @required double originLat,
    @required double originLng,
    String originName = '起点',

    /// 途径点经纬度坐标， 格式为: position=lon,lat[,name]
    /// 否
    /// 途径点只在驾车模式下有效。
    double viaLat,
    double viaLng,
    String viaName = '途经点',

    /// 出行方式： 驾车：mode=car; 公交：mode=bus； 步行：mode=walk； 骑行：mode=ride；
    /// 否
    /// 缺省mode=car； 骑行仅在移动端有效； 当选择骑行模式时，调起客户端仅对高德地图APP V8.0.0以上版本支持；
    String mode = 'car',

    /// 当mode=car(驾车):0:推荐策略,1:避免拥堵,2:避免收费,3:不走高速（仅限移动端）
    /// 当mode=bus(公交):0:最佳路线,1:换乘少,2:步行少,3:不坐地铁
    /// 否
    /// 缺省policy=0
    int policy = 0,

    /// 使用方来源信息
    /// 否
    /// 为保证服务质量建议填写
    String src,

    /// 坐标系参数coordinate=gaode,表示高德坐标（gcj02坐标），
    /// coordinate=wgs84,表示wgs84坐标（GPS原始坐标）
    /// 否
    /// 默认为高德坐标系（gcj02坐标系）
    String coordinate = 'gaode',

    /// 是否尝试调起高德地图APP并在APP中查看，0表示不调起，1表示调起, 默认值为0
    /// 否
    /// 1、该参数仅在移动端有效，需要保证移动设备中安装了高德地图客户端。（部分第三方平台内置浏览器无法成功调起，例如微信、QQ）；
    /// 2、Android 端通过 webview 实现的浏览器容器需要重写WebViewClient 的 shouldOverrideUrlLoading方法；
    /// 3、当选择骑行模式时，调起功能仅对高德地图APP V8.0.0以上版本支持；
    int callnative = 1,
  }) async {
    Map<String, dynamic> params = {};
    if ((desLat ?? 0) != 0 && (desLng ?? 0) != 0) {
      params['to'] = '$desLng,$desLat,${Uri.encodeFull(desName)}';
    }
    if ((originLat ?? 0) != 0 && (originLng ?? 0) != 0) {
      params['from'] = '$originLng,$originLat,${Uri.encodeFull(originName)}';
    }
    if ((viaLat ?? 0) != 0 && (viaLng ?? 0) != 0) {
      params['via'] = '$viaLng,$viaLat,${Uri.encodeFull(viaName)}';
    }
    params['mode'] = mode;
    params['policy'] = policy;
    if ((src ?? '').length > 0) {
      params['src'] = src;
    }
    params['coordinate'] = coordinate;
    params['callnative'] = callnative;

    /// MARK: 直接使用Uri的API进行转换遇到中文字符串有可能失败,故换为遍历拼接
    String queryString = '';
    for (String key in params.keys) {
      queryString += '$key=${params[key]}&';
    }
    if (queryString.length > 0) {
      queryString = queryString.substring(0, queryString.length - 1);
    }
    String uri = 'https://uri.amap.com/navigation';
    uri += '${uri.contains('?') ? '&' : '?'}$queryString';

    /*
    String uri = Uri.parse('https://uri.amap.com/navigation')
        .replace(
      queryParameters: params,
    )
        .toString();
    */
    print(uri);
    if (Platform.isAndroid) {
      /// TODO:
    } else if (Platform.isIOS) {
      return _channel.invokeMethod('navigationWithAMap', {"uri": uri});
    }
    return false;
  }
}
