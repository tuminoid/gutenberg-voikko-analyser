# simple^Wover-engineered makefile to automate process
# this would be easier to follow if everything was just bash scripts

TOP_DIR := $(shell git rev-parse --show-toplevel)
DATA_DIR := $(TOP_DIR)/data
DOCKER_IMAGE := gutenberg-voikko-analyser
DOCKER_TAG := latest
CONTENT_START := Produced by
CONTENT_END := End of the Project

# flag files
DL_FLAG := $(DATA_DIR)/.download_done
UNZIP_FLAG := $(DATA_DIR)/.unzip_done
WORD_FLAG := $(DATA_DIR)/.words_done
UNIQ_FLAG := $(DATA_DIR)/.unique_done
LIST_FLAG := $(DATA_DIR)/.lists_done


# some readable target names
all: lists
download: $(DL_FLAG)
unzip: $(UNZIP_FLAG)
words: $(WORD_FLAG)
unique: $(UNIQ_FLAG)
lists: $(LIST_FLAG)

# downloading 250M of books is time consuming
$(DL_FLAG):
	@echo "Downloading all Finnish books from Gutenberg: this will take an hour."
	mkdir -p $(DATA_DIR)/books
	cd $(DATA_DIR)/books ; \
	wget -w 2 -m -H "http://www.gutenberg.org/robot/harvest?filetypes[]=txt&langs[]=fi"
	touch $(DL_FLAG)

# unpack zips and move text files into single dir
$(UNZIP_FLAG): $(DL_FLAG)
	@echo "Unpacking zips."
	cd $(DATA_DIR)/books ; \
	for file in $(shell find $(DATA_DIR)/books -name '*.zip'); do \
		unzip -o $${file} ; \
	done
	mv -v $(DATA_DIR)/books/*/*.txt $(DATA_DIR)/books
	touch $(UNZIP_FLAG)

# cleanup and convert to utf-8 so python on linux will process them
$(WORD_FLAG): $(UNZIP_FLAG)
	@echo "Generating a master word list from the books."
	for file in $(DATA_DIR)/books/*.txt ; do \
		mv $${file} $${file}.orig ; \
		awk "/^$(CONTENT_START)/{flag=1;next}/^$(CONTENT_END)/{flag=0}flag" < $${file}.orig > $${file} ; \
		rm -f $${file}.orig ; \
	done
	cat $(DATA_DIR)/books/*.txt | iconv -f ISO-8859-1 -t UTF-8 > $(DATA_DIR)/words.txt
	touch $(WORD_FLAG)

# use voikko to analyse all the words
$(UNIQ_FLAG): $(WORD_FLAG)
	@echo "Building docker image with Voikko to analyze the master list."
	cd $(TOP_DIR)/docker ; \
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) . ; \
	echo "Running voikko: this will take an hour." ; \
	docker run --rm -t -v $(DATA_DIR):/data $(DOCKER_IMAGE):$(DOCKER_TAG) \
		python /usr/src/app/app.py | sort -u | tr -d '\r' > $(DATA_DIR)/unique.txt
	touch $(UNIQ_FLAG)

# make wordlists from the voikko analysis files
$(LIST_FLAG): $(UNIQ_FLAG)
	@echo "Processing all words into classified word lists."
	mkdir -p $(DATA_DIR)/lists ; \
	while read -r line; do \
		line=$$(echo $${line} | tr -d '\r') ; \
		baseform=$${line%:*} ; \
		class=$${line##*:} ; \
		echo "$${baseform}" >> "$(DATA_DIR)/lists/$${class}" ; \
	done < $(DATA_DIR)/unique.txt
	touch $(LIST_FLAG)

.PHONY: clean realclean
clean:
	@echo "Cleaning up temporary data but downloaded books."
	rm -rf $(DATA_DIR)/*.txt $(DATA_DIR)/lists
	rm -f $(DATA_DIR)/.words_done $(DATA_DIR)/.unique_done \
		$(DATA_DIR)/.lists_done $(DATA_DIR)/.unzip_done

realclean:
	@echo "Cleaning up everything."
	rm -rf $(DATA_DIR)/* $(DATA_DIR)/.*_done
