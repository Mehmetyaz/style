/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../style_base.dart';

/// Ana Mimarideki her bir parça
///
@immutable
abstract class Component {
  ///
  const Component({this.key});

  ///
  final Key? key;

  ///
  Binding createBinding();

  ///
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  ///
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class StatelessComponent extends Component {
  ///
  const StatelessComponent({Key? key}) : super(key: key);

  @override
  StatelessBinding createBinding() => StatelessBinding(this);

  ///
  Component build(BuildContext context);

  @override
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class StatefulComponent extends Component {
  ///
  const StatefulComponent({GlobalKey<State<StatefulComponent>>? key})
      : super(key: key);

  ///
  State<StatefulComponent> createState();

  @override
  // TODO: implement key
  GlobalKey<State<StatefulComponent>>? get key =>
      super.key as GlobalKey<State<StatefulComponent>>?;

  ///
  @override
  StatefulBinding createBinding() => StatefulBinding(this);
}

///
abstract class State<T extends StatefulComponent> {
  ///
  bool get attached => _binding != null;

  ///
  Component build(BuildContext context);

  T? _component;

  ///
  T get component => _component!;

  StatefulBinding? _binding;

  ///
  StatefulBinding get context => _binding!;

  ///
  GlobalKey<State<T>> get key => context.key as GlobalKey<State<T>>;

  ///
  void initState() async {}
}


RandomGenerator _randomKey = RandomGenerator("[*]/l(20)");

///
@immutable
class Key {
  ///
  const Key(this.key);

  ///
  Key.random() : key = _randomKey.generateString();

  ///
  final String key;
}

///
@immutable
class GlobalKey<T extends State<StatefulComponent>> extends Key {
  ///
  GlobalKey(String key) : super(key);

  ///
  GlobalKey.random() : super.random();

  ///
  late final StatefulBinding binding;

  ///
  T get state {
    return binding._state as T;
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalKey<T> && other.key == key;
  }

  late final int _hashCode = Object.hash(key, T);

  @override
  int get hashCode => _hashCode;
}

/// TODO:
abstract class CallingComponent extends Component {
  /// TODO:
  const CallingComponent({Key? key}) : super(key: key);

  @override
  CallingBinding createBinding();

  ///
  Calling createCalling(BuildContext context);

  @override
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class SingleChildCallingComponent extends CallingComponent {
  ///
  SingleChildCallingComponent(this.child, {Key? key}) : super(key: key);

  ///
  final Component child;

  @override
  SingleChildCallingBinding createBinding();
}

///
abstract class MultiChildCallingComponent extends CallingComponent {
  ///
  MultiChildCallingComponent(this.children);

  ///
  final List<Component> children;

  @override
  MultiChildCallingBinding createBinding() => MultiChildCallingBinding(this);
}

/// Server
/// Service
///
/// MultiChild,
/// SingleChild,
/// Endpoint
abstract class CallingBinding extends Binding {
  ///
  CallingBinding(CallingComponent component) : super(component);

  @override
  CallingComponent get component => super.component as CallingComponent;

  ///
  Calling get calling => _calling!;

  Calling? _calling;

  ///
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor);

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return callingVisitor(visitor);
  }
}

///
abstract class SingleChildBindingComponent extends StatelessComponent {
  ///
  SingleChildBindingComponent(this.child);

  ///
  final Component child;

  ///
  SingleChildBinding createCustomBinding();
}

///
class SingleChildBinding extends Binding {
  ///
  SingleChildBinding(Component component) : super(component);

  @override
  SingleChildCallingComponent get component =>
      super.component as SingleChildCallingComponent;

  late Binding _child;

  ///
  Binding get child => _child;

  @override
  void buildBinding() {
    _child = component.child.createBinding();

    _child.attachToParent(this);
    _child.buildBinding();
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    // TODO: implement visitCallingChildren
    throw UnimplementedError();
  }
}

///
class SingleChildCallingBinding extends CallingBinding {
  ///
  SingleChildCallingBinding(SingleChildCallingComponent component)
      : super(component);

  @override
  SingleChildCallingComponent get component =>
      super.component as SingleChildCallingComponent;

  late Binding _child;

  ///
  Binding get child => _child;

  @override
  void buildBinding() {
    _calling = component.createCalling(this);
    _child = component.child.createBinding();

    _child.attachToParent(this);
    _child.buildBinding();
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor.stopped) return visitor;
    visitor(calling);
    return child.visitCallingChildren(visitor);
  }
}

///
class MultiChildCallingBinding extends CallingBinding {
  ///
  MultiChildCallingBinding(MultiChildCallingComponent component)
      : super(component);

  @override
  MultiChildCallingComponent get component =>
      super.component as MultiChildCallingComponent;

  ///
  late List<Binding> children;

  /// Bir map yap buildde
  /// Bu mapde callingler bulunsun
  ///
  @override
  void buildBinding() {
    var _bindings = <Binding>[];
    for (var element in component.children) {
      _bindings.add(element.createBinding());
    }
    children = _bindings;
    for (var bind in children) {
      bind.attachToParent(this);
      bind.buildBinding();
    }
    _calling = component.createCalling(this);
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor.stopped) return visitor;
    visitor(calling);
    if (!visitor.stopped) {
      for (var child in children) {
        child.visitCallingChildren(visitor);
      }
    }
    return visitor;
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor.stopped) return visitor;
    visitor(this);
    if (!visitor.stopped) {
      //
      for (var bind in children) {
        bind.visitChildren(visitor);
      }
    }
    return visitor;
    //
    // visitor(this);
    // for (var bind in _childrenBindings ?? <Binding>[]) {
    //   bind.visitChildren(visitor);
    // }
  }
}
