import 'package:flutter/widgets.dart';
import 'package:qtadmin_studio/store/app_store.dart';

/// 通过 InheritedNotifier 向下分发 AppStore，路由层与页面共享治理数据。
class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({
    super.key,
    required AppStore super.notifier,
    required super.child,
  });

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope 未在组件树上');
    return scope!.notifier!;
  }
}
