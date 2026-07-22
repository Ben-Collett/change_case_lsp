BIN_DIR = bin
BIN_NAME = change_case_lsp.dart
OUT_NAME = change_case_lsp.exe
VIDEO_DIR = demo_video
GIF_FILE = demo.gif
GIF_TMP_FILE = demo_temp.gif
MP4_FILE = demo.mp4
AVIF_FILE = demo.avif
TAPE_FILE = demo.tape

.PHONY: compile always gif demo

compile:
	-rm $(BIN_DIR)/$(OUT_NAME)
	dart compile exe $(BIN_DIR)/$(BIN_NAME)

gif:
	cd $(VIDEO_DIR) && sed 's/^Output.*/Output $(GIF_FILE)/' $(TAPE_FILE) | vhs -
	ffmpeg -y -i $(VIDEO_DIR)/$(GIF_FILE) -ss 1 $(VIDEO_DIR)/$(GIF_TMP_FILE)
	mv $(VIDEO_DIR)/$(GIF_TMP_FILE) $(VIDEO_DIR)/$(GIF_FILE)

demo:
	cd $(VIDEO_DIR) && vhs $(TAPE_FILE)
	crop_params=$$(ffmpeg -i $(VIDEO_DIR)/$(MP4_FILE) -ss 1 -vf "cropdetect=24:2" -f null - 2>&1 | grep -oP 'crop=\d+:\d+:\d+:\d+' | tail -1 | sed 's/crop=//'); \
	ffmpeg -y -i $(VIDEO_DIR)/$(MP4_FILE) -ss 1 -vf "crop=$$crop_params" -c:v libaom-av1 -pix_fmt yuva420p -cpu-used 4 -still-picture 0 $(VIDEO_DIR)/$(AVIF_FILE)
	rm -f $(VIDEO_DIR)/$(MP4_FILE)

