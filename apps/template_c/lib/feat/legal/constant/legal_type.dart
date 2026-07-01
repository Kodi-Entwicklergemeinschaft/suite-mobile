enum LegalType {
  termsOfUse('terms-of-use'),
  imprint('imprint'),
  privacyPolicy('privacy-policy');

  final String name;
  const LegalType(this.name);
}
