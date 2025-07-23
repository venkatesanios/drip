import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
 import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/duration_notifier.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../utils/constants.dart';


class BoosterWidget extends StatelessWidget {
  final FertilizerSiteModel fertilizerSite;
  const BoosterWidget({
    super.key,
    required this.fertilizerSite,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getBoosterPumpOnOffStatus(fertilizerSite.boosterPump[0].sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          fertilizerSite.boosterPump[0].status = int.parse(statusParts[1]);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
                width: 70,
                height: 119,
                child : Stack(
                  children: [
                    AppConstants.getAsset('booster', fertilizerSite.boosterPump[0].status,''),
                    Positioned(
                      top: 70,
                      left: 15,
                      child: fertilizerSite.selector.isNotEmpty ? const SizedBox(
                        width: 50,
                        child: Center(
                          child: Text('Selector' , style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                          ),
                        ),
                      ) :
                      const SizedBox(),
                    ),
                    Positioned(
                      top: 85,
                      left: 18,
                      child: fertilizerSite.selector.isNotEmpty ? Container(
                        decoration: BoxDecoration(
                          color: fertilizerSite.selector[0]['Status']==0? Colors.grey.shade300:
                          fertilizerSite.selector[0]['Status']==1? Colors.greenAccent:
                          fertilizerSite.selector[0]['Status']==2? Colors.orangeAccent:Colors.redAccent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        width: 45,
                        height: 22,
                      ):
                      const SizedBox(),
                    ),
                    //ec&ph
                    Positioned(
                      top: 55,
                      left: 18,
                      child: fertilizerSite.ec!.isNotEmpty ? SizedBox(
                        width: 55,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(child: Text('Ec : ', style: TextStyle(fontSize: 10, color: Colors.black45))),
                            Center(
                              child: Text(
                                double.parse('${fertilizerSite.ec?[0].value}')
                                    .toStringAsFixed(2),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 5,),
                          ],
                        ),
                      ) :
                      const SizedBox(),
                    ),
                    Positioned(
                      top: 68,
                      left: 18,
                      child: fertilizerSite.ph!.isNotEmpty ? SizedBox(
                        width: 55,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(child: Text('pH : ', style: TextStyle(fontSize: 10, color: Colors.black45))),
                            Center(
                              child: Text(
                                double.parse('${fertilizerSite.ph?[0].value}')
                                    .toStringAsFixed(2),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 5,),
                          ],
                        ),
                      ) :
                      const SizedBox(),
                    ),
                  ],
                )
            ),
            if(kIsWeb)...[
              SizedBox(
                width: 70,
                child: Row(
                  children: [
                    const SizedBox(width:10),
                    SizedBox(
                      width:6.5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 1, height: 10,color: Colors.grey.shade300),
                          const SizedBox(width: 3.5),
                          Container(width: 1, height: 6.5,color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                    SizedBox(
                      width:53.5,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Container(width: 53.5, height: 1,color: Colors.grey.shade300),
                          const SizedBox(height: 3.5),
                          Container(width: 53.5, height: 1,color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        );
      },
    );
  }

}

class ChannelWidget extends StatelessWidget {
  final Channel channel;
  final int cIndex, channelLength;
  final List<Agitator> agitator;
  final String siteSno;
  const ChannelWidget({super.key, required this.channel, required this.cIndex,
    required this.channelLength, required this.agitator, required this.siteSno});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, Tuple2<String?, String?>>(
      selector: (_, provider) => Tuple2(
        provider.getChannelOnOffStatus(channel.sNo.toString()),
        provider.getChannelOtherData(channel.sNo.toString()),
      ),
      builder: (_, data, __) {
        final status = data.item1;
        final other = data.item2;

        final statusParts = status?.split(',') ?? [];
        if (statusParts.length > 1) {
          channel.status = int.tryParse(statusParts[1]) ?? 0;
        }

        final otherParts = other?.split(',') ?? [];
        if (otherParts.isNotEmpty) {
          channel.frtMethod = otherParts[1];
          channel.duration = otherParts[2];
          channel.completedDrQ = otherParts[3];
          channel.onTime = otherParts[4];
          channel.offTime = otherParts[5];
          channel.flowRateLpH = otherParts[6];
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              height: 120,
              child: Stack(
                children: [
                  Image.asset(AppConstants.getFertilizerImage(cIndex, channel.status, channelLength, agitator)),
                  Positioned(
                    top: 52,
                    left: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.teal.shade100,
                      child: Text('${cIndex+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      width: 60,
                      child: Center(
                        child: Text(channel.duration, style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 65,
                    left: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      width: 60,
                      child: Center(
                        child: Text('${channel.flowRateLpH}-lph', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),

                  channel.status == 1 && channel.completedDrQ !='00:00:00' ?
                  Positioned(
                    top: 103,
                    left: 0,
                    child: Container(
                      width: 55,
                      decoration: BoxDecoration(
                        color:Colors.greenAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.grey, width: .50,),
                      ),
                      child: ChangeNotifierProvider(
                        create: (_) => IncreaseDurationNotifier(channel.duration, channel.completedDrQ, double.parse(channel.flowRateLpH)),
                        child: Stack(
                          children: [
                            Consumer<IncreaseDurationNotifier>(
                              builder: (context, durationNotifier, _) {
                                return Center(
                                  child: Text(channel.frtMethod=='1' || channel.frtMethod=='3'?
                                  durationNotifier.onCompletedDrQ :
                                  '${durationNotifier.onCompletedDrQ} L',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):
                  const SizedBox(),
                ],
              ),
            ),
            if(kIsWeb)...[
              const SizedBox(height: 4),
              Container(width: 70, height: 1,color: Colors.grey.shade300),
              const SizedBox(height: 3.5),
              Container(width: 70, height: 1,color: Colors.grey.shade300),
            ]
          ],
        );
      },
    );
  }
}

class AgitatorWidget extends StatelessWidget {
  final FertilizerSiteModel fertilizerSite;
  const AgitatorWidget({
    super.key,
    required this.fertilizerSite,
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
            SizedBox(
                width: 53,
                height: 34,
                child : AppConstants.getAsset('agitator', fertilizerSite.agitator[0].status,''),
            ),
            if(kIsWeb)...[
              const SizedBox(height: 90),
              Container(width: 53, height: 1,color: Colors.grey.shade300),
              const SizedBox(height: 3.5),
              Container(width: 53, height: 1,color: Colors.grey.shade300),
            ]
          ],
        );
      },
    );
  }

}
