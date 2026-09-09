import 'package:careconnect_mobile/data/daily_tasks_repository.dart';
import 'package:careconnect_mobile/state/daily_tasks_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyTasksController', () {
    late DailyTasksController controller;

    setUp(() {
      controller = DailyTasksController(
        repository: InMemoryDailyTasksRepository(),
      );
    });

    test('starts with the seeded tasks, none done', () {
      expect(controller.totalCount, 7);
      expect(controller.doneCount, 0);
      expect(controller.progress, 0);
    });

    test('toggling a task marks it done and notifies listeners', () {
      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggleTask('1');

      expect(notifications, 1);
      expect(controller.doneCount, 1);
      expect(controller.tasks.firstWhere((t) => t.id == '1').isDone, isTrue);
    });

    test('toggling the same task again marks it not done', () {
      controller.toggleTask('1');
      controller.toggleTask('1');

      expect(controller.doneCount, 0);
      expect(controller.tasks.firstWhere((t) => t.id == '1').isDone, isFalse);
    });

    test('progress is doneCount divided by totalCount', () {
      controller.toggleTask('1');
      controller.toggleTask('2');

      expect(controller.progress, closeTo(2 / 7, 1e-9));
    });

    test('the appointment notification starts visible', () {
      expect(controller.showNotification, isTrue);
    });

    test('dismissing the notification hides it and notifies listeners', () {
      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.dismissNotification();

      expect(notifications, 1);
      expect(controller.showNotification, isFalse);
    });
  });
}
