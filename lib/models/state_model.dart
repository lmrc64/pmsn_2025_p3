class StateModel {
  int? stateId;
  String? state;

  StateModel({this.stateId, this.state});

  factory StateModel.fromMap(Map<String, dynamic> map) {
    return StateModel(
      stateId: map['state_id'],
      state: map['state'],
    );
  }
}
