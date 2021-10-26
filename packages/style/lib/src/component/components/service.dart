part of '../../style_base.dart';

///
class Server extends StatefulComponent {
  ///
  Server(
      {GlobalKey? key,
      HttpService? httpServiceNew,
      this.socketService,
      this.dataAccess,
      this.cryptoService,
      Logger? logger,
      String? rootName,
      this.rootEndpoint,
      this.authorization,
      required this.children,
      this.faviconDirectory,
      Map<Type, ExceptionEndpoint>? defaultExceptionEndpoints})
      : httpServiceNew = httpServiceNew ?? DefaultHttpServiceHandler(),
        logger = logger ?? DefaultLogger(),
        rootName = rootName ?? "style_server",
        defaultExceptionEndpoints = defaultExceptionEndpoints ??
            {
              Exception: DefaultExceptionEndpoint<Exception>(),
            },
        super(key: key ?? GlobalKey<ServiceState>.random()) {
    this.defaultExceptionEndpoints[Exception] ??=
        DefaultExceptionEndpoint<Exception>();
  }

  ///
  final Map<Type, ExceptionEndpoint> defaultExceptionEndpoints;

  ///
  final String? faviconDirectory;

  ///
  final String rootName;

  ///
  final Logger? logger;

  ///
  final Crypto? cryptoService;

  ///
  final DataAccess? dataAccess;

  ///
  final WebSocketService? socketService;

  ///
  final HttpService httpServiceNew;

  ///
  final Authorization? authorization;

  ///
  final List<Component> children;

  ///
  final Component? rootEndpoint;

  @override
  State<StatefulComponent> createState() => ServiceState();
}

///
class ServiceState extends State<Server> {
  ///
  String get rootName => component.rootName;

  ///
  Crypto get cryptoService => component.cryptoService!;

  ///
  DataAccess get dataAccess => component.dataAccess!;

  ///
  WebSocketService get socketService => component.socketService!;

  ///
  HttpService get httpServiceNew => component.httpServiceNew;

  ///
  Authorization get authorization => component.authorization!;

  @override
  Component build(BuildContext context) {
    Component result = Gateway(children: [
      if (component.faviconDirectory != null)
        Route("favicon.ico", root: Favicon(component.faviconDirectory!)),
      if (component.rootEndpoint != null)
        Route("*root", root: component.rootEndpoint),
      ...component.children
    ]);

    result = ServiceWrapper<HttpService>(
        service: component.httpServiceNew, child: result);
    if (component.logger != null) {
      result =
          ServiceWrapper<Logger>(service: component.logger!, child: result);
    }
    if (component.cryptoService != null) {
      result = ServiceWrapper<Crypto>(service: cryptoService, child: result);
    }

    if (component.socketService != null) {
      result = ServiceWrapper<WebSocketService>(
          service: socketService, child: result);
    }

    if (component.dataAccess != null) {
      result = ServiceWrapper<DataAccess>(service: dataAccess, child: result);
    }

    if (component.authorization != null) {
      result =
          ServiceWrapper<Authorization>(service: authorization, child: result);
    }

    return ServiceCallingComponent(
        rootName: rootName,
        child: ExceptionWrapper.fromMap(
            map: component.defaultExceptionEndpoints, child: result));
  }
}

///
class ServiceCallingComponent extends SingleChildCallingComponent {
  ///
  ServiceCallingComponent({
    required this.rootName,
    required this.child,
    this.serviceMaxIdleDuration = const Duration(minutes: 180),
    this.createStateOnCall = true,
    this.createStateOnInitialize = true,
  }) : super(child);

  ///
  final String rootName;

  ///
  final bool createStateOnInitialize;

  ///
  final Duration serviceMaxIdleDuration;

  ///
  final bool createStateOnCall;

  ///
  final Component child;

  /// type belirtilmezse bir üsttekini getirir
  /// type belirtilirse ve bir üstteki o type değilse
  /// üst ağaçtan o servisi bulur
  static T of<T extends ServiceState>(BuildContext context) {
    var serviceBinding = context.owner;
    if (serviceBinding is StatefulBinding &&
        (serviceBinding as StatefulBinding).state is T) {
      return (serviceBinding as StatefulBinding).state as T;
    } else {
      var serviceComponent = context.findAncestorStateOfType<T>();

      if (serviceComponent == null) {
        throw Exception("No $T found of binding tree");
      }
      return serviceComponent;
    }
  }

  @override
  ServiceBinding createBinding() => ServiceBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      ServiceCalling(binding: context as ServiceBinding);
}

///
class ServiceBinding extends SingleChildCallingBinding with ServiceOwnerMixin {
  ///
  ServiceBinding(ServiceCallingComponent component) : super(component);

  @override
  ServiceCallingComponent get component =>
      super.component as ServiceCallingComponent;

  ///
  late Binding rootEndpoint;

  late GatewayCalling _childGateway;

  @override
  void _build() {
    serviceRootName = component.rootName;
    _calling = component.createCalling(this);
    _child = component.child.createBinding();
    _owner = this;
    _child.attachToParent(this);
    var _ancestor = _parent;
    while (_ancestor != null && _ancestor._owner == null) {
      _ancestor._owner = this;
      _ancestor = _ancestor._parent;
    }
    _child._build();
    _childGateway = _child.visitCallingChildren(TreeVisitor((visitor) {
      if (visitor.currentValue is GatewayCalling) {
        visitor.stop();
      }
    })).result as GatewayCalling;
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);
    if (!visitor._stopped) {
      return child.visitChildren(visitor);
    }
    return visitor;
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    if (!visitor._stopped) {
      return child.visitCallingChildren(visitor);
    }
    return visitor;
  }
}

///
class ServiceCalling extends Calling {
  ///
  ServiceCalling({required ServiceBinding binding}) : super(binding);

  @override
  ServiceBinding get binding => super.binding as ServiceBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    request.path
        .resolveFor(binding._childGateway.childrenBinding.keys.toList());
    return (binding.child).findCalling.calling(request);
  }
}

///
mixin ServiceOwnerMixin on Binding {
  final Map<GlobalKey, StatefulBinding> _states = {};

  ///
  void addState(State state) {
    _states[state.component.key as GlobalKey] = state.context;
  }

  ///
  late String serviceRootName;
}
