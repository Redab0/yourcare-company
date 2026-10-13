import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_extra_fees_request.g.dart';

@JsonSerializable(createFactory: false, ignoreUnannotated: true)
class AddExtraFeesRequest extends Equatable {
  @JsonKey()
  final double extraFees;
  @JsonKey()
  final String extraFeesDescription;

  const AddExtraFeesRequest({
    required this.extraFees,
    required this.extraFeesDescription,
  });

  Map<String, dynamic> toJson() => _$AddExtraFeesRequestToJson(this);

  @override
  List<Object?> get props => [extraFees, extraFeesDescription];
}
