# Changelog

## Unreleased

- Model name msgids now use the raw class name (`BigCar`, `Admin::User`) instead of the
  humanized form (`Big car`), matching `human_attribute_name`. The humanized form is still
  looked up as a deprecated fallback and warns once per msgid. See #207.
- `rake gettext:store_model_attributes` now emits model names as `n_()` singular/plural
  pairs, so model name plurals (`model_name.human(count:)`) can be translated via
  `msgid_plural`. Re-extract to pick up the plural entries. See #207.

### Upgrading model name msgids (#207)

Up to version 2.1.0 model names were looked up by their humanized form (`_('Big car')`),
while attributes already used the raw class name (`_('BigCar|Wheels size')`). Model names
now also use the raw class name (`_('BigCar')`, `_('Admin::User')`), so name and attribute
lookups are consistent and greppable.

The old humanized msgid is still looked up as a fallback and prints a one-time deprecation
warning. To migrate:

 - re-run `rake gettext:store_model_attributes` and `rake gettext:find`
 - rename the affected `msgid`s in your `*.po` files (`Big car` -> `BigCar`)

The humanized fallback will be removed in a future major release.

Model names are now extracted as `n_()` singular/plural pairs, so a translated
`model_name.human(count:)` needs the `msgid_plural` filled in your `*.po` files.

## 2.1.0

- Add automatic reloading of .po and .mo files in development mode

## 2.0.0

- change how model attributes are looked up (class first, then sti root)
- drop support for old rubies

## v1.13.0

- Use subclasses instead of direct_descendants on rails 7 and above

## v1.12.0

- drop support for gettext < 3
- improve haml and slim parsing
