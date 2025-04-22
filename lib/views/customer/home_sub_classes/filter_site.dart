import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/duration_notifier.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';

class FilterSiteView extends StatelessWidget {
  final FilterSiteModel filterSite;
  const FilterSiteView({super.key, required this.filterSite});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filterSite.pressureIn != null?
            PressureSensorWidget(
              sensor: filterSite.pressureIn!,
            ):
            const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(top: 1.9),
              child: SizedBox(
                height: 91,
                width: filterSite.filters.length * 70,
                child: ListView.builder(
                  itemCount: filterSite.filters.length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return FilterWidget(filter: filterSite.filters[flIndex], siteSno: filterSite.sNo.toString());
                  },
                ),
              ),
            ),
            filterSite.pressureOut != null?
            PressureSensorWidget(
              sensor: filterSite.pressureOut!,
            ):
            const SizedBox(),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(3),
          ),

          width: filterSite.pressureIn != null? filterSite.filters.length * 70+70:
          filterSite.filters.length * 70,
          height: 20,
          child: Center(
            child: Text(filterSite.name, style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 11)),
          ),
        ),
      ],
    );
  }
}

class FilterWidget extends StatelessWidget {
  final Filters filter;
  final String siteSno;
  const FilterWidget({super.key, required this.filter, required this.siteSno});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, Tuple2<String?, String?>>(
      selector: (_, provider) => Tuple2(
        provider.getFilterOnOffStatus(filter.sNo.toString()),
        provider.getFilterOtherData(siteSno),
      ),
      builder: (_, data, __) {
        final status = data.item1;
        final other = data.item2;

        final statusParts = status?.split(',') ?? [];
        if (statusParts.length > 1) {
          filter.status = int.tryParse(statusParts[1]) ?? 0;
        }

        int siteStatus = 0;
        final otherParts = other?.split(',') ?? [];
        if (otherParts.length >= 4) {
          int value = int.parse(otherParts[1]);
          siteStatus = value < 0 ? 0 : value;
          filter.onDelayLeft = otherParts[2];
        }

        return Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: AppConstants.getAsset('filter', filter.status,''),
                ),

                filter.onDelayLeft != '00:00:00' && siteStatus!=0?
                Positioned(
                  top: 55,
                  left: 7.5,
                  child: Container(
                    width: 55,
                    decoration: BoxDecoration(
                      color:Colors.greenAccent,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(color: Colors.grey, width: .50,),
                    ),
                    child: ChangeNotifierProvider(
                      create: (_) => DecreaseDurationNotifier(filter.onDelayLeft),
                      child: Stack(
                        children: [
                          Consumer<DecreaseDurationNotifier>(
                            builder: (context, durationNotifier, _) {
                              return Center(
                                child: Text(durationNotifier.onDelayLeft,
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
            SizedBox(
              width: 70,
              height: 20,
              child: Center(
                child: Text(filter.name, style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PressureSensorWidget extends StatelessWidget {
  final PressureSensor sensor;
  const PressureSensorWidget({
    super.key,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          sensor.value = statusParts[1];
        }

        return Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: SizedBox(
            width: 70,
            height: 70,
            child : Stack(
              children: [
                Image.asset('assets/png/dp_prs_sensor.png',),
                Positioned(
                  top: 42,
                  left: 5,
                  child: Container(
                    width: 60,
                    height: 17,
                    decoration: BoxDecoration(
                      color:Colors.yellow,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(color: Colors.grey, width: .50,),
                    ),
                    child: Center(
                      child: Text('${sensor.value} bar', style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
