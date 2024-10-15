.DEFAULT_GOAL := init

# Initialize the makemarkers directory (helps track out-of-date dependencies).
init:
	mkdir -p .makemarkers


# ----------------------------------------------------------------------------#
#     BUILD STATIC DOCUMENTATION SITE
# ----------------------------------------------------------------------------#

%:
	@echo "dummy target: $@"

.PHONY: html
html: .makemarkers/sphinx-docs


.makemarkers/sphinx-autogen: \
	$(shell find src/op_analytics/cli/subcommands/misc/dbtgen -type f -print0 | xargs -0 ls -t | head -n 1) \
	$(shell find packages/op-datasets/src/op_datasets/schemas -type f -print0 | xargs -0 ls -t | head -n 1) \
	src/op_analytics/cli/subcommands/misc/docsgen/coreschemas.md
	@echo "Running sphinx documentation autegen."
	uv run opdata misc generate_docs
	uv run opdata misc generate_dbt
	@touch .makemarkers/sphinx-autogen


# NOTE (pedro - 2024/09/24) There is a bug in the "_get_one_catalog" function in dbt/adapters/base/impl.py
# For the duckdb adapter the get_one_catalog macro requires "needs_conn=True" but that kwarg is not set
# This causes the "docs generate" command to fail unless we use --empty-catalog.
#
# The second command here is to customize the docs site and bundle it up as a single static HTML file.
.makemarkers/dbt-autogen: \
	$(wildcard dbt/docs/*.md) \
	$(wildcard dbt/models/*.sql) \
	$(wildcard dbt/sources/*.yml)
	@echo "Running dbt documentation autegen."
	./scripts/dbt_docs.sh
	uv run opdata misc customize_dbt
	@touch .makemarkers/dbt-autogen


.makemarkers/sphinx-docs: \
	.makemarkers/sphinx-autogen \
	.makemarkers/dbt-autogen \
	$(shell find sphinx -type f -print0 | xargs -0 ls -t | head -n 1)
	$(MAKE) -C sphinx clean
	$(MAKE) -C sphinx html
	@touch .makemarkers/sphinx-docs


# ----------------------------------------------------------------------------#
#     MAKE COPIES OF HTML CONTENT THAT NEEDS TO BE SERVED ON THE STATIC SITE
# ----------------------------------------------------------------------------#

html-copies:
	find "op_rewards_tracking" -type f -name "*.html" > rsync-files.txt
	rsync -aSvuc --recursive --files-from=rsync-files.txt . "docs/"
	rm rsync-files.txt

# ----------------------------------------------------------------------------#
#     LOCAL DEVELOPMENT
# ----------------------------------------------------------------------------#

.PHONY: sphinx-serve
sphinx-serve: .makemarkers/sphinx-docs
	cd docs && uv run python -m http.server

