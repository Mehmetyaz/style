/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of style_dart;

abstract class ModuleDelegate {
  /// The context in which the service attached
  late final BuildContext _context;

  BuildContext get context => _context;

  void _attach(BuildContext context) {
    _context = context;
  }

  /// Service is initialized
  bool initialized = false;

  /// Init Service
  FutureOr<bool> init();

  FutureOr<void> _init() async {
    var i = init();
    if (i is Future) {
      initialized = await i;
      _initializeCompleter.complete(initialized);
    } else {
      initialized = i;
    }
  }

  late final Completer<bool> _initializeCompleter = Completer<bool>();

  /// Wait service is initialized.
  ///
  /// if service initializing is success returns true.
  FutureOr<bool> ensureInitialize() {
    if (_initializeCompleter.isCompleted) {
      return initialized;
    }
    return _initializeCompleter.future;
  }
}

class ModuleBindComponent<T extends ModuleDelegate>
    extends SingleChildBindingComponent {
  ModuleBindComponent(
      {required super.child, required this.delegate, super.key});

  final T delegate;

  @override
  SingleChildBinding createCustomBinding() {
    return ModuleDelegateBinding(this);
  }

  @override
  Component build(BuildContext context) {
    return child;
  }
}

class ModuleDelegateBinding<T extends ModuleDelegate>
    extends SingleChildBinding {
  ModuleDelegateBinding(ModuleBindComponent<T> super.component);

  @override
  ModuleBindComponent<T> get component =>
      super.component as ModuleBindComponent<T>;
}
