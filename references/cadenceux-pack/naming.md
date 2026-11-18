# CadenceUX naming conventions

Applied **rule by rule** over ADK's Baseline. Only the rules below differ from it; every other
Baseline rule (primary and foreign keys, housekeeping fields, the `_calc`, `_unstored` and
`_summary` suffixes, layouts, variables, value lists, deprecation, starting a script's action
with a verb where the domain doesn't already say it, and grouping scripts in folders) still
applies.

## Scripts

- A script name is `Domain: Action`: a one-word domain in Title Case, a colon and one space,
  then the action in Title Case. `Email: Invoice To Contact`, `Search: Staff`,
  `Report: Monthly Sales`.
- The domain is the area of work the script belongs to. Use one of `Search`, `Email`,
  `Export`, `Import`, `Report`, `Update`, `Validate`, `Create`, `Delete`, `Navigate`, `Print`,
  `Utility` or `Trigger`. When none fits, use the singular name of the base table the script
  works on: `Invoice: Recalculate Totals`.
- A script that a script trigger calls (the wrapper the Baseline's "Script triggers" pattern
  requires) uses the `Trigger` domain, then the layout or object and the trigger:
  `Trigger: Invoice Detail OnRecordLoad`. This replaces the Baseline's trigger-script prefix.
- When one action has more than one version, every version carries a variant: a space, a pipe
  and a space, then the variant in Title Case: `Search: Staff | Single` and
  `Search: Staff | Batch`. An action with one version has no variant.
- Parameters are not part of the name. The script's header records them on its `PARAMETERS`
  line (see "Script commenting headers" in `patterns.md`). This replaces the Baseline's rule of
  carrying the parameter signature in the name.
- A script whose behaviour depends on a mode passed in its parameter ends with the mode name
  in square brackets: `Export: Orders [Mode]`.
- A copy of a script kept for reference before it is changed ends with ` [OLD]`:
  `Email: Invoice To Contact [OLD]`. It is never called. When nothing references it any more,
  deprecate it per the Baseline's "Deprecation" rule.

## Fields

- Related fields share a dot-separated namespace, from general to specific, each part in
  UpperCamelCase: `Address.City`, `Address.Postcode`, `Invoice.Total.Tax`. The first part is
  the entity or group the field belongs to; add parts only while they narrow the meaning.
- A global field ends with `_g`: `UserName_g`, `Settings.CompanyName_g`. This replaces the
  Baseline's `_global`. The Baseline's `_calc`, `_unstored` and `_summary` suffixes still
  apply; a global calculation carries both, `_calc_g`.
- Configuration globals live in the settings table (see "Configuration globals" in
  `patterns.md`), never in the table that uses them.

## Table occurrences

- The occurrence a table's layouts and scripts default to is named after the base table, as
  in the Baseline: `Invoice`.
- Every other occurrence is a dot-separated context path from the occurrence it is related
  from to the base table it points at, then, when two paths would otherwise share a name, what
  it is for: `Invoice.Contact`, `Invoice.LineItem`, `Contact.Invoice.Open`. Each part is the
  base table name in UpperCamelCase, singular.
- An occurrence used only to import or stage data starts with a lowercase prefix naming the
  source and an underscore: `xml_Order`, `csv_Order`. When the source has no short name, the
  prefix is `imp_`.
