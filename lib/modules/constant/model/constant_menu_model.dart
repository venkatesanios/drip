import '../widget/arrow_tab.dart';

class ConstantMenuModel{
  final int dealerDefinitionId;
  final String parameter;
  ArrowTabState arrowTabState;

  ConstantMenuModel({
    required this.dealerDefinitionId,
    required this.parameter,
    required this.arrowTabState,
  });

  factory ConstantMenuModel.fromJson(data){
    return ConstantMenuModel(
        dealerDefinitionId: data['dealerDefinitionId'],
        parameter: data['parameter'],
        arrowTabState: ArrowTabState.inComplete
    );
  }
}