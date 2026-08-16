import 'package:equatable/equatable.dart';

class AddExtraFeesRequest extends Equatable {
  final double extraFees;
  final String extraFeesDescription;

  const AddExtraFeesRequest({
    required this.extraFees,
    required this.extraFeesDescription,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'extraFees': extraFees,
        'extraFeesDescription': extraFeesDescription,
      };

  @override
  List<Object?> get props => [extraFees, extraFeesDescription];
}
