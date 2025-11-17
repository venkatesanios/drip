import 'package:flutter/cupertino.dart';

import '../../../models/customer/site_model.dart';
import '../home_sub_classes/filter_site.dart';

List<Widget> buildFilter (BuildContext context, List<FilterSiteModel> filterSite, bool isFrtAvail, bool isMobile) {
  return filterSite.expand((site) => [
    if (site.pressureIn != null)
      Padding(
        padding: EdgeInsets.only(top: isFrtAvail? 38.5 : 0),
        child: PressureSensorWidget(sensor: site.pressureIn!, isMobile: isMobile),
      ),
    ...site.filters.map((filter) => Padding(
      padding: EdgeInsets.only(top: isFrtAvail? 38.5 : 0),
      child: FilterWidget(filter: filter, siteSno: site.sNo.toString(), isMobile: isMobile),
    )),
    if (site.pressureOut != null)
      Padding(
        padding: EdgeInsets.only(top: isFrtAvail? 38.5 : 0),
        child: PressureSensorWidget(sensor: site.pressureOut!, isMobile: isMobile),
      ),
  ]).toList();
}