import 'package:flutter/material.dart';

class RelayStatusAvatar extends StatelessWidget {
  final int? status;
  final int? rlyNo;
  final String? objType;

  const RelayStatusAvatar({
    super.key,
    required this.status,
    required this.rlyNo,
    required this.objType,
  });

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.black12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: _getStatusColor(status!),
      child: Text(
        getLabel(objType, rlyNo),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  String getLabel(String? objType, int? rlyNo) {
    final no = (rlyNo ?? 0).toString();
    if (objType == "1,2") {
      return 'RL-$no';
    }else if (objType == "3") {
      return 'Ai-$no';
    }else if (objType == "4") {
      return 'Di-$no';
    }else if (objType == "5") {
      return 'Mi-$no';
    }else if (objType == "6") {
      return 'Pi-$no';
    }else if (objType == "7") {
      return 'i2c-$no';
    }
    return 'PmI-$no';
  }
}