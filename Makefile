BIN_DIR = bin
BIN_NAME = change_case_lsp.dart
OUT_NAME = change_case_lsp.exe

.PHONY: compile, always
compile:
	-rm $(BIN_DIR)/$(OUT_NAME)
	dart compile exe $(BIN_DIR)/$(BIN_NAME)
