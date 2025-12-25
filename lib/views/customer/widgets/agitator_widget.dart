import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../utils/constants.dart';

class AgitatorWidget extends StatelessWidget {
  final FertilizerSiteModel fertilizerSite;
  final bool isMobile;
  const AgitatorWidget({
    super.key,
    required this.fertilizerSite, required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getAgitatorOnOffStatus(fertilizerSite.agitator[0].sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          fertilizerSite.agitator[0].status = int.parse(statusParts[1]);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            (isMobile)
                ? agitatorWidget(true, fertilizerSite)
                : agitatorWidget(false, fertilizerSite),

            if(kIsWeb && !isMobile)...[
              SizedBox(height: fertilizerSite.agitator[0].status==1? 25:90),
              Container(width: 53, height: 1,color: Colors.grey.shade300),
              const SizedBox(height: 3.5),
              Container(width: 53, height: 1,color: Colors.grey.shade300),
            ]
          ],
        );
      },
    );
  }

  Widget agitatorWidget(bool isMobile, FertilizerSiteModel fertilizerSite) {
    final agitator = fertilizerSite.agitator[0];
    final height = agitator.status == 1 ? 99.0 : 34.0;

    Widget content = SizedBox(
      width: 53,
      height: height,
      child: AppConstants.getAsset(
        'agitator',
        agitator.status,
        '',
      ),
    );

    if (isMobile) {
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: content,
      );
    }

    return content;
  }

}