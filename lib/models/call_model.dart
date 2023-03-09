// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum CallEnum {
  startCalling('start calling'),
  calling('calling'),
  stoppedCalling('stopped calling');

  const CallEnum(this.type);
  final String type;
}

extension ConvertCall on String {
  CallEnum toEnum() {
    switch (this) {
      case 'start calling':
        return CallEnum.startCalling;
      case 'calling':
        return CallEnum.calling;
      case 'stopped calling':
        return CallEnum.stoppedCalling;
      default:
        return CallEnum.startCalling;
    }
  }
}

class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerPic;
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final CallEnum status;
  final String roomId;
  
  CallModel({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.callId,
    required this.status,
    required this.roomId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPic': receiverPic,
      'status': status.type,
      'roomId': roomId,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'] as String,
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      callerPic: map['callerPic'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPic: map['receiverPic'] as String,
      status: (map['status'] as String).toEnum(),
      roomId: map['roomId'] as String
    );
  }

  String toJson() => json.encode(toMap());

  factory CallModel.fromJson(String source) => CallModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
