## Add your own custom Makefile targets here

RUN = poetry run
ROBOT_PATH = robot
SQLITE_PATH = sqlite

.PHONY: generateds-all generateds-clean

generateds-clean:
	rm -rf \
			local/gen-owl.owl \
			local/robot-convert.ttl \
			local/Person-only-001.db \
			local/Person-only-001.tsv

generateds-all: generateds-clean local/robot-convert.ttl local/Person-only-001.tsv

local/gen-owl.owl: src/linkml_gen_something_functional/schema/linkml_gen_something_functional.yaml
	$(RUN) gen-owl $< > $@

local/robot-convert.ttl: local/gen-owl.owl
	$(ROBOT_PATH) convert --input $< --output $@

# WARNING:root:There is no established path to linkml-gen-something-functional - compile_python may or may not work

local/Person-only-001.db: src/linkml_gen_something_functional/schema/linkml_gen_something_functional.yaml examples/Person-only-001.yaml
	$(RUN) linkml-sqldb dump \
		--db $@ \
		--input-format yaml \
		--target-class Person \
		--index-slot entries \
		--schema $^

local/Person-only-001.tsv: local/Person-only-001.db
	$(SQLITE_PATH) $< ".header on" ".mode tabs" "SELECT * from Person" > $@


#Usage: gen-owl [OPTIONS] YAMLFILE
 #
 #  Note that in previous versions of this generator, the default was to use
 #  type objects and to include metaclasses. To restore this behavior:
 #
 #      gen-owl --metaclasses --type-objects my_schema.yaml
 #
 #  For more info, see: https://linkml.io/linkml/generators/owl
 #
 #Options:
 #  -o, --output TEXT               Output file name
 #  --metadata-profile [linkml|rdfs|ols]
 #                                  What kind of metadata profile to use for
 #                                  annotations on generated OWL objects
 #                                  [default: linkml]
 #  --type-objects / --no-type-objects
 #                                  If true, will model linkml types as objects,
 #                                  not literals  [default: no-type-objects]
 #  --metaclasses / --no-metaclasses
 #                                  If true, include linkml metamodel classes as
 #                                  metaclasses. Note this introduces punning in
 #                                  OWL-DL  [default: no-metaclasses]
 #  --add-root-classes / --no-add-root-classes
 #                                  If true, include linkml metamodel classes as
 #                                  superclasses.  [default: no-add-root-
 #                                  classes]
 #  --add-ols-annotations / --no-add-ols-annotations
 #                                  If true, auto-include annotations from
 #                                  https://www.ebi.ac.uk/ols/docs/installation-
 #                                  guide  [default: add-ols-annotations]
 #  --ontology-uri-suffix TEXT      Suffix to append to schema id to generate
 #                                  OWL Ontology IRI  [default: .owl.ttl]
 #  --assert-equivalent-classes / --no-assert-equivalent-classes
 #                                  If true, add owl:equivalentClass between a
 #                                  class and a class_uri  [default: no-assert-
 #                                  equivalent-classes]
 #  --mixins-as-expressions / --no-mixins-as-expressions
 #                                  If true, then mixins are represented as
 #                                  existential expressions  [default: no-
 #                                  mixins-as-expressions]
 #  --use-native-uris / --no-use-native-uris
 #                                  Use model URIs rather than class/slot URIs
 #                                  [default: use-native-uris]
 #  -V, --version                   Show the version and exit.
 #  -f, --format [owl|ttl|json-ld|xml|n3|turtle|ttl|ntriples|nt|nt11|nquads|trix|trig|hext]
 #                                  Output format  [default: owl]
 #  --metadata / --no-metadata      Include metadata in output  [default:
 #                                  metadata]
 #  --useuris / --metauris          Use class and slot URIs over model uris
 #                                  [default: useuris]
 #  -im, --importmap FILENAME       Import mapping file
 #  --log_level [CRITICAL|ERROR|WARNING|INFO|DEBUG]
 #                                  Logging level  [default: WARNING]
 #  -v, --verbose                   Verbosity. Takes precedence over
 #                                  --log_level.
 #  --mergeimports / --no-mergeimports
 #                                  Merge imports into source file
 #                                  (default=mergeimports)
 #  --stacktrace / --no-stacktrace  Print a stack trace when an error occurs
 #                                  [default: no-stacktrace]
 #  --help                          Show this message and exit.