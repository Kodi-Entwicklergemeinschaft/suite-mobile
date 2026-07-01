enum ActionConstant {
  category('category'),
  feature('feature'),
  serviceHub('service_hub'),
  urlWebview('url_webview'),
  urlBrowser('url_browser'),
  linkHub('linkhub');

  final String name;

  const ActionConstant(this.name);

  static ActionConstant? fromName(String? name) {
    return ActionConstant.values.firstWhere((element) => element.name == name);
  }
}
