import 'package:equatable/equatable.dart';

abstract class ComplaintEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserComplaints extends ComplaintEvent {}

class LoadAllComplaints extends ComplaintEvent {}

