import 'package:flutter/material.dart';



import '../utils/device_status_colors.dart';



/// 设备点位图标记：底图 + [DeviceStatusColors] 状态叠层（与报到设备列表一致）。

class AttendDeviceMapMarker extends StatelessWidget {

  const AttendDeviceMapMarker({

    super.key,

    required this.width,

    required this.height,

    required this.status,

    required this.processType,

    this.roleLabel,

  });



  final double width;

  final double height;

  final String status;

  final String processType;

  final String? roleLabel;



  static String baseAssetFor(String processType) {

    switch (processType) {

      case 'didian':

        return 'assets/images/didian.png';

      case 'Client':

        return 'assets/images/jsj.png';

      default:

        return 'assets/images/device.png';

    }

  }



  @override

  Widget build(BuildContext context) {

    final asset = baseAssetFor(processType);

    final imageAlign =

        processType == 'didian' ? const Alignment(0, -1.0) : Alignment.center;

    final imageScale = processType == 'didian' ? 1.12 : 1.0;



    return SizedBox(

      width: width,

      height: height,

      child: Stack(

        clipBehavior: Clip.hardEdge,

        fit: StackFit.expand,

        children: [

          Transform.scale(

            scale: imageScale,

            alignment: imageAlign,

            child: Image.asset(

              asset,

              fit: BoxFit.contain,

              filterQuality: FilterQuality.medium,

            ),

          ),

          if (processType == 'didian' && status == '空闲')

            _DidianIdleStrip(width: width, height: height)

          else

            _ScreenStatusOverlay(

              width: width,

              height: height,

              status: status,

              processType: processType,

            ),

          if (roleLabel != null)

            Positioned(

              left: 0,

              right: 0,

              bottom: height * 0.12,

              child: Text(

                roleLabel!,

                textAlign: TextAlign.center,

                style: TextStyle(

                  fontSize: (width * 0.26).clamp(6.0, 8.0),

                  fontWeight: FontWeight.w600,

                  fontFamily: 'Microsoft YaHei',

                  color: const Color(0xFF616161),

                  height: 1,

                  shadows: const [

                    Shadow(color: Colors.white, blurRadius: 2),

                  ],

                ),

              ),

            ),

        ],

      ),

    );

  }

}



/// 状态块叠在显示器「屏幕」区域内，不遮挡整幅底图（与报到设备 jsj 叠层一致）。

class _ScreenStatusOverlay extends StatelessWidget {

  const _ScreenStatusOverlay({

    required this.width,

    required this.height,

    required this.status,

    required this.processType,

  });



  final double width;

  final double height;

  final String status;

  final String processType;



  static ({double left, double right, double top, double bottom})

      _screenInsets(String processType) {

    switch (processType) {

      case 'Client':

        return (left: 0.18, right: 0.18, top: 0.22, bottom: 0.46);

      case 'didian':

        return (left: 0.16, right: 0.16, top: 0.26, bottom: 0.42);

      default:

        return (left: 0.18, right: 0.18, top: 0.22, bottom: 0.44);

    }

  }



  @override

  Widget build(BuildContext context) {

    final inset = _screenInsets(processType);

    final bg = DeviceStatusColors.background(status);

    final fg = DeviceStatusColors.foreground(status);

    final borderW = (height * 0.05).clamp(0.6, 1.2);

    final fontSize = (height * 0.22).clamp(5.0, 10.0);



    return Positioned(

      left: width * inset.left,

      right: width * inset.right,

      top: height * inset.top,

      bottom: height * inset.bottom,

      child: DecoratedBox(

        decoration: BoxDecoration(

          color: bg,

          borderRadius: BorderRadius.circular(2),

          border: Border.all(

            color: Colors.white.withValues(alpha: 0.5),

            width: borderW,

          ),

        ),

        child: Center(

          child: FittedBox(

            fit: BoxFit.scaleDown,

            child: Padding(

              padding: EdgeInsets.symmetric(

                horizontal: width * 0.04,

                vertical: height * 0.02,

              ),

              child: Text(

                status,

                maxLines: 1,

                softWrap: false,

                style: TextStyle(

                  fontSize: fontSize,

                  fontWeight: FontWeight.bold,

                  color: fg,

                  fontFamily: 'Microsoft YaHei',

                  height: 1.0,

                ),

                textAlign: TextAlign.center,

              ),

            ),

          ),

        ),

      ),

    );

  }

}



class _DidianIdleStrip extends StatelessWidget {

  const _DidianIdleStrip({

    required this.width,

    required this.height,

  });



  final double width;

  final double height;



  @override

  Widget build(BuildContext context) {

    final stripH = height * 0.34;

    final fontSize = (stripH * 0.42).clamp(5.0, 10.0);

    const status = '空闲';



    return Positioned(

      left: 0,

      right: 0,

      bottom: 0,

      height: stripH,

      child: DecoratedBox(

        decoration: BoxDecoration(

          color: DeviceStatusColors.background(status),

          border: Border.all(

            color: Colors.white.withValues(alpha: 0.5),

            width: 1,

          ),

        ),

        child: Center(

          child: Text(

            status,

            style: TextStyle(

              fontSize: fontSize,

              fontWeight: FontWeight.bold,

              color: DeviceStatusColors.foreground(status),

              fontFamily: 'Microsoft YaHei',

            ),

            textAlign: TextAlign.center,

          ),

        ),

      ),

    );

  }

}

