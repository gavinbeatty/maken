PROJECT = maken

bindir = $(DESTDIR)$(prefix)/bin
man5dir = $(DESTDIR)$(prefix)/share/man/man5
docdir = $(DESTDIR)$(prefix)/share/doc/$(PROJECT)
doc_examplesdir = $(DESTDIR)$(prefix)/share/doc/$(PROJECT)/examples

default: all
.PHONY: default

.SUFFIXES:

include make/maken.mk
-include make/.builddir.mk
-include $(builddir)/.build.mk

ifneq ($(HAVE_BUILDDIR),1)
all: conf
	$(make_p)$(MAKE) all
conf: builddir
	$(call write_builddir_path,builddir)
else
all: bin doc
endif
install: install-bin install-doc
clean:
	$(call clean_dir_p,$(builddir))$(RM) -r $(builddir)
builddir_doc:
	@$(INSTALL_DIR) $(builddir)/doc
builddir: builddir_ builddir_doc
.PHONY: all conf install clean builddir builddir_doc

DOCS_DEP =
DOCS_DEP += doc/$(PROJECT).5.txt.in
DOCS_DEP += $(builddir)/doc/$(PROJECT).5.txt
DOCS_DEP += $(builddir)/doc/$(PROJECT).5.html
DOCS_DEP += $(builddir)/doc/$(PROJECT).5
DOCS_DEP += $(builddir)/doc/$(PROJECT).txt
DOCS_MAN5 =
DOCS_MAN5 += $(builddir)/doc/$(PROJECT).5.html
DOCS_MAN5 += $(builddir)/doc/$(PROJECT).5
DOCS_DOC =
DOCS_DOC += $(builddir)/doc/$(PROJECT).txt
DOCS_DOC += README.markdown
DOCS_EXAMPLES_MAKEN =
DOCS_EXAMPLES_MAKEN += Makefile
DOCS_EXAMPLES = $(DOCS_EXAMPLES_MAKEN)
DOCS_INSTALL = $(DOCS_MAN5) $(DOCS_DOC) $(DOCS_EXAMPLES)

$(builddir)/doc/$(PROJECT).5.txt: doc/$(PROJECT).5.txt.in $(VERSION_DEP)
	$(gen_p)$(SED) -e 's/^# @VERSION@/:man version: $(VERSION)/' $< > $@
$(builddir)/doc/$(PROJECT).5: $(builddir)/doc/$(PROJECT).5.txt
	$(a2x_p)$(A2X) -f manpage -L $<
$(builddir)/doc/$(PROJECT).5.html: $(builddir)/doc/$(PROJECT).5.txt
	$(asciidoc_p)$(ASCIIDOC) $<
$(builddir)/doc/$(PROJECT).txt: $(builddir)/doc/$(PROJECT).5
	$(roff_p)$(call man2txt,$<,$@)
doc: $(DOCS_DEP)
install-doc: $(DOCS_INSTALL)
	@$(INSTALL_DIR) $(man5dir)
	$(INSTALL_DATA) $(DOCS_MAN5) $(man5dir)
	@$(INSTALL_DIR) $(docdir)
	$(INSTALL_DATA) $(DOCS_DOC) $(docdir)
	@$(INSTALL_DIR) $(doc_examplesdir)
	$(INSTALL_DATA) $(DOCS_EXAMPLES_MAKEN) $(addprefix $(doc_examplesdir)/,$(join $(DOCS_EXAMPLES_MAKEN),.maken))
.PHONY: doc install-doc

## maken has no bins to install
# BINS =
# BINS += $(builddir)/$(PROJECT)
# BINS_INSTALL = $(BINS)
#
# $(builddir)/$(PROJECT): $(PROJECT).sh $(VERSION_DEP)
# 	$(gen_p)$(SED) -e 's/^# @VERSION@/VERSION=$(VERSION)/' $< > $@
# 	@chmod +x $(builddir)/$(PROJECT)
# bin: $(BINS)
# install-bin: $(BINS_INSTALL)
# 	@$(INSTALL_DIR) $(bindir)
# 	$(INSTALL_BIN) $(BINS_INSTALL) $(bindir)
.PHONY: bin install-bin


