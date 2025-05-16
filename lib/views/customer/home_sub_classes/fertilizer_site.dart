import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
 import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/duration_notifier.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../utils/constants.dart';


class FertilizerSiteView extends StatelessWidget {
  final FertilizerSiteModel fertilizerSite;
  final int siteIndex;
  const FertilizerSiteView({super.key, required this.fertilizerSite, required this.siteIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if(siteIndex!=0)
                  SizedBox(
                    width: 4.5,
                    height: 120,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 42),
                          child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                        ),
                        const SizedBox(width: 4.5,),
                        Padding(
                          padding: const EdgeInsets.only(top: 45),
                          child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                        ),
                      ],
                    ),
                  ),
                BoosterWidget(fertilizerSite: fertilizerSite),
                SizedBox(
                  width: fertilizerSite.channel.length * 70,
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fertilizerSite.channel.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ChannelWidget(channel: fertilizerSite.channel[index], cIndex: index,
                        channelLength: fertilizerSite.channel.length,
                        agitator:  fertilizerSite.agitator, siteSno: fertilizerSite.sNo.toString(),);
                    },
                  ),
                ),
                fertilizerSite.agitator.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: fertilizerSite.agitator.map<Widget>((agitator) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 59,
                          height: 34,
                          child: AppConstants.getAsset('agitator', agitator.status, '',),
                        ),
                        Center(child: Text(agitator.name, style: const TextStyle(fontSize: 10, color: Colors.black54),)),
                      ],
                    );
                  }).toList(), // Convert the map result to a list of widgets
                ):
                const SizedBox(),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            width: (fertilizerSite.channel.length * 79 + fertilizerSite.agitator.length*59)+50,
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                  child: Row(
                    children: [
                      if(siteIndex!=0)
                        const Row(
                          children: [
                            VerticalDivider(width: 0,color: Colors.black12),
                            SizedBox(width: 4.0,),
                            VerticalDivider(width: 0,color: Colors.black12),
                          ],
                        ),
                      Row(
                        children: [
                          const SizedBox(width: 10.5,),
                          const VerticalDivider(width: 0,color: Colors.black12),
                          const SizedBox(width: 4.0,),
                          const VerticalDivider(width: 0,color: Colors.black12),
                          const SizedBox(width: 5.0,),

                          fertilizerSite.ec!.isNotEmpty || fertilizerSite.ph!.isNotEmpty?
                          SizedBox(
                            width: fertilizerSite.ec!.length > 1 ? 110 : 60,
                            height: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fertilizerSite.ec!.isNotEmpty?
                                SizedBox(
                                  height: 12,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerSite.ec!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Center(
                                              child: Text(
                                                'Ec : ',
                                                style: TextStyle(
                                                    fontSize: 10, fontWeight: FontWeight.normal),
                                              )),
                                          Center(
                                            child: Text(
                                              double.parse(
                                                  fertilizerSite.ec![index].value)
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ):
                                const SizedBox(),

                                fertilizerSite.ph!.isNotEmpty?
                                SizedBox(
                                  height: 12,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerSite.ph!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        children: [
                                          const Center(
                                              child: Text(
                                                'pH : ',
                                                style: TextStyle(
                                                    fontSize: 10, fontWeight: FontWeight.normal),
                                              )),
                                          Center(
                                            child: Text(
                                              double.parse(
                                                  fertilizerSite.ph![index].value)
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ):
                                const SizedBox(),
                              ],
                            ),
                          ):
                          const SizedBox(),

                          SizedBox(
                            width: (fertilizerSite.channel.length * 67)+40 - (fertilizerSite.ec!.isNotEmpty ?
                            fertilizerSite.ec!.length * 70 : fertilizerSite.ph!.length * 70),
                            child: Center(
                              child: Text(fertilizerSite.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11),),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isTimeFormat(String value) {
    final timeRegExp = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d:[0-5]\d$');
    return timeRegExp.hasMatch(value);
  }
}

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

        return SizedBox(
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
              ],
            )
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

        return SizedBox(
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
        );
      },
    );
  }
}
