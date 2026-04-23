import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_service.dart';
import '../../models/visitor.dart';
import '../auth/auth_provider.dart';

class VisitorsState {
  final List<Visitor> visitors;
  final bool isLoading;
  final String? error;
  final bool initialized;

  const VisitorsState({
    this.visitors = const [],
    this.isLoading = false,
    this.error,
    this.initialized = false,
  });

  VisitorsState copyWith({
    List<Visitor>? visitors,
    bool? isLoading,
    String? error,
    bool? initialized,
  }) {
    return VisitorsState(
      visitors: visitors ?? this.visitors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      initialized: initialized ?? this.initialized,
    );
  }
}

class VisitorsNotifier extends StateNotifier<VisitorsState> {
  VisitorsNotifier(this._ref) : super(const VisitorsState());

  final Ref _ref;

  Future<void> loadVisitors({bool force = false}) async {
    final authState = _ref.read(authProvider);
    final token = authState.user?.token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        visitors: const [],
        isLoading: false,
        error: 'You need to sign in before loading visitors.',
        initialized: true,
      );
      return;
    }

    if (!force && state.initialized && state.visitors.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final visitors = await ApiService.getVisits(token);
      state = state.copyWith(
        visitors: visitors,
        isLoading: false,
        error: null,
        initialized: true,
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        initialized: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to fetch visitors from the API.',
        initialized: true,
      );
    }
  }

  Future<String> createInvitation({
    required String visitorName,
    required String email,
    required String phone,
    required String purpose,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final user = _requireUser();
    final token = user.token!;
    final orgId = user.orgId;

    if (orgId == null || orgId.isEmpty) {
      throw ApiException('The logged-in user response does not include an orgId.');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final startTime = _formatTimeOfDay(time);
      final endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ).add(const Duration(hours: 1));

      final visit = await ApiService.createVisit(
        token: token,
        fields: {
          'visitorName': visitorName,
          'email': email,
          'phone': phone,
          'purpose': purpose,
          'orgId': orgId,
          'hostId': user.id,
          'hostName': user.name,
          'visitingDate': _formatDate(date),
          'timeFrom': startTime,
          'timeTo': _formatTimeOfDay(
            TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute),
          ),
          'registrationSource': 'invite',
          'status': 'invited',
        },
      );

      final inviteToken = await ApiService.issueInvite(
        token: token,
        visitId: visit.id,
        orgId: orgId,
      );

      _upsertVisitor(visit.copyWith(inviteToken: inviteToken));
      state = state.copyWith(isLoading: false, error: null, initialized: true);
      return inviteToken;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      rethrow;
    } catch (_) {
      const message = 'Unable to create the visitor invitation.';
      state = state.copyWith(isLoading: false, error: message);
      throw ApiException(message);
    }
  }

  Future<void> approveVisitor(String visitId) async {
    await _updateVisit(
      visitId: visitId,
      fields: {'status': 'approved'},
    );
  }

  Future<void> rejectVisitor(String visitId, {String? reason}) async {
    await _updateVisit(
      visitId: visitId,
      fields: {
        'status': 'rejected',
        'rejectReason': reason ?? 'Declined from the app.',
      },
    );
  }

  Future<void> rescheduleVisitor({
    required String visitId,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).add(const Duration(hours: 1));

    await _updateVisit(
      visitId: visitId,
      fields: {
        'status': 'approved',
        'visitingDate': _formatDate(date),
        'timeFrom': _formatTimeOfDay(time),
        'timeTo': _formatTimeOfDay(
          TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute),
        ),
      },
    );
  }

  Future<void> confirmCheckIn(String visitId, {String? note}) async {
    await _confirmVisitStatus(
      visitId: visitId,
      status: 'checked_in',
      note: note,
    );
  }

  Future<void> confirmCheckOut(String visitId, {String? note}) async {
    await _confirmVisitStatus(
      visitId: visitId,
      status: 'checked_out',
      note: note,
    );
  }

  void clear() {
    state = const VisitorsState();
  }

  Future<void> _updateVisit({
    required String visitId,
    required Map<String, dynamic> fields,
  }) async {
    final user = _requireUser();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updated = await ApiService.updateVisit(
        token: user.token!,
        visitId: visitId,
        fields: fields,
      );

      _upsertVisitor(updated);
      state = state.copyWith(isLoading: false, error: null, initialized: true);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      rethrow;
    } catch (_) {
      const message = 'Unable to update the visitor status.';
      state = state.copyWith(isLoading: false, error: message);
      throw ApiException(message);
    }
  }

  Future<void> _confirmVisitStatus({
    required String visitId,
    required String status,
    String? note,
  }) async {
    final user = _requireUser();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updated = await ApiService.confirmScan(
        token: user.token!,
        visitId: visitId,
        status: status,
        performer: user.name,
        note: note,
      );

      _upsertVisitor(updated);
      state = state.copyWith(isLoading: false, error: null, initialized: true);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      rethrow;
    } catch (_) {
      const message = 'Unable to confirm the visitor status.';
      state = state.copyWith(isLoading: false, error: message);
      throw ApiException(message);
    }
  }

  User _requireUser() {
    final user = _ref.read(authProvider).user;
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw ApiException('You need to sign in before calling this action.');
    }
    return user;
  }

  void _upsertVisitor(Visitor visitor) {
    final nextVisitors = [...state.visitors];
    final index = nextVisitors.indexWhere((item) => item.id == visitor.id);

    if (index >= 0) {
      nextVisitors[index] = visitor;
    } else {
      nextVisitors.insert(0, visitor);
    }

    state = state.copyWith(visitors: nextVisitors, initialized: true);
  }
}

final visitorsStateProvider =
    StateNotifierProvider<VisitorsNotifier, VisitorsState>((ref) {
  return VisitorsNotifier(ref);
});

final visitorsProvider = Provider<List<Visitor>>((ref) {
  return ref.watch(visitorsStateProvider).visitors;
});

final selectedFilterProvider = StateProvider<VisitorStatus?>((ref) => null);
final visitorSearchProvider = StateProvider<String>((ref) => '');

final filteredVisitorsProvider = Provider<List<Visitor>>((ref) {
  final visitors = ref.watch(visitorsProvider);
  final filter = ref.watch(selectedFilterProvider);
  final search = ref.watch(visitorSearchProvider).toLowerCase().trim();

  var result = visitors;

  if (filter != null) {
    result = result.where((visitor) => visitor.status == filter).toList();
  }

  if (search.isNotEmpty) {
    result = result.where((visitor) {
      return visitor.name.toLowerCase().contains(search) ||
          visitor.email.toLowerCase().contains(search) ||
          visitor.phone.toLowerCase().contains(search) ||
          visitor.host.toLowerCase().contains(search);
    }).toList();
  }

  return result;
});

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
