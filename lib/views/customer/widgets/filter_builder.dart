import 'package:flutter/cupertino.dart';

import '../../../models/customer/site_model.dart';
import '../home_sub_classes/filter_site.dart';

List<Widget> buildFilter (BuildContext context, List<FilterSiteModel> filterSite, bool isFrtAvail) {
  return filterSite.expand((site) => [
    if (site.pressureIn != null)
      Padding(
        padding: EdgeInsets.only(top: isFrtAvail? 38.5:8),
        child: PressureSensorWidget(sensor: site.pressureIn!),
      ),
    ...site.filters.map((filter) => Padding(
      padding: EdgeInsets.only(top: isFrtAvail? 38.5:8),
      child: FilterWidget(filter: filter, siteSno: site.sNo.toString()),
    )),
    if (site.pressureOut != null)
      Padding(
        padding: EdgeInsets.only(top: isFrtAvail? 38.5:8),
        child: PressureSensorWidget(sensor: site.pressureOut!),
      ),
  ]).toList();
}