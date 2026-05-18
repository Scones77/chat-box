import 'package:backend/models/user_model.dart';
import 'package:flint_dart/model.dart';
import 'package:flint_dart/schema.dart';

class Call extends Model<Call> {
  Call() : super(() => Call());

  String get channelName => getAttribute('channelName');
  String? get conversationId => getAttribute('conversationId');
  String get callerId => getAttribute('callerId');
  String get recipientId => getAttribute('recipientId');
  String get callType => getAttribute('callType');
  String get status => getAttribute('status');
  String? get startedAt => getAttribute('startedAt');
  String? get acceptedAt => getAttribute('acceptedAt');
  String? get endedAt => getAttribute('endedAt');
  String? get durationSeconds => getAttribute('durationSeconds');
  String? get agoraUidCaller => getAttribute('agoraUidCaller');
  String? get agoraUidRecipient => getAttribute('agoraUidRecipient');
  String? get recordingUrl => getAttribute('recordingUrl');
  String? get transcript => getAttribute('transcript');
  User? get caller => getRelation<User>('caller');
  User? get recipient => getRelation<User>('recipient');

  @override
  Map<String, RelationDefinition> get relations => {
        'caller': Relations.belongsTo<User>(
          'caller',
          () => User(),
          foreignKey: 'callerId',
          ownerKey: 'id',
        ),
        'recipient': Relations.belongsTo<User>(
          'recipient',
          () => User(),
          foreignKey: 'recipientId',
          ownerKey: 'id',
        ),
      };

  @override
  Table get table => Table(
        name: 'calls',
        columns: [
          Column(
            name: 'conversationId',
            type: ColumnType.string,
            length: 255,
            isNullable: true,
          ),
          Column(name: 'channelName', type: ColumnType.string, length: 255),
          Column(name: 'callerId', type: ColumnType.string, length: 255),
          Column(name: 'recipientId', type: ColumnType.string, length: 255),
          Column(
            name: 'callType',
            type: ColumnType.string,
            length: 32,
            defaultValue: 'audio',
          ),
          Column(
            name: 'status',
            type: ColumnType.string,
            length: 32,
            defaultValue: 'ringing',
          ),
          Column(name: 'startedAt', type: ColumnType.string, length: 64),
          Column(
            name: 'acceptedAt',
            type: ColumnType.string,
            length: 64,
            isNullable: true,
          ),
          Column(
            name: 'endedAt',
            type: ColumnType.string,
            length: 64,
            isNullable: true,
          ),
          Column(
            name: 'durationSeconds',
            type: ColumnType.string,
            length: 32,
            isNullable: true,
          ),
          Column(
            name: 'agoraUidCaller',
            type: ColumnType.string,
            length: 32,
            isNullable: true,
          ),
          Column(
            name: 'agoraUidRecipient',
            type: ColumnType.string,
            length: 32,
            isNullable: true,
          ),
          Column(
            name: 'recordingUrl',
            type: ColumnType.string,
            isNullable: true,
          ),
          Column(
            name: 'transcript',
            type: ColumnType.text,
            isNullable: true,
          ),
        ],
      );
}
